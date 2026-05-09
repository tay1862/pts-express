import 'dart:convert';
import 'dart:typed_data';

enum EvidenceAttachmentType {
  photo('PHOTO'),
  signature('SIGNATURE');

  const EvidenceAttachmentType(this.apiValue);

  final String apiValue;
}

class EvidenceAttachment {
  const EvidenceAttachment({
    required this.type,
    required this.fileName,
    required this.contentType,
    required this.bytes,
    required this.capturedAt,
    this.note,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.addressText,
  });

  final EvidenceAttachmentType type;
  final String fileName;
  final String contentType;
  final Uint8List bytes;
  final DateTime capturedAt;
  final String? note;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final String? addressText;

  Map<String, dynamic> toJson() => {
    'type': type.apiValue,
    'fileName': fileName,
    'contentType': contentType,
    'dataBase64': base64Encode(bytes),
    'capturedAt': capturedAt.toIso8601String(),
    if (note?.isNotEmpty == true) 'note': note,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (accuracyMeters != null) 'accuracyMeters': accuracyMeters,
    if (addressText?.isNotEmpty == true) 'addressText': addressText,
  };
}
