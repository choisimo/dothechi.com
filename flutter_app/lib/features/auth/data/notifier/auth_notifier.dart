import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/token_storage.dart';
import '../../domain/dto/auth_status.dart';

class AuthNotifier extends StateNotifier<AuthStatus> {
  final TokenStorage _tokenStorage;

  AuthNotifier(this._tokenStorage) : super(const AuthInitial());

  Future<void> initialize() async {
    state = const AuthLoading();

    try {
      final token = await _tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        // TODO: Fetch user info from server and create AuthAuthenticated state
        // For now, we just mark as unauthenticated since we don't have user info
        state = const AuthUnauthenticated();
      } else {
        state = const AuthUnauthenticated();
      }
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearAllTokens();
    state = const AuthUnauthenticated();
  }
}
