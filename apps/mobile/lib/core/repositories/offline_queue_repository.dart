import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../api/api_client.dart';
import '../db/app_database.dart';
import '../models/evidence_attachment.dart';
import '../models/parcel_models.dart';
import '../models/parcel_status.dart';

class SyncQueueEntry {
  const SyncQueueEntry({
    required this.clientMutationId,
    required this.type,
    required this.deviceId,
    required this.happenedAt,
    required this.attempts,
    required this.lastError,
    required this.synced,
  });

  final String clientMutationId;
  final String type;
  final String deviceId;
  final DateTime happenedAt;
  final int attempts;
  final String? lastError;
  final bool synced;
}

class OfflineQueueRepository {
  OfflineQueueRepository(this._database);

  final AppDatabase _database;
  final Uuid _uuid = const Uuid();

  Future<int> pendingCount() async =>
      (await _database.pendingOperations()).length;

  Future<List<SyncQueueEntry>> pendingEntries() async {
    final rows = await _database.pendingOperations();
    return rows
        .map(
          (row) => SyncQueueEntry(
            clientMutationId: row.clientMutationId,
            type: row.type,
            deviceId: row.deviceId,
            happenedAt: row.happenedAt,
            attempts: row.attempts,
            lastError: row.lastError,
            synced: row.synced,
          ),
        )
        .toList();
  }

  Future<List<SyncQueueEntry>> failedEntries() async {
    final rows = await _database.failedOperations();
    return rows
        .map(
          (row) => SyncQueueEntry(
            clientMutationId: row.clientMutationId,
            type: row.type,
            deviceId: row.deviceId,
            happenedAt: row.happenedAt,
            attempts: row.attempts,
            lastError: row.lastError,
            synced: row.synced,
          ),
        )
        .toList();
  }

  Future<String> enqueueReceive({
    required String trackingCode,
    required String customerName,
    required String? customerPhone,
    required String? labelName,
    required String? secondaryCode,
    required String? note,
    required List<EvidenceAttachment> attachments,
    required String deviceId,
  }) async {
    final mutationId = _uuid.v4();
    final now = DateTime.now();
    final code = trackingCode.trim().isEmpty
        ? fallbackTrackingCode(now)
        : trackingCode.trim();
    final payload = {
      'trackingCode': code,
      'customerName': customerName,
      if (customerPhone?.isNotEmpty == true) 'customerPhone': customerPhone,
      if (labelName?.isNotEmpty == true) 'labelName': labelName,
      if (note?.isNotEmpty == true) 'note': note,
      if (attachments.isNotEmpty)
        'attachments': attachments
            .map((attachment) => attachment.toJson())
            .toList(),
      'rawCodes': [
        {'rawCode': code, 'kind': 'MANUAL', 'isPrimary': true},
        if (secondaryCode?.isNotEmpty == true)
          {'rawCode': secondaryCode, 'kind': 'QR', 'isPrimary': false},
      ],
    };
    await _database.enqueueOperation(
      clientMutationId: mutationId,
      type: 'RECEIVE',
      deviceId: deviceId,
      happenedAt: now,
      payload: payload,
    );
    await _database.upsertLocalParcel(
      ParcelSummary(
        id: mutationId,
        trackingCode: code,
        status: ParcelStatus.receivedInThailand,
        customerName: customerName,
        customerPhone: customerPhone,
        labelName: labelName,
        note: note,
        updatedAt: now,
        queued: true,
      ),
    );
    return code;
  }

  Future<void> enqueueStatus({
    required String trackingCode,
    required ParcelStatus status,
    required String customerName,
    required String? note,
    required List<EvidenceAttachment> attachments,
    required String deviceId,
  }) async {
    final mutationId = _uuid.v4();
    final now = DateTime.now();
    await _database.enqueueOperation(
      clientMutationId: mutationId,
      type: status == ParcelStatus.arrivedInLaos ? 'ARRIVE' : 'PICKUP',
      deviceId: deviceId,
      happenedAt: now,
      payload: {
        'trackingCode': trackingCode,
        if (customerName.isNotEmpty) 'customerName': customerName,
        if (note?.isNotEmpty == true) 'note': note,
        if (attachments.isNotEmpty)
          'attachments': attachments
              .map((attachment) => attachment.toJson())
              .toList(),
      },
    );
    final existing = await _database.findLocalParcel(trackingCode);
    await _database.upsertLocalParcel(
      ParcelSummary(
        id: existing?.id ?? mutationId,
        trackingCode: trackingCode,
        status: status,
        customerName: customerName.isEmpty
            ? existing?.customerName ?? ''
            : customerName,
        customerPhone: existing?.customerPhone,
        labelName: existing?.labelName,
        note: note ?? existing?.note,
        updatedAt: now,
        queued: true,
      ),
    );
  }

  Future<void> pushPending(ApiClient apiClient) async {
    final pending = await _database.pendingOperations();
    if (pending.isEmpty) {
      return;
    }
    final operations = pending
        .map(
          (operation) => {
            'clientMutationId': operation.clientMutationId,
            'type': operation.type,
            'deviceId': operation.deviceId,
            'happenedAt': operation.happenedAt.toIso8601String(),
            'payload': jsonDecode(operation.payloadJson),
          },
        )
        .toList();
    try {
      await apiClient.syncPush(operations);
      await _database.markSyncedAll(
        pending.map((operation) => operation.clientMutationId),
      );
    } catch (error) {
      await _database.markFailedAll(
        pending.map((operation) => operation.clientMutationId),
        error,
      );
      rethrow;
    }
  }

  String fallbackTrackingCode(DateTime now) {
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final suffix = now.microsecondsSinceEpoch
        .toString()
        .substring(10)
        .padLeft(4, '0');
    return 'PTS-TH-$date-$suffix';
  }
}
