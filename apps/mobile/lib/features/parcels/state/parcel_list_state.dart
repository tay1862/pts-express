import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/parcel_models.dart';
import '../../../core/models/parcel_status.dart';

part 'parcel_list_state.freezed.dart';

@freezed
abstract class ParcelListState with _$ParcelListState {
  const factory ParcelListState({
    @Default(false) bool loading,
    @Default([]) List<ParcelSummary> parcels,
    ParcelStatus? filterStatus,
    String? error,
  }) = _ParcelListState;
}
