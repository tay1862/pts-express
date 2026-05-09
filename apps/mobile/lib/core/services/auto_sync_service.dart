import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../repositories/offline_queue_repository.dart';
import '../repositories/parcel_repository.dart';

class AutoSyncService {
  AutoSyncService({
    required ParcelRepository parcelRepository,
    required OfflineQueueRepository offlineQueue,
    Connectivity? connectivity,
  }) : _parcelRepository = parcelRepository,
       _offlineQueue = offlineQueue,
       _connectivity = connectivity ?? Connectivity();

  final ParcelRepository _parcelRepository;
  final OfflineQueueRepository _offlineQueue;
  final Connectivity _connectivity;
  final StreamController<int> _pendingCountController =
      StreamController<int>.broadcast();
  static const retryDelay = Duration(seconds: 5);

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _scheduledSync;
  bool _enabled = false;
  bool _syncing = false;
  bool _disposed = false;

  Stream<int> get pendingCountChanged => _pendingCountController.stream;

  void start() {
    _connectivitySubscription ??= _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      if (_hasNetwork(results)) {
        scheduleSync(delay: const Duration(milliseconds: 500));
      }
    });
  }

  void setEnabled(bool value) {
    _enabled = value;
    if (value) {
      scheduleSync();
    } else {
      _scheduledSync?.cancel();
    }
  }

  Future<int> pendingCount() => _offlineQueue.pendingCount();

  void scheduleSync({Duration delay = Duration.zero}) {
    if (!_enabled || _disposed) {
      return;
    }
    _scheduledSync?.cancel();
    _scheduledSync = Timer(delay, () => unawaited(syncIfNeeded()));
  }

  Future<void> syncIfNeeded({bool throwOnError = false}) async {
    if (!_enabled || _syncing || _disposed) {
      return;
    }

    final beforeCount = await _offlineQueue.pendingCount();
    _emitPendingCount(beforeCount);
    if (beforeCount == 0) {
      return;
    }

    _syncing = true;
    try {
      await _parcelRepository.syncPending();
    } catch (error) {
      // Auto sync must stay silent. The manual sync button still reports errors.
      _scheduleRetryIfPending(beforeCount);
      if (throwOnError) {
        rethrow;
      }
    } finally {
      _syncing = false;
      final afterCount = await _offlineQueue.pendingCount();
      _emitPendingCount(afterCount);
      _scheduleRetryIfPending(afterCount);
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    _scheduledSync?.cancel();
    await _connectivitySubscription?.cancel();
    await _pendingCountController.close();
  }

  bool _hasNetwork(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }

  void _emitPendingCount(int count) {
    if (!_pendingCountController.isClosed) {
      _pendingCountController.add(count);
    }
  }

  void _scheduleRetryIfPending(int pendingCount) {
    if (pendingCount > 0 && !_disposed && _enabled) {
      scheduleSync(delay: retryDelay);
    }
  }
}
