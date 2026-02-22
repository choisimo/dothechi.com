import 'package:dio/dio.dart';
import '../api/auth_api.dart';
import '../../domain/models/user.dart';
import 'token_storage.dart';

/// Result of a successful login — contains the JWT access token and user profile.
class LoginResult {
  final String token;
  final User? user;

  const LoginResult({required this.token, this.user});
}

class AuthRepository {
  final AuthApi _authApi;
  final TokenStorage _tokenStorage;
  final Dio _dio;

  AuthRepository(this._authApi, this._tokenStorage, this._dio);

  /// Login: sends credentials to `/auth/login`.
  /// The server returns the JWT in the `Authorization` response header.
  Future<LoginResult> login(String email, String password) async {
    final httpResponse = await _authApi.loginRaw({
      'email': email,
      'password': password,
    });

    // Extract token from response header
    final authHeader = httpResponse.response.headers.value('Authorization');
    if (authHeader == null) {
      throw Exception('로그인 응답에 토큰이 없습니다.');
    }
    final token = authHeader.startsWith('Bearer ')
        ? authHeader.substring(7)
        : authHeader;

    await _tokenStorage.saveToken(token);

    // Try to fetch user profile with the new token
    User? user;
    try {
      user = await _authApi.getProfile('Bearer $token');
    } catch (_) {
      // Profile fetch failure should not block login
    }

    return LoginResult(token: token, user: user);
  }

  /// Register: sends registration data to `/auth/register`.
  /// The server sends a verification email; no token is returned.
  Future<void> register(String email, String password, String userNick) async {
    await _authApi.register({
      'email': email,
      'password': password,
      'userNick': userNick,
    });
    // No token returned — user must verify email before logging in.
  }

  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }

  Future<User?> getCurrentUser() async {
    final token = await _tokenStorage.getToken();
    if (token == null) return null;

    try {
      return await _authApi.getProfile('Bearer $token');
    } catch (e) {
      await _tokenStorage.deleteToken();
      return null;
    }
  }

  Future<String?> getStoredToken() async {
    return await _tokenStorage.getToken();
  }

  Future<User> getProfile() async {
    final token = await _tokenStorage.getToken();
    if (token == null) throw Exception('토큰이 없습니다.');
    return await _authApi.getProfile('Bearer $token');
  }

  /// Refresh the access token using the HttpOnly refresh token cookie.
  Future<String?> refreshAccessToken() async {
    try {
      final httpResponse = await _authApi.refreshToken();
      final authHeader = httpResponse.response.headers.value('Authorization');
      if (authHeader == null) return null;
      final token = authHeader.startsWith('Bearer ')
          ? authHeader.substring(7)
          : authHeader;
      await _tokenStorage.saveToken(token);
      return token;
    } catch (e) {
      return null;
    }
  }
}
