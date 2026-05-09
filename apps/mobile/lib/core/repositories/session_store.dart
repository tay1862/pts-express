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

  String? _token;
  String? _userId;
  String? _username;
  String? _displayName;
  String? _role;
  String? _languageCode;

  Future<void> saveSession(UserSession session) async {
    _token = session.accessToken;
    _userId = session.userId;
    _username = session.username;
    _displayName = session.displayName;
    _role = session.role;
    await Future.wait([
      _storage.write(key: _tokenKey, value: session.accessToken),
      _storage.write(key: _userIdKey, value: session.userId),
      _storage.write(key: _usernameKey, value: session.username),
      _storage.write(key: _displayNameKey, value: session.displayName),
      _storage.write(key: _roleKey, value: session.role),
    ]);
  }

  Future<UserSession?> session() async {
    var token = _token;
    var userId = _userId;
    var username = _username;
    var displayName = _displayName;
    var role = _role;
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
    _token ??= await _storage.read(key: _tokenKey);
    return _token;
  }

  Future<void> clearSession() async {
    _token = null;
    _userId = null;
    _username = null;
    _displayName = null;
    _role = null;
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _usernameKey),
      _storage.delete(key: _displayNameKey),
      _storage.delete(key: _roleKey),
    ]);
  }

  Future<String> languageCode() async =>
      _languageCode ??= await _storage.read(key: _languageKey) ?? 'th';

  Future<void> saveLanguageCode(String value) {
    _languageCode = value;
    return _storage.write(key: _languageKey, value: value);
  }
}
