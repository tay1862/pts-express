import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_client.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/repositories/offline_queue_repository.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit(this._apiClient, this._offlineQueue, this._languageCode)
    : super(const AdminState());

  final ApiClient _apiClient;
  final OfflineQueueRepository _offlineQueue;
  final String _languageCode;

  Future<void> loadUsers() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      emit(state.copyWith(loading: false, users: await _apiClient.users()));
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          error: t(_languageCode, 'โหลดผู้ใช้ไม่ได้', 'ໂຫຼດຜູ້ໃຊ້ບໍ່ໄດ້'),
        ),
      );
    }
  }

  Future<void> loadQueue() async {
    emit(state.copyWith(queueLoading: true, queueError: null));
    try {
      emit(
        state.copyWith(
          queueLoading: false,
          queueEntries: await _offlineQueue.pendingEntries(),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          queueLoading: false,
          queueError: t(_languageCode, 'โหลดคิวไม่ได้', 'ໂຫຼດຄິວບໍ່ໄດ້'),
        ),
      );
    }
  }

  Future<void> createUser({
    required String username,
    required String password,
    required String displayName,
    required String role,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _apiClient.createUser({
        'username': username.trim(),
        'password': password,
        'displayName': displayName.trim(),
        'role': role,
      });
      await loadUsers();
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          error: t(_languageCode, 'สร้างผู้ใช้ไม่ได้', 'ສ້າງຜູ້ໃຊ້ບໍ່ໄດ້'),
        ),
      );
    }
  }

  Future<void> updateUser({
    required String userId,
    required String displayName,
    required String role,
    required bool isActive,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _apiClient.updateUser(userId, {
        'displayName': displayName.trim(),
        'role': role,
        'isActive': isActive,
      });
      await loadUsers();
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          error: t(_languageCode, 'อัปเดตผู้ใช้ไม่ได้', 'ອັບເດດຜູ້ໃຊ້ບໍ່ໄດ້'),
        ),
      );
    }
  }

  Future<void> resetPassword({
    required String userId,
    required String password,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _apiClient.resetUserPassword(userId, password);
      await loadUsers();
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          error: t(
            _languageCode,
            'รีเซ็ตรหัสผ่านไม่ได้',
            'ຣີເຊັດລະຫັດຜ່ານບໍ່ໄດ້',
          ),
        ),
      );
    }
  }

  Future<void> deleteUser(String userId) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _apiClient.deleteUser(userId);
      await loadUsers();
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          error: t(_languageCode, 'ลบผู้ใช้ไม่ได้', 'ລຶບຜູ້ໃຊ້ບໍ່ໄດ້'),
        ),
      );
    }
  }

  Future<void> retryQueue() async {
    emit(state.copyWith(queueLoading: true, queueError: null));
    try {
      await _offlineQueue.pushPending(_apiClient);
      await loadQueue();
    } catch (error) {
      emit(
        state.copyWith(
          queueLoading: false,
          queueError: t(
            _languageCode,
            'ลองซิงก์ใหม่ไม่ได้',
            'ລອງຊິງຄ໌ໃໝ່ບໍ່ໄດ້',
          ),
        ),
      );
    }
  }
}
