import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/parcel_models.dart';

part 'public_tracking_state.freezed.dart';

@freezed
abstract class PublicTrackingState with _$PublicTrackingState {
  const factory PublicTrackingState({
    @Default(false) bool loading,
    TrackResult? result,
    String? error,
  }) = _PublicTrackingState;
}
