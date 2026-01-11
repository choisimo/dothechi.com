import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for authentication tokens.
///
/// Uses FlutterSecureStorage to store tokens securely on the device.
/// Supports both access tokens and refresh tokens for proper OAuth2 flow.
class TokenStorage {
  final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  // Legacy key for backwards compatibility
  static const String _legacyTokenKey = 'auth_token';

  TokenStorage(this._secureStorage);

  // ============================================================================
  // Access Token Methods
  // ============================================================================

  /// Save the access token securely.
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  /// Get the stored access token.
  Future<String?> getAccessToken() async {
    // Try new key first, fallback to legacy
    final token = await _secureStorage.read(key: _accessTokenKey);
    if (token != null) return token;
    return await _secureStorage.read(key: _legacyTokenKey);
  }

  /// Delete the access token.
  Future<void> deleteAccessToken() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _legacyTokenKey);
  }

  // ============================================================================
  // Refresh Token Methods
  // ============================================================================

  /// Save the refresh token securely.
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  /// Get the stored refresh token.
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// Delete the refresh token.
  Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  // ============================================================================
  // Utility Methods
  // ============================================================================

  /// Save both access and refresh tokens.
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    if (refreshToken != null) {
      await saveRefreshToken(refreshToken);
    }
  }

  /// Delete all stored tokens (logout).
  Future<void> clearAllTokens() async {
    await Future.wait([deleteAccessToken(), deleteRefreshToken()]);
  }

  /// Check if user has a valid access token stored.
  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Check if user has a refresh token stored.
  Future<bool> hasRefreshToken() async {
    final token = await getRefreshToken();
    return token != null && token.isNotEmpty;
  }

  // ============================================================================
  // Legacy Methods (for backwards compatibility)
  // ============================================================================

  /// @deprecated Use [saveAccessToken] instead.
  Future<void> saveToken(String token) async {
    await saveAccessToken(token);
  }

  /// @deprecated Use [getAccessToken] instead.
  Future<String?> getToken() async {
    return await getAccessToken();
  }

  /// @deprecated Use [deleteAccessToken] instead.
  Future<void> deleteToken() async {
    await deleteAccessToken();
  }

  /// @deprecated Use [hasAccessToken] instead.
  Future<bool> hasToken() async {
    return await hasAccessToken();
  }
}
