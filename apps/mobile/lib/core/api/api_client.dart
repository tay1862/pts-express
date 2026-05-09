import 'package:dio/dio.dart';

import '../models/parcel_models.dart';
import '../models/parcel_status.dart';
import '../repositories/session_store.dart';

class ApiClient {
  ApiClient(this._sessionStore)
    : _dio = Dio(
        BaseOptions(
          baseUrl: const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'http://localhost:3000/api',
          ),
          connectTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _sessionStore.token();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final SessionStore _sessionStore;
  final Dio _dio;

  Future<UserSession> login({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
        'rememberMe': rememberMe,
      },
    );
    return UserSession.fromJson(response.data!);
  }

  Future<List<ParcelSummary>> searchParcels({
    String? query,
    ParcelStatus? status,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/parcels',
      queryParameters: {
        if (query?.isNotEmpty == true) 'q': query,
        if (status != null) 'status': status.apiValue,
      },
    );
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(ParcelSummary.fromJson)
        .toList();
  }

  Future<ParcelSummary> receive(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/parcels/receive',
      data: payload,
    );
    return ParcelSummary.fromJson(response.data!);
  }

  Future<ParcelSummary> arrive(
    String trackingCode,
    Map<String, dynamic> payload,
  ) async {
    final encodedCode = Uri.encodeComponent(trackingCode);
    final response = await _dio.post<Map<String, dynamic>>(
      '/parcels/$encodedCode/arrive',
      data: payload,
    );
    return ParcelSummary.fromJson(response.data!);
  }

  Future<ParcelSummary> pickup(
    String trackingCode,
    Map<String, dynamic> payload,
  ) async {
    final encodedCode = Uri.encodeComponent(trackingCode);
    final response = await _dio.post<Map<String, dynamic>>(
      '/parcels/$encodedCode/pickup',
      data: payload,
    );
    return ParcelSummary.fromJson(response.data!);
  }

  Future<ParcelSummary> overrideStatus(
    String parcelId,
    ParcelStatus status,
    String? reason,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/parcels/$parcelId/override',
      data: {
        'status': status.apiValue,
        if (reason?.isNotEmpty == true) 'reason': reason,
      },
    );
    return ParcelSummary.fromJson(response.data!);
  }

  Future<TrackResult> track(String trackingCode) async {
    final encodedCode = Uri.encodeComponent(trackingCode);
    final response = await _dio.get<Map<String, dynamic>>(
      '/track/$encodedCode',
    );
    return TrackResult.fromJson(response.data!);
  }

  Future<List<AdminUser>> users() async {
    final response = await _dio.get<List<dynamic>>('/users');
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(AdminUser.fromJson)
        .toList();
  }

  Future<AdminUser> createUser(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/users',
      data: payload,
    );
    return AdminUser.fromJson(response.data!);
  }

  Future<void> syncPush(List<Map<String, dynamic>> operations) async {
    await _dio.post<Map<String, dynamic>>(
      '/sync/push',
      data: {'operations': operations},
    );
  }
}
