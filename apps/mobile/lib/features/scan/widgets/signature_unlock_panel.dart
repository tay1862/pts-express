import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/models/evidence_attachment.dart';

class SignatureUnlockPanel extends StatefulWidget {
  const SignatureUnlockPanel({
    super.key,
    required this.languageCode,
    required this.onChanged,
  });

  final String languageCode;
  final ValueChanged<EvidenceAttachment?> onChanged;

  @override
  State<SignatureUnlockPanel> createState() => SignatureUnlockPanelState();
}

class SignatureUnlockPanelState extends State<SignatureUnlockPanel> {
  late final SignatureController controller;
  bool unlocked = false;
  bool saved = false;

  @override
  void initState() {
    super.initState();
    controller = SignatureController(
      penStrokeWidth: 3,
      penColor: const Color(0xff123f2c),
      exportBackgroundColor: Colors.white,
    );
    controller.addListener(updateSavedState);
  }

  @override
  void dispose() {
    controller.removeListener(updateSavedState);
    controller.dispose();
    super.dispose();
  }

  void updateSavedState() {
    if (saved && controller.isEmpty) {
      setState(() => saved = false);
      widget.onChanged(null);
    }
  }

  Future<void> saveSignature() async {
    if (controller.isEmpty) {
      widget.onChanged(null);
      setState(() => saved = false);
      return;
    }
    final bytes = await controller.toPngBytes();
    if (bytes == null) {
      return;
    }
    final now = DateTime.now();
    widget.onChanged(
      EvidenceAttachment(
        type: EvidenceAttachmentType.signature,
        fileName: 'pts-signature-${now.millisecondsSinceEpoch}.png',
        contentType: 'image/png',
        bytes: bytes,
        capturedAt: now,
        note: t(widget.languageCode, 'ลายเซ็นผู้รับ', 'ລາຍເຊັນຜູ້ຮັບ'),
      ),
    );
    setState(() => saved = true);
  }

  void clearSignature() {
    controller.clear();
    widget.onChanged(null);
    setState(() => saved = false);
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.languageCode;
    if (!unlocked) {
      return OutlinedButton.icon(
        key: const ValueKey('signature_unlock_button'),
        onPressed: () => setState(() => unlocked = true),
        icon: const Icon(Icons.lock_open),
        label: Text(t(strings, 'แตะเพื่อเปิดลายเซ็น', 'ແຕະເພື່ອເປີດລາຍເຊັນ')),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t(strings, 'ลายเซ็นผู้รับ (ตัวเลือก)', 'ລາຍເຊັນຜູ້ຮັບ (ບໍ່ບັງຄັບ)'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Signature(
              key: const ValueKey('recipient_signature_pad'),
              controller: controller,
              height: 180,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              key: const ValueKey('signature_save_button'),
              onPressed: saveSignature,
              icon: Icon(saved ? Icons.check_circle : Icons.draw),
              label: Text(t(strings, 'ใช้ลายเซ็นนี้', 'ໃຊ້ລາຍເຊັນນີ້')),
            ),
            OutlinedButton.icon(
              key: const ValueKey('signature_clear_button'),
              onPressed: clearSignature,
              icon: const Icon(Icons.backspace_outlined),
              label: Text(t(strings, 'ล้าง', 'ລ້າງ')),
            ),
            TextButton.icon(
              onPressed: () => setState(() => unlocked = false),
              icon: const Icon(Icons.lock),
              label: Text(t(strings, 'ล็อก', 'ລັອກ')),
            ),
          ],
        ),
      ],
    );
  }
}
