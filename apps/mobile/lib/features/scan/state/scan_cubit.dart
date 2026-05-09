import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/models/evidence_attachment.dart';
import '../../../core/models/parcel_status.dart';
import '../../../core/repositories/offline_queue_repository.dart';
import '../../../core/repositories/parcel_repository.dart';
import '../../../core/services/auto_sync_service.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  ScanCubit({
    required ParcelRepository parcelRepository,
    required OfflineQueueRepository offlineQueue,
    required AutoSyncService autoSync,
    required String languageCode,
  }) : _parcelRepository = parcelRepository,
       _offlineQueue = offlineQueue,
       _autoSync = autoSync,
       _languageCode = languageCode,
       super(const ScanState()) {
    _pendingCountSubscription = _autoSync.pendingCountChanged.listen((count) {
      if (!isClosed) {
        emit(state.copyWith(pendingCount: count));
      }
    });
    refreshPendingCount();
  }

  final ParcelRepository _parcelRepository;
  final OfflineQueueRepository _offlineQueue;
  final AutoSyncService _autoSync;
  final String _languageCode;
  final String deviceId = const Uuid().v4();
  late final StreamSubscription<int> _pendingCountSubscription;

  @override
  Future<void> close() async {
    await _pendingCountSubscription.cancel();
    return super.close();
  }

  void setMode(ScanMode mode) {
    emit(
      state.copyWith(
        mode: mode,
        submissionStatus: ScanSubmissionStatus.idle,
        message: null,
      ),
    );
  }

  Future<void> refreshPendingCount() async {
    emit(state.copyWith(pendingCount: await _offlineQueue.pendingCount()));
  }

  Future<void> syncNow() async {
    emit(
      state.copyWith(
        submissionStatus: ScanSubmissionStatus.loading,
        message: null,
      ),
    );
    try {
      await _autoSync.syncIfNeeded(throwOnError: true);
      emit(
        state.copyWith(
          submissionStatus: ScanSubmissionStatus.success,
          message: t(_languageCode, 'ซิงก์ข้อมูลเสร็จแล้ว', 'ຊິງຂໍ້ມູນສຳເລັດ'),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          submissionStatus: ScanSubmissionStatus.error,
          message: t(
            _languageCode,
            'ซิงก์ข้อมูลไม่สำเร็จ',
            'ຊິງຂໍ້ມູນບໍ່ສຳເລັດ',
          ),
        ),
      );
    }
    await refreshPendingCount();
  }

  Future<void> submitReceive({
    required String trackingCode,
    required String customerName,
    required String? customerPhone,
    required String? labelName,
    required String? secondaryCode,
    required String? note,
    required List<EvidenceAttachment> attachments,
  }) async {
    if (customerName.trim().isEmpty) {
      emit(
        state.copyWith(
          submissionStatus: ScanSubmissionStatus.error,
          message: t(_languageCode, 'ต้องใส่ชื่อลูกค้า', 'ຕ້ອງໃສ່ຊື່ລູກຄ້າ'),
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        submissionStatus: ScanSubmissionStatus.loading,
        message: null,
      ),
    );
    final result = await _parcelRepository.receive(
      trackingCode: trackingCode,
      customerName: customerName.trim(),
      customerPhone: customerPhone?.trim(),
      labelName: labelName?.trim(),
      secondaryCode: secondaryCode?.trim(),
      note: note?.trim(),
      attachments: attachments,
      deviceId: deviceId,
    );
    emit(
      state.copyWith(
        submissionStatus: ScanSubmissionStatus.success,
        lastQueued: result.queued,
        lastParcel: result.parcel,
        message: result.queued
            ? t(
                _languageCode,
                'บันทึกในเครื่อง รอซิงก์',
                'ບັນທຶກໃນເຄື່ອງ ລໍຖ້າຊິງ',
              )
            : t(_languageCode, 'บันทึกแล้ว', 'ບັນທຶກແລ້ວ'),
      ),
    );
    await refreshPendingCount();
    _syncInBackground();
  }

  Future<void> submitStatus({
    required String trackingCode,
    required String customerName,
    required String? note,
    required List<EvidenceAttachment> attachments,
  }) async {
    if (trackingCode.trim().isEmpty) {
      emit(
        state.copyWith(
          submissionStatus: ScanSubmissionStatus.error,
          message: t(_languageCode, 'ต้องมีเลขพัสดุ', 'ຕ້ອງມີເລກພັດສະດຸ'),
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        submissionStatus: ScanSubmissionStatus.loading,
        message: null,
      ),
    );
    try {
      final result = await _parcelRepository.advance(
        mode: state.mode,
        trackingCode: trackingCode.trim(),
        customerName: customerName.trim(),
        note: note?.trim(),
        attachments: attachments,
        deviceId: deviceId,
      );
      emit(
        state.copyWith(
          submissionStatus: ScanSubmissionStatus.success,
          lastQueued: result.queued,
          lastParcel: result.parcel,
          message: result.queued
              ? t(
                  _languageCode,
                  'บันทึกในเครื่อง รอซิงก์',
                  'ບັນທຶກໃນເຄື່ອງ ລໍຖ້າຊິງ',
                )
              : t(_languageCode, 'อัปเดตสถานะแล้ว', 'ອັບເດດສະຖານະແລ້ວ'),
          missingTrackingCode: null,
        ),
      );
      _syncInBackground();
    } on MissingCustomerNameException catch (error) {
      emit(
        state.copyWith(
          submissionStatus: ScanSubmissionStatus.needsCustomerName,
          missingTrackingCode: error.trackingCode,
          message: t(
            _languageCode,
            'ต้องใส่ชื่อสำหรับเลขที่ยังไม่พบ',
            'ຕ້ອງໃສ່ຊື່ສຳລັບເລກທີ່ຍັງບໍ່ພົບ',
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          submissionStatus: ScanSubmissionStatus.error,
          message: t(_languageCode, 'อัปเดตไม่ได้', 'ອັບເດດບໍ່ໄດ້'),
        ),
      );
    }
    await refreshPendingCount();
  }

  void _syncInBackground() {
    unawaited(
      _autoSync.syncIfNeeded().whenComplete(() async {
        if (!isClosed) {
          await refreshPendingCount();
        }
      }),
    );
  }
}
