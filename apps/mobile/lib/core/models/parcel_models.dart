import 'parcel_status.dart';

class UserSession {
  const UserSession({
    required this.accessToken,
    required this.userId,
    required this.username,
    required this.displayName,
    required this.role,
  });

  final String accessToken;
  final String userId;
  final String username;
  final String displayName;
  final String role;

  bool get isAdmin => role == 'OWNER' || role == 'ADMIN';

  factory UserSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return UserSession(
      accessToken: json['accessToken'] as String,
      userId: user['id'] as String,
      username: user['username'] as String,
      displayName: user['displayName'] as String,
      role: user['role'] as String,
    );
  }
}

class ParcelEventSummary {
  const ParcelEventSummary({
    required this.eventType,
    required this.toStatus,
    required this.happenedAt,
    this.note,
  });

  final String eventType;
  final ParcelStatus? toStatus;
  final DateTime happenedAt;
  final String? note;

  factory ParcelEventSummary.fromJson(Map<String, dynamic> json) =>
      ParcelEventSummary(
        eventType: json['eventType'] as String,
        toStatus: (json['toStatus'] ?? json['status']) == null
            ? null
            : ParcelStatus.fromApi(
                (json['toStatus'] ?? json['status']) as String,
              ),
        happenedAt: DateTime.parse(json['happenedAt'] as String),
        note: json['note'] as String?,
      );
}

class ParcelPhotoSummary {
  const ParcelPhotoSummary({
    required this.id,
    required this.type,
    required this.url,
    required this.createdAt,
    this.note,
    this.eventId,
    this.capturedAt,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.addressText,
  });

  final String id;
  final String type;
  final String url;
  final String? note;
  final String? eventId;
  final DateTime? capturedAt;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final String? addressText;
  final DateTime createdAt;

  String get displayUrl {
    if (!url.startsWith('http')) {
      return url;
    }
    final apiBaseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:3000/api',
    );
    return '$apiBaseUrl/storage/proxy?url=${Uri.encodeComponent(url)}';
  }

  factory ParcelPhotoSummary.fromJson(Map<String, dynamic> json) =>
      ParcelPhotoSummary(
        id: json['id'] as String,
        type: (json['type'] as String?) ?? 'PHOTO',
        url: json['url'] as String,
        note: json['note'] as String?,
        eventId: json['eventId'] as String?,
        capturedAt: json['capturedAt'] == null
            ? null
            : DateTime.parse(json['capturedAt'] as String),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        accuracyMeters: (json['accuracyMeters'] as num?)?.toDouble(),
        addressText: json['addressText'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class ParcelSummary {
  const ParcelSummary({
    required this.id,
    required this.trackingCode,
    required this.status,
    required this.customerName,
    required this.updatedAt,
    this.customerPhone,
    this.labelName,
    this.note,
    this.events = const [],
    this.photos = const [],
    this.queued = false,
  });

  final String id;
  final String trackingCode;
  final ParcelStatus status;
  final String customerName;
  final String? customerPhone;
  final String? labelName;
  final String? note;
  final DateTime updatedAt;
  final List<ParcelEventSummary> events;
  final List<ParcelPhotoSummary> photos;
  final bool queued;

  factory ParcelSummary.fromJson(Map<String, dynamic> json) => ParcelSummary(
    id: json['id'] as String,
    trackingCode: json['trackingCode'] as String,
    status: ParcelStatus.fromApi(json['status'] as String),
    customerName: json['customerName'] as String,
    customerPhone: json['customerPhone'] as String?,
    labelName: json['labelName'] as String?,
    note: json['note'] as String?,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    events: ((json['events'] as List?) ?? [])
        .cast<Map<String, dynamic>>()
        .map(ParcelEventSummary.fromJson)
        .toList(),
    photos: ((json['photos'] as List?) ?? [])
        .cast<Map<String, dynamic>>()
        .map(ParcelPhotoSummary.fromJson)
        .toList(),
  );
}

class TrackResult {
  const TrackResult({
    required this.trackingCode,
    required this.status,
    required this.history,
  });

  final String trackingCode;
  final ParcelStatus status;
  final List<ParcelEventSummary> history;

  factory TrackResult.fromJson(Map<String, dynamic> json) => TrackResult(
    trackingCode: json['trackingCode'] as String,
    status: ParcelStatus.fromApi(json['status'] as String),
    history: ((json['history'] as List?) ?? [])
        .cast<Map<String, dynamic>>()
        .map(ParcelEventSummary.fromJson)
        .toList(),
  );
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    required this.isActive,
  });

  final String id;
  final String username;
  final String displayName;
  final String role;
  final bool isActive;

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    id: json['id'] as String,
    username: json['username'] as String,
    displayName: json['displayName'] as String,
    role: json['role'] as String,
    isActive: json['isActive'] as bool,
  );
}
