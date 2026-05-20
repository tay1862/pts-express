import 'dart:async';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/models/evidence_attachment.dart';
import '../../../core/models/parcel_status.dart';

class EvidenceCameraSheet extends StatefulWidget {
  const EvidenceCameraSheet({
    super.key,
    required this.languageCode,
    required this.mode,
    required this.trackingCode,
  });

  final String languageCode;
  final ScanMode mode;
  final String trackingCode;

  @override
  State<EvidenceCameraSheet> createState() => EvidenceCameraSheetState();
}

class EvidenceCameraSheetState extends State<EvidenceCameraSheet>
    with WidgetsBindingObserver {
  CameraController? controller;
  Position? position;
  String? addressText;
  String? errorText;
  bool initializing = true;
  bool capturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final camera = controller;
    if (camera == null || !camera.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      camera.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initialize();
    }
  }

  Future<void> initialize() async {
    setState(() {
      initializing = true;
      errorText = null;
    });
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final nextController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller?.dispose();
      await nextController.initialize();
      if (!mounted) {
        return;
      }
      setState(() {
        controller = nextController;
        initializing = false;
      });
      unawaited(loadLocation());
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        initializing = false;
        errorText = t(widget.languageCode, 'เปิดกล้องไม่ได้', 'ເປີດກ້ອງບໍ່ໄດ້');
      });
    }
  }

  Future<void> loadLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final nextPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 6),
        ),
      );
      final nextAddress = await reverseGeocode(nextPosition);
      if (!mounted) {
        return;
      }
      setState(() {
        position = nextPosition;
        addressText = nextAddress;
      });
    } catch (_) {
      if (mounted) {
        setState(() => addressText = null);
      }
    }
  }

  Future<String?> reverseGeocode(Position value) async {
    if (kIsWeb) {
      return null;
    }
    try {
      await setLocaleIdentifier('lo_LA');
      final places = await placemarkFromCoordinates(
        value.latitude,
        value.longitude,
      );
      if (places.isEmpty) {
        return null;
      }
      final place = places.first;
      return [
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
      ].where((part) => part != null && part.trim().isNotEmpty).join(', ');
    } catch (_) {
      return null;
    }
  }

  Future<void> capture() async {
    final camera = controller;
    if (camera == null || !camera.value.isInitialized || capturing) {
      return;
    }
    setState(() => capturing = true);
    try {
      final capturedAt = DateTime.now();
      final file = await camera.takePicture();
      final bytes = await file.readAsBytes();
      final watermarked = await EvidenceWatermarker.draw(
        imageBytes: bytes,
        lines: watermarkLines(capturedAt),
      );
      if (watermarked.length > maxEvidenceAttachmentBytes) {
        if (!mounted) {
          return;
        }
        setState(() {
          errorText = t(
            widget.languageCode,
            'รูปมีขนาดใหญ่เกินไป กรุณาถ่ายใหม่',
            'ຮູບໃຫຍ່ເກີນໄປ ກະລຸນາຖ່າຍໃໝ່',
          );
        });
        return;
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(
        EvidenceAttachment(
          type: EvidenceAttachmentType.photo,
          fileName: 'pts-photo-${capturedAt.millisecondsSinceEpoch}.jpg',
          contentType: 'image/jpeg',
          bytes: watermarked,
          capturedAt: capturedAt,
          note: statusForMode(widget.mode).label(widget.languageCode),
          addressText: addressText,
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          errorText = t(
            widget.languageCode,
            'ถ่ายรูปไม่สำเร็จ',
            'ຖ່າຍຮູບບໍ່ສຳເລັດ',
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() => capturing = false);
      }
    }
  }

  List<String> watermarkLines(DateTime capturedAt) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return [
      'PTS Express',
      'ສະຖານະ: ${statusForMode(widget.mode).label('lo')}',
      if (widget.trackingCode.trim().isNotEmpty)
        'ເລກພັດສະດຸ: ${widget.trackingCode.trim()}',
      'ເວລາ: ${formatter.format(capturedAt)}',
      if (addressText?.isNotEmpty == true) 'ທີ່ຢູ່: $addressText',
    ];
  }

  ParcelStatus statusForMode(ScanMode mode) => switch (mode) {
    ScanMode.receive => ParcelStatus.receivedInThailand,
    ScanMode.arrive => ParcelStatus.arrivedInLaos,
    ScanMode.pickup => ParcelStatus.pickedUp,
  };

  @override
  Widget build(BuildContext context) {
    final camera = controller;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.86,
      child: Column(
        children: [
          const _SheetHandle(),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (initializing)
                    const Center(child: CircularProgressIndicator())
                  else if (camera != null && camera.value.isInitialized)
                    CameraPreview(camera)
                  else
                    Center(child: Text(errorText ?? 'Camera unavailable')),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _CameraMetaPanel(
                      lines: watermarkLines(DateTime.now()),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: Text(t(widget.languageCode, 'ยกเลิก', 'ຍົກເລີກ')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    key: const ValueKey('capture_evidence_button'),
                    onPressed: initializing || capturing ? null : capture,
                    icon: capturing
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.camera_alt),
                    label: Text(t(widget.languageCode, 'ถ่ายรูป', 'ຖ່າຍຮູບ')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EvidenceWatermarker {
  static Future<Uint8List> draw({
    required Uint8List imageBytes,
    required List<String> lines,
  }) async {
    final codec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: maxEvidencePhotoDimension,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(image.width.toDouble(), image.height.toDouble());
    canvas.drawImage(image, Offset.zero, Paint());

    final scale = size.width / 1600;
    final padding = 24 * scale;
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 30 * scale,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );
    final paragraph = TextPainter(
      text: TextSpan(text: lines.join('\n'), style: textStyle),
      textDirection: ui.TextDirection.ltr,
      maxLines: 8,
    )..layout(maxWidth: size.width - padding * 2);
    final offset = Offset(padding, size.height - paragraph.height - padding);
    final shadowStyle = textStyle.copyWith(color: Colors.black);
    final shadow = TextPainter(
      text: TextSpan(text: lines.join('\n'), style: shadowStyle),
      textDirection: ui.TextDirection.ltr,
      maxLines: 6,
    )..layout(maxWidth: size.width - padding * 2);
    const shadowOffsets = [
      Offset(-2, -2),
      Offset(2, -2),
      Offset(-2, 2),
      Offset(2, 2),
      Offset(0, 3),
    ];
    for (final shadowOffset in shadowOffsets) {
      shadow.paint(canvas, offset + shadowOffset * scale);
    }
    paragraph.paint(canvas, offset);

    final watermarked = await recorder.endRecording().toImage(
      image.width,
      image.height,
    );
    final data = await watermarked.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    final rgba = data!.buffer.asUint8List();
    final encoded = await _encodeJpegInIsolate(
      rgba: rgba,
      width: image.width,
      height: image.height,
    );
    return encoded;
  }

  static Future<Uint8List> _encodeJpegInIsolate({
    required Uint8List rgba,
    required int width,
    required int height,
  }) {
    return Isolate.run(() {
      final encoded = img.encodeJpg(
        img.Image.fromBytes(
          width: width,
          height: height,
          bytes: rgba.buffer,
          order: img.ChannelOrder.rgba,
        ),
        quality: evidencePhotoJpegQuality,
      );
      return Uint8List.fromList(encoded);
    });
  }
}

class _CameraMetaPanel extends StatelessWidget {
  const _CameraMetaPanel({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          lines.join('\n'),
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            height: 1.22,
            shadows: [
              Shadow(offset: Offset(-1, -1), blurRadius: 2),
              Shadow(offset: Offset(1, -1), blurRadius: 2),
              Shadow(offset: Offset(-1, 1), blurRadius: 2),
              Shadow(offset: Offset(1, 1), blurRadius: 2),
              Shadow(offset: Offset(0, 2), blurRadius: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

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
