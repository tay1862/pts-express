import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_client.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/models/parcel_models.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._apiClient, this._languageCode) : super(const LoginState());

  final ApiClient _apiClient;
  final String _languageCode;

  void setRememberMe(bool value) {
    emit(state.copyWith(rememberMe: value));
  }

  Future<UserSession?> login({
    required String username,
    required String password,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final session = await _apiClient.login(
        username: username.trim(),
        password: password,
        rememberMe: state.rememberMe,
      );
      emit(state.copyWith(loading: false));
      return session;
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          error: t(
            _languageCode,
            'เข้าสู่ระบบไม่สำเร็จ',
            'ເຂົ້າລະບົບບໍ່ສຳເລັດ',
          ),
        ),
      );
      return null;
    }
  }
}
