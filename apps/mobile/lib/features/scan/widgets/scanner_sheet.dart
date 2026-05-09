import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerSheet extends StatefulWidget {
  const ScannerSheet({super.key});

  @override
  State<ScannerSheet> createState() => ScannerSheetState();
}

class ScannerSheetState extends State<ScannerSheet> {
  late final MobileScannerController controller;
  bool detected = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      autoZoom: true,
      formats: const [
        BarcodeFormat.qrCode,
        BarcodeFormat.code128,
        BarcodeFormat.code39,
        BarcodeFormat.code93,
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.itf14,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
        BarcodeFormat.codabar,
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.78,
      child: Column(
        children: [
          const ScannerSheetHandle(),
          Expanded(
            child: MobileScanner(
              controller: controller,
              fit: BoxFit.cover,
              onDetect: (capture) {
                if (detected) {
                  return;
                }
                final rawValue = capture.barcodes
                    .map((barcode) => barcode.rawValue)
                    .whereType<String>()
                    .where((value) => value.trim().isNotEmpty)
                    .firstOrNull;
                if (rawValue != null && Navigator.of(context).canPop()) {
                  detected = true;
                  Navigator.of(context).pop(rawValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerSheetHandle extends StatelessWidget {
  const ScannerSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        width: 52,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outline,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}
