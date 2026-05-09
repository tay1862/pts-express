import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/parcel_models.dart';

part 'admin_state.freezed.dart';

@freezed
abstract class AdminState with _$AdminState {
  const factory AdminState({
    @Default(false) bool loading,
    @Default([]) List<AdminUser> users,
    String? error,
  }) = _AdminState;
}
