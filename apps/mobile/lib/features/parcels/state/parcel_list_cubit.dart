import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/models/parcel_status.dart';
import '../../../core/repositories/parcel_repository.dart';
import 'parcel_list_state.dart';

class ParcelListCubit extends Cubit<ParcelListState> {
  ParcelListCubit(this._parcelRepository, this._languageCode)
    : super(const ParcelListState());

  final ParcelRepository _parcelRepository;
  final String _languageCode;

  Future<void> search({String? query, ParcelStatus? status}) async {
    emit(state.copyWith(loading: true, error: null, filterStatus: status));
    try {
      final parcels = await _parcelRepository.search(
        query: query,
        status: status,
      );
      emit(state.copyWith(loading: false, parcels: parcels));
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          error: t(_languageCode, 'ค้นหาไม่ได้', 'ຄົ້ນຫາບໍ່ໄດ້'),
        ),
      );
    }
  }
}
