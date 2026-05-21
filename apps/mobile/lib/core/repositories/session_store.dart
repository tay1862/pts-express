import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/parcel_models.dart';

class SessionStore {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'pts_access_token';
  static const _userIdKey = 'pts_user_id';
  static const _usernameKey = 'pts_username';
  static const _displayNameKey = 'pts_display_name';
  static const _roleKey = 'pts_role';
  static const _languageKey = 'pts_language';
  static const _themeModeKey = 'pts_theme_mode';

  String? _token;
  String? _userId;
  String? _username;
  String? _displayName;
  String? _role;
  String? _languageCode;
  String? _themeMode;

  Future<void> saveSession(UserSession session) async {
    _token = session.accessToken;
    _userId = session.userId;
    _username = session.username;
    _displayName = session.displayName;
    _role = session.role;
    try {
      await Future.wait([
        _storage.write(key: _tokenKey, value: session.accessToken),
        _storage.write(key: _userIdKey, value: session.userId),
        _storage.write(key: _usernameKey, value: session.username),
        _storage.write(key: _displayNameKey, value: session.displayName),
        _storage.write(key: _roleKey, value: session.role),
      ]);
    } catch (_) {
      // Fallback silently if storage write fails
    }
  }

  Future<UserSession?> session() async {
    var token = _token;
    var userId = _userId;
    var username = _username;
    var displayName = _displayName;
    var role = _role;
    try {
      if ([
        token,
        userId,
        username,
        displayName,
        role,
      ].any((value) => value == null)) {
        token = await _storage.read(key: _tokenKey);
        userId = await _storage.read(key: _userIdKey);
        username = await _storage.read(key: _usernameKey);
        displayName = await _storage.read(key: _displayNameKey);
        role = await _storage.read(key: _roleKey);
      }
    } catch (_) {
      // Fallback to in-memory if storage read fails
    }
    if ([
      token,
      userId,
      username,
      displayName,
      role,
    ].any((value) => value == null)) {
      return null;
    }
    _token = token;
    _userId = userId;
    _username = username;
    _displayName = displayName;
    _role = role;
    return UserSession(
      accessToken: token!,
      userId: userId!,
      username: username!,
      displayName: displayName!,
      role: role!,
    );
  }

  Future<String?> token() async {
    try {
      _token ??= await _storage.read(key: _tokenKey);
    } catch (_) {
      // Fallback silently
    }
    return _token;
  }

  Future<void> clearSession() async {
    _token = null;
    _userId = null;
    _username = null;
    _displayName = null;
    _role = null;
    try {
      await Future.wait([
        _storage.delete(key: _tokenKey),
        _storage.delete(key: _userIdKey),
        _storage.delete(key: _usernameKey),
        _storage.delete(key: _displayNameKey),
        _storage.delete(key: _roleKey),
      ]);
    } catch (_) {
      // Fallback silently
    }
  }

  Future<String> languageCode() async {
    try {
      _languageCode ??= await _storage.read(key: _languageKey) ?? 'th';
    } catch (_) {
      _languageCode ??= 'th';
    }
    return _languageCode!;
  }

  Future<void> saveLanguageCode(String value) async {
    _languageCode = value;
    try {
      await _storage.write(key: _languageKey, value: value);
    } catch (_) {
      // Fallback silently
    }
  }

  Future<String> themeMode() async {
    try {
      _themeMode ??= await _storage.read(key: _themeModeKey) ?? 'system';
    } catch (_) {
      _themeMode ??= 'system';
    }
    return _themeMode!;
  }

  Future<void> saveThemeMode(String value) async {
    _themeMode = value;
    try {
      await _storage.write(key: _themeModeKey, value: value);
    } catch (_) {
      // Fallback silently
    }
  }
}
