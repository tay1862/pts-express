import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/parcel_models.dart';
import '../models/parcel_status.dart';

part 'app_database.g.dart';

class LocalParcels extends Table {
  TextColumn get id => text()();
  TextColumn get trackingCode => text().unique()();
  TextColumn get status => text()();
  TextColumn get customerName => text()();
  TextColumn get customerPhone => text().nullable()();
  TextColumn get labelName => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncOperations extends Table {
  TextColumn get clientMutationId => text()();
  TextColumn get type => text()();
  TextColumn get payloadJson => text()();
  TextColumn get deviceId => text()();
  DateTimeColumn get happenedAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {clientMutationId};
}

@DriftDatabase(tables: [LocalParcels, SyncOperations])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
    : super(
        driftDatabase(
          name: 'pts_express',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
          native: const DriftNativeOptions(shareAcrossIsolates: true),
        ),
      );

  @override
  int get schemaVersion => 1;

  Future<List<ParcelSummary>> allLocalParcels() async {
    final rows = await (select(
      localParcels,
    )..orderBy([(row) => OrderingTerm.desc(row.updatedAt)])).get();
    return rows.map(localParcelToSummary).toList();
  }

  Future<ParcelSummary?> findLocalParcel(String trackingCode) async {
    final row =
        await (select(localParcels)
              ..where((parcel) => parcel.trackingCode.equals(trackingCode)))
            .getSingleOrNull();
    return row == null ? null : localParcelToSummary(row);
  }

  Future<void> upsertLocalParcel(ParcelSummary parcel) {
    return into(localParcels).insertOnConflictUpdate(
      LocalParcelsCompanion.insert(
        id: parcel.id,
        trackingCode: parcel.trackingCode,
        status: parcel.status.apiValue,
        customerName: parcel.customerName,
        customerPhone: Value(parcel.customerPhone),
        labelName: Value(parcel.labelName),
        note: Value(parcel.note),
        updatedAt: parcel.updatedAt,
      ),
    );
  }

  Future<void> enqueueOperation({
    required String clientMutationId,
    required String type,
    required String deviceId,
    required DateTime happenedAt,
    required Map<String, dynamic> payload,
  }) {
    return into(syncOperations).insertOnConflictUpdate(
      SyncOperationsCompanion.insert(
        clientMutationId: clientMutationId,
        type: type,
        deviceId: deviceId,
        happenedAt: happenedAt,
        payloadJson: jsonEncode(payload),
      ),
    );
  }

  Future<List<SyncOperation>> pendingOperations() {
    return (select(syncOperations)
          ..where((operation) => operation.synced.equals(false))
          ..orderBy([(operation) => OrderingTerm.asc(operation.happenedAt)]))
        .get();
  }

  Future<void> markSynced(String clientMutationId) {
    return (update(
      syncOperations,
    )..where((row) => row.clientMutationId.equals(clientMutationId))).write(
      const SyncOperationsCompanion(
        synced: Value(true),
        lastError: Value(null),
      ),
    );
  }

  Future<void> markFailed(String clientMutationId, Object error) {
    return (update(
      syncOperations,
    )..where((row) => row.clientMutationId.equals(clientMutationId))).write(
      SyncOperationsCompanion(
        attempts: const Value(0),
        lastError: Value(error.toString()),
      ),
    );
  }
}

ParcelSummary localParcelToSummary(LocalParcel row) => ParcelSummary(
  id: row.id,
  trackingCode: row.trackingCode,
  status: ParcelStatus.fromApi(row.status),
  customerName: row.customerName,
  customerPhone: row.customerPhone,
  labelName: row.labelName,
  note: row.note,
  updatedAt: row.updatedAt,
  queued: true,
);
