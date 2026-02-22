import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/auth_api.dart';
import '../datasources/auth_repository.dart';
import '../datasources/token_storage.dart';
import '../../domain/dto/auth_status.dart';
import '../../domain/models/user.dart';

part 'auth_providers.g.dart';

@riverpod
Dio dio(DioRef ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://auth.nodove.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
}

@riverpod
AuthApi authApi(AuthApiRef ref) {
  final dio = ref.watch(dioProvider);
  return AuthApi(dio);
}

@riverpod
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return const FlutterSecureStorage();
}

@riverpod
TokenStorage tokenStorage(TokenStorageRef ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return TokenStorage(secureStorage);
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final authApi = ref.watch(authApiProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  final dio = ref.watch(dioProvider);
  return AuthRepository(authApi, tokenStorage, dio);
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthStatus build() {
    return AuthStatus.initial();
  }

  Future<void> login(String email, String password) async {
    state = AuthStatus.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.login(email, password);
      // result.user may be null if profile fetch failed; create a placeholder
      final user = result.user ??
          User(
            id: '',
            userId: '',
            email: email,
            userNick: email,
            userRole: UserRole.user,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
      state = AuthStatus.authenticated(user, result.token);
    } catch (e) {
      state = AuthStatus.error(e.toString());
    }
  }

  /// Register only triggers email verification — does NOT log the user in.
  Future<void> register(String email, String password, String userNick) async {
    state = AuthStatus.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.register(email, password, userNick);
      // After registration, user must verify email; go to unauthenticated
      state = AuthStatus.unauthenticated();
    } catch (e) {
      state = AuthStatus.error(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
      state = AuthStatus.unauthenticated();
    } catch (e) {
      state = AuthStatus.error(e.toString());
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.getCurrentUser();
      if (user != null) {
        final token = await repository.getStoredToken();
        state = AuthStatus.authenticated(user, token ?? '');
      } else {
        state = AuthStatus.unauthenticated();
      }
    } catch (e) {
      state = AuthStatus.unauthenticated();
    }
  }
}
