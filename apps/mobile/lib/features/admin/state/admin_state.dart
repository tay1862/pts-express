import '../../../core/models/parcel_models.dart';
import '../../../core/repositories/offline_queue_repository.dart';

class AdminState {
  static const Object _unset = Object();

  const AdminState({
    this.loading = false,
    this.users = const [],
    this.queueLoading = false,
    this.queueEntries = const [],
    this.error,
    this.queueError,
  });

  final bool loading;
  final List<AdminUser> users;
  final bool queueLoading;
  final List<SyncQueueEntry> queueEntries;
  final String? error;
  final String? queueError;

  AdminState copyWith({
    bool? loading,
    List<AdminUser>? users,
    bool? queueLoading,
    List<SyncQueueEntry>? queueEntries,
    Object? error = _unset,
    Object? queueError = _unset,
  }) {
    return AdminState(
      loading: loading ?? this.loading,
      users: users ?? this.users,
      queueLoading: queueLoading ?? this.queueLoading,
      queueEntries: queueEntries ?? this.queueEntries,
      error: error == _unset ? this.error : error as String?,
      queueError: queueError == _unset
          ? this.queueError
          : queueError as String?,
    );
  }
}
