import 'package:flutter/material.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'core/db/app_database.dart';
import 'core/repositories/offline_queue_repository.dart';
import 'core/repositories/parcel_repository.dart';
import 'core/repositories/session_store.dart';
import 'core/services/auto_sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  final sessionStore = SessionStore();
  final apiClient = ApiClient(sessionStore);
  final offlineQueue = OfflineQueueRepository(database);
  final parcelRepository = ParcelRepository(
    apiClient: apiClient,
    database: database,
    offlineQueue: offlineQueue,
  );
  final autoSync = AutoSyncService(
    parcelRepository: parcelRepository,
    offlineQueue: offlineQueue,
  );

  runApp(
    PtsApp(
      sessionStore: sessionStore,
      apiClient: apiClient,
      parcelRepository: parcelRepository,
      offlineQueue: offlineQueue,
      autoSync: autoSync,
    ),
  );
}
