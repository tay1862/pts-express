import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default(false) bool loading,
    @Default(false) bool rememberMe,
    String? error,
  }) = _LoginState;
}
