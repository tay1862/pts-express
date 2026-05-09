import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/parcel_models.dart';
import '../../../core/models/parcel_status.dart';

part 'scan_state.freezed.dart';

enum ScanSubmissionStatus { idle, loading, success, error, needsCustomerName }

@freezed
abstract class ScanState with _$ScanState {
  const factory ScanState({
    @Default(ScanMode.receive) ScanMode mode,
    @Default(ScanSubmissionStatus.idle) ScanSubmissionStatus submissionStatus,
    @Default(0) int pendingCount,
    @Default(false) bool lastQueued,
    String? message,
    String? missingTrackingCode,
    ParcelSummary? lastParcel,
  }) = _ScanState;
}
