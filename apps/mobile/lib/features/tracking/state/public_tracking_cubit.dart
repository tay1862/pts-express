import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_client.dart';
import '../../../core/i18n/app_strings.dart';
import 'public_tracking_state.dart';

class PublicTrackingCubit extends Cubit<PublicTrackingState> {
  PublicTrackingCubit(this._apiClient, this._languageCode)
    : super(const PublicTrackingState());

  final ApiClient _apiClient;
  final String _languageCode;

  Future<void> track(String trackingCode) async {
    if (trackingCode.trim().isEmpty) {
      emit(
        state.copyWith(
          error: t(_languageCode, 'ต้องมีเลขพัสดุ', 'ຕ້ອງມີເລກພັດສະດຸ'),
        ),
      );
      return;
    }
    emit(state.copyWith(loading: true, error: null));
    try {
      final result = await _apiClient.track(trackingCode.trim());
      emit(state.copyWith(loading: false, result: result));
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          error: t(_languageCode, 'ไม่พบสถานะ', 'ບໍ່ພົບສະຖານະ'),
        ),
      );
    }
  }
}
