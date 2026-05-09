import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/models/evidence_attachment.dart';
import '../../core/models/parcel_status.dart';
import '../../core/repositories/offline_queue_repository.dart';
import '../../core/repositories/parcel_repository.dart';
import '../../core/services/auto_sync_service.dart';
import 'state/scan_cubit.dart';
import 'state/scan_state.dart';
import 'widgets/mode_selector.dart';
import 'widgets/evidence_camera_sheet.dart';
import 'widgets/scan_feedback.dart';
import 'widgets/scanner_sheet.dart';
import 'widgets/signature_unlock_panel.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key, required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScanCubit(
        parcelRepository: context.read<ParcelRepository>(),
        offlineQueue: context.read<OfflineQueueRepository>(),
        autoSync: context.read<AutoSyncService>(),
        languageCode: languageCode,
      ),
      child: ScanWorkspace(languageCode: languageCode),
    );
  }
}

class ScanWorkspace extends StatefulWidget {
  const ScanWorkspace({super.key, required this.languageCode});

  final String languageCode;

  @override
  State<ScanWorkspace> createState() => ScanWorkspaceState();
}

class ScanWorkspaceState extends State<ScanWorkspace> {
  final trackingController = TextEditingController();
  final customerNameController = TextEditingController();
  final noteController = TextEditingController();
  final photoAttachments = <EvidenceAttachment>[];
  EvidenceAttachment? signatureAttachment;

  @override
  void dispose() {
    trackingController.dispose();
    customerNameController.dispose();
    noteController.dispose();
    super.dispose();
  }

  List<EvidenceAttachment> attachmentsForMode(ScanMode mode) => [
    ...photoAttachments,
    if (mode == ScanMode.pickup && signatureAttachment != null)
      signatureAttachment!,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScanCubit, ScanState>(
      listener: (context, state) {
        if (state.submissionStatus == ScanSubmissionStatus.success) {
          trackingController.clear();
          customerNameController.clear();
          noteController.clear();
          setState(() {
            photoAttachments.clear();
            signatureAttachment = null;
          });
        }
      },
      builder: (context, state) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ScanHeader(
            languageCode: widget.languageCode,
            pendingCount: state.pendingCount,
          ),
          const SizedBox(height: 16),
          ModeSelector(languageCode: widget.languageCode),
          const SizedBox(height: 16),
          TrackingInputRow(
            languageCode: widget.languageCode,
            controller: trackingController,
            onScanPressed: () => openScanner(context),
          ),
          const SizedBox(height: 12),
          if (state.mode == ScanMode.receive)
            ReceiveFields(
              customerNameController: customerNameController,
              languageCode: widget.languageCode,
            )
          else
            CustomerNameForMissingField(
              controller: customerNameController,
              languageCode: widget.languageCode,
            ),
          const SizedBox(height: 12),
          EvidenceControls(
            languageCode: widget.languageCode,
            photoCount: photoAttachments.length,
            hasSignature:
                state.mode == ScanMode.pickup && signatureAttachment != null,
            showSignature: state.mode == ScanMode.pickup,
            onCameraPressed: () => openCamera(context, state.mode),
            onClearPhotos: () => setState(photoAttachments.clear),
            onSignatureChanged: (signature) =>
                setState(() => signatureAttachment = signature),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('parcel_note_field'),
            controller: noteController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: t(widget.languageCode, 'หมายเหตุ', 'ໝາຍເຫດ'),
            ),
          ),
          const SizedBox(height: 16),
          ScanPrimaryButton(
            state: state,
            languageCode: widget.languageCode,
            onPressed: () => submit(context, state),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const ValueKey('sync_now_button'),
            onPressed: state.submissionStatus == ScanSubmissionStatus.loading
                ? null
                : () => context.read<ScanCubit>().syncNow(),
            icon: const Icon(Icons.sync),
            label: Text(t(widget.languageCode, 'ซิงก์ข้อมูล', 'ຊິງຂໍ້ມູນ')),
          ),
          const SizedBox(height: 16),
          ScanFeedback(languageCode: widget.languageCode),
        ],
      ),
    );
  }

  Future<void> openScanner(BuildContext context) async {
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ScannerSheet(),
    );
    if (code != null && mounted) {
      trackingController.text = code;
      trackingController.selection = TextSelection.collapsed(
        offset: code.length,
      );
    }
  }

  Future<void> submit(BuildContext context, ScanState state) async {
    if (state.mode == ScanMode.receive) {
      await context.read<ScanCubit>().submitReceive(
        trackingCode: trackingController.text,
        customerName: customerNameController.text,
        customerPhone: null,
        labelName: null,
        secondaryCode: null,
        note: noteController.text,
        attachments: attachmentsForMode(state.mode),
      );
      return;
    }
    await context.read<ScanCubit>().submitStatus(
      trackingCode: trackingController.text,
      customerName: customerNameController.text,
      note: noteController.text,
      attachments: attachmentsForMode(state.mode),
    );
  }

  Future<void> openCamera(BuildContext context, ScanMode mode) async {
    final attachment = await showModalBottomSheet<EvidenceAttachment>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EvidenceCameraSheet(
        languageCode: widget.languageCode,
        mode: mode,
        trackingCode: trackingController.text,
      ),
    );
    if (attachment != null && mounted) {
      setState(() => photoAttachments.add(attachment));
    }
  }
}

class ScanHeader extends StatelessWidget {
  const ScanHeader({
    super.key,
    required this.languageCode,
    required this.pendingCount,
  });

  final String languageCode;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(languageCode, 'สแกน', 'ສະແກນ'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                languageCode == 'lo'
                    ? 'ຄິວລໍຖ້າຊິງຂໍ້ມູນ: $pendingCount'
                    : 'รอซิงก์ข้อมูล: $pendingCount',
              ),
            ],
          ),
        ),
        Icon(Icons.warehouse, color: Theme.of(context).colorScheme.primary),
      ],
    );
  }
}

class TrackingInputRow extends StatelessWidget {
  const TrackingInputRow({
    super.key,
    required this.languageCode,
    required this.controller,
    required this.onScanPressed,
  });

  final String languageCode;
  final TextEditingController controller;
  final VoidCallback onScanPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const ValueKey('tracking_code_field'),
            controller: controller,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: t(
                languageCode,
                'เลขพัสดุ / Barcode / QR',
                'ເລກພັດສະດຸ / Barcode / QR',
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox.square(
          dimension: 56,
          child: IconButton.filled(
            key: const ValueKey('barcode_scan_button'),
            tooltip: t(languageCode, 'สแกน', 'ສະແກນ'),
            onPressed: onScanPressed,
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ),
      ],
    );
  }
}

class ReceiveFields extends StatelessWidget {
  const ReceiveFields({
    super.key,
    required this.customerNameController,
    required this.languageCode,
  });

  final TextEditingController customerNameController;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const ValueKey('customer_name_field'),
      controller: customerNameController,
      decoration: InputDecoration(
        labelText: t(languageCode, 'ชื่อลูกค้า', 'ຊື່ລູກຄ້າ'),
      ),
    );
  }
}

class EvidenceControls extends StatelessWidget {
  const EvidenceControls({
    super.key,
    required this.languageCode,
    required this.photoCount,
    required this.hasSignature,
    required this.showSignature,
    required this.onCameraPressed,
    required this.onClearPhotos,
    required this.onSignatureChanged,
  });

  final String languageCode;
  final int photoCount;
  final bool hasSignature;
  final bool showSignature;
  final VoidCallback onCameraPressed;
  final VoidCallback onClearPhotos;
  final ValueChanged<EvidenceAttachment?> onSignatureChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const ValueKey('photo_capture_button'),
                onPressed: onCameraPressed,
                icon: const Icon(Icons.camera_alt),
                label: Text(t(languageCode, 'ถ่ายรูป', 'ຖ່າຍຮູບ')),
              ),
            ),
            if (photoCount > 0) ...[
              const SizedBox(width: 8),
              IconButton.outlined(
                key: const ValueKey('photo_clear_button'),
                tooltip: t(languageCode, 'ล้างรูป', 'ລ້າງຮູບ'),
                onPressed: onClearPhotos,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ],
        ),
        if (photoCount > 0 || hasSignature) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (photoCount > 0)
                Chip(
                  avatar: const Icon(Icons.photo_camera, size: 18),
                  label: Text(
                    languageCode == 'lo'
                        ? 'ຮູບຖ່າຍ $photoCount'
                        : 'รูปถ่าย $photoCount',
                  ),
                ),
              if (hasSignature)
                Chip(
                  avatar: const Icon(Icons.draw, size: 18),
                  label: Text(t(languageCode, 'มีลายเซ็น', 'ມີລາຍເຊັນ')),
                ),
            ],
          ),
        ],
        if (showSignature) ...[
          const SizedBox(height: 12),
          SignatureUnlockPanel(
            languageCode: languageCode,
            onChanged: onSignatureChanged,
          ),
        ],
      ],
    );
  }
}

class CustomerNameForMissingField extends StatelessWidget {
  const CustomerNameForMissingField({
    super.key,
    required this.controller,
    required this.languageCode,
  });

  final TextEditingController controller;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const ValueKey('missing_customer_name_field'),
      controller: controller,
      decoration: InputDecoration(
        labelText: t(languageCode, 'ชื่อลูกค้า', 'ຊື່ລູກຄ້າ'),
      ),
    );
  }
}

class ScanPrimaryButton extends StatelessWidget {
  const ScanPrimaryButton({
    super.key,
    required this.state,
    required this.languageCode,
    required this.onPressed,
  });

  final ScanState state;
  final String languageCode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = switch (state.mode) {
      ScanMode.receive => t(languageCode, 'บันทึกรับไทย', 'ບັນທຶກຮັບທີ່ໄທ'),
      ScanMode.arrive => t(languageCode, 'ถึงลาว', 'ຮອດລາວ'),
      ScanMode.pickup => t(languageCode, 'ส่งมอบ', 'ສົ່ງມອບ'),
    };
    return FilledButton.icon(
      key: const ValueKey('scan_submit_button'),
      onPressed: state.submissionStatus == ScanSubmissionStatus.loading
          ? null
          : onPressed,
      icon: state.submissionStatus == ScanSubmissionStatus.loading
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.check_circle),
      label: Text(label),
    );
  }
}
