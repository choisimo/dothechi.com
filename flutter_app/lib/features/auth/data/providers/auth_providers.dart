import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../api/auth_api.dart';
import '../datasources/auth_repository.dart';
import '../datasources/token_storage.dart';
import '../../domain/dto/auth_status.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/storage_interface.dart';
import '../../../../core/storage/storage_factory.dart';

part 'auth_providers.g.dart';

@riverpod
StorageInterface platformStorage(PlatformStorageRef ref) {
  return StorageFactory.create();
}

@riverpod
AuthApi authApi(AuthApiRef ref) {
  final dio = ref.watch(authDioProvider);
  return AuthApi(dio);
}

@riverpod
TokenStorage tokenStorage(TokenStorageRef ref) {
  final storage = ref.watch(platformStorageProvider);
  return TokenStorage(storage);
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final authApi = ref.watch(authApiProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthRepository(authApi, tokenStorage);
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
      state = AuthStatus.authenticated(result.user, result.token);
    } catch (e) {
      state = AuthStatus.error(e.toString());
    }
  }

  Future<void> register(String email, String password, String userNick) async {
    state = AuthStatus.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.register(email, password, userNick);
      state = AuthStatus.authenticated(result.user, result.token);
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
