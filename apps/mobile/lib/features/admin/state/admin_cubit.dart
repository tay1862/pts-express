import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_client.dart';
import '../../../core/i18n/app_strings.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit(this._apiClient, this._languageCode) : super(const AdminState());

  final ApiClient _apiClient;
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
}
