import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../api/api_client.dart';
import '../db/app_database.dart';
import '../models/evidence_attachment.dart';
import '../models/parcel_models.dart';
import '../models/parcel_status.dart';
import 'offline_queue_repository.dart';

class ParcelWriteResult {
  const ParcelWriteResult({required this.parcel, required this.queued});

  final ParcelSummary parcel;
  final bool queued;
}

class ParcelRepository {
  ParcelRepository({
    required ApiClient apiClient,
    required AppDatabase database,
    required OfflineQueueRepository offlineQueue,
  }) : _apiClient = apiClient,
       _database = database,
       _offlineQueue = offlineQueue;

  final ApiClient _apiClient;
  final AppDatabase _database;
  final OfflineQueueRepository _offlineQueue;
  final Uuid _uuid = const Uuid();

  Future<List<ParcelSummary>> search({
    String? query,
    ParcelStatus? status,
  }) async {
    try {
      final remote = await _apiClient.searchParcels(
        query: query,
        status: status,
      );
      for (final parcel in remote) {
        await _database.upsertLocalParcel(parcel);
      }
      return remote;
    } on DioException {
      final local = await _database.allLocalParcels();
      final q = query?.toLowerCase();
      return local.where((parcel) {
        final matchesStatus = status == null || parcel.status == status;
        final matchesQuery =
            q == null ||
            q.isEmpty ||
            parcel.trackingCode.toLowerCase().contains(q) ||
            parcel.customerName.toLowerCase().contains(q) ||
            (parcel.customerPhone?.toLowerCase().contains(q) ?? false);
        return matchesStatus && matchesQuery;
      }).toList();
    }
  }

  Future<ParcelWriteResult> receive({
    required String trackingCode,
    required String customerName,
    required String? customerPhone,
    required String? labelName,
    required String? secondaryCode,
    required String? note,
    required List<EvidenceAttachment> attachments,
    required String deviceId,
  }) async {
    final payload = {
      'trackingCode': trackingCode,
      'customerName': customerName,
      if (customerPhone?.isNotEmpty == true) 'customerPhone': customerPhone,
      if (labelName?.isNotEmpty == true) 'labelName': labelName,
      if (note?.isNotEmpty == true) 'note': note,
      'clientMutationId': _uuid.v4(),
      'deviceId': deviceId,
      'happenedAt': DateTime.now().toIso8601String(),
      if (attachments.isNotEmpty)
        'attachments': attachments
            .map((attachment) => attachment.toJson())
            .toList(),
      'rawCodes': [
        {'rawCode': trackingCode, 'kind': 'MANUAL', 'isPrimary': true},
        if (secondaryCode?.isNotEmpty == true)
          {'rawCode': secondaryCode, 'kind': 'QR', 'isPrimary': false},
      ],
    };
    try {
      final parcel = await _apiClient.receive(payload);
      await _database.upsertLocalParcel(parcel);
      return ParcelWriteResult(parcel: parcel, queued: false);
    } on DioException {
      final code = await _offlineQueue.enqueueReceive(
        trackingCode: trackingCode,
        customerName: customerName,
        customerPhone: customerPhone,
        labelName: labelName,
        secondaryCode: secondaryCode,
        note: note,
        attachments: attachments,
        deviceId: deviceId,
      );
      final parcel = (await _database.findLocalParcel(code))!;
      return ParcelWriteResult(parcel: parcel, queued: true);
    }
  }

  Future<ParcelWriteResult> advance({
    required ScanMode mode,
    required String trackingCode,
    required String customerName,
    required String? note,
    required List<EvidenceAttachment> attachments,
    required String deviceId,
  }) async {
    final targetStatus = mode == ScanMode.arrive
        ? ParcelStatus.arrivedInLaos
        : ParcelStatus.pickedUp;
    final payload = {
      if (customerName.isNotEmpty) 'customerName': customerName,
      if (note?.isNotEmpty == true) 'note': note,
      'clientMutationId': _uuid.v4(),
      'deviceId': deviceId,
      'happenedAt': DateTime.now().toIso8601String(),
      if (attachments.isNotEmpty)
        'attachments': attachments
            .map((attachment) => attachment.toJson())
            .toList(),
    };
    try {
      final parcel = mode == ScanMode.arrive
          ? await _apiClient.arrive(trackingCode, payload)
          : await _apiClient.pickup(trackingCode, payload);
      await _database.upsertLocalParcel(parcel);
      return ParcelWriteResult(parcel: parcel, queued: false);
    } on DioException catch (error) {
      final responseMessage = error.response?.data is Map<String, dynamic>
          ? (error.response!.data as Map<String, dynamic>)['message'].toString()
          : '';
      if (responseMessage.contains('customerName') &&
          customerName.trim().isEmpty) {
        throw MissingCustomerNameException(trackingCode);
      }
      final local = await _database.findLocalParcel(trackingCode);
      if (local == null &&
          customerName.trim().isEmpty &&
          error.type != DioExceptionType.connectionError) {
        rethrow;
      }
      if (local == null && customerName.trim().isEmpty) {
        throw MissingCustomerNameException(trackingCode);
      }
      await _offlineQueue.enqueueStatus(
        trackingCode: trackingCode,
        status: targetStatus,
        customerName: customerName.trim().isEmpty
            ? local?.customerName ?? ''
            : customerName,
        note: note,
        attachments: attachments,
        deviceId: deviceId,
      );
      final parcel = (await _database.findLocalParcel(trackingCode))!;
      return ParcelWriteResult(parcel: parcel, queued: true);
    }
  }

  Future<void> syncPending() => _offlineQueue.pushPending(_apiClient);
}

class MissingCustomerNameException implements Exception {
  const MissingCustomerNameException(this.trackingCode);

  final String trackingCode;
}
