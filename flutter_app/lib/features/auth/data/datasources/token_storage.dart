import 'package:flutter_chat_client/core/storage/storage_interface.dart';

class TokenStorage {
  final StorageInterface _storage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _legacyTokenKey = 'auth_token';

  TokenStorage(this._storage);

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    if (token != null) return token;
    return await _storage.read(key: _legacyTokenKey);
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _legacyTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    if (refreshToken != null) {
      await saveRefreshToken(refreshToken);
    }
  }

  Future<void> clearAllTokens() async {
    await Future.wait([deleteAccessToken(), deleteRefreshToken()]);
  }

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> hasRefreshToken() async {
    final token = await getRefreshToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveToken(String token) async {
    await saveAccessToken(token);
  }

  Future<String?> getToken() async {
    return await getAccessToken();
  }

  Future<void> deleteToken() async {
    await deleteAccessToken();
  }

  Future<bool> hasToken() async {
    return await hasAccessToken();
  }
}
