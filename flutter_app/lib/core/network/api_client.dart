import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/app_config.dart';
import '../../features/auth/data/datasources/token_storage.dart';

part 'api_client.g.dart';

/// Centralized API client with Dio configuration and interceptors.
///
/// Features:
/// - Automatic token injection for authenticated requests
/// - Request/Response logging (dev only)
/// - Centralized error handling
/// - Token refresh on 401 responses
class ApiClient {
  final Dio _authDio;
  final Dio _communityDio;
  final Dio _chatDio;
  final TokenStorage _tokenStorage;

  ApiClient({
    required Dio authDio,
    required Dio communityDio,
    required Dio chatDio,
    required TokenStorage tokenStorage,
  }) : _authDio = authDio,
       _communityDio = communityDio,
       _chatDio = chatDio,
       _tokenStorage = tokenStorage;

  Dio get authDio => _authDio;
  Dio get communityDio => _communityDio;
  Dio get chatDio => _chatDio;

  /// Factory constructor with default configuration
  factory ApiClient.create(TokenStorage tokenStorage) {
    final config = AppConfig.instance;

    final authDio = _createDio(config.authBaseUrl, config);
    final communityDio = _createDio(config.communityBaseUrl, config);
    final chatDio = _createDio(config.chatBaseUrl, config);

    final client = ApiClient(
      authDio: authDio,
      communityDio: communityDio,
      chatDio: chatDio,
      tokenStorage: tokenStorage,
    );

    // Add interceptors
    client._addAuthInterceptor(authDio);
    client._addAuthInterceptor(communityDio);
    client._addAuthInterceptor(chatDio);

    if (config.enableLogging) {
      client._addLoggingInterceptor(authDio, 'AUTH');
      client._addLoggingInterceptor(communityDio, 'COMMUNITY');
      client._addLoggingInterceptor(chatDio, 'CHAT');
    }

    client._addErrorInterceptor(authDio);
    client._addErrorInterceptor(communityDio);
    client._addErrorInterceptor(chatDio);

    return client;
  }

  static Dio _createDio(String baseUrl, AppConfig config) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  void _addAuthInterceptor(Dio dio) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip auth header for login/register endpoints
          final skipAuthPaths = [
            '/auth/login',
            '/auth/register',
            '/auth/refresh',
          ];
          if (skipAuthPaths.any((path) => options.path.contains(path))) {
            return handler.next(options);
          }

          final token = await _tokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 - attempt token refresh
          if (error.response?.statusCode == 401) {
            final refreshed = await _attemptTokenRefresh();
            if (refreshed) {
              // Retry the original request
              final newToken = await _tokenStorage.getAccessToken();
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newToken';

              try {
                final response = await dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _attemptTokenRefresh() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _authDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'] as String?;
        final newRefreshToken = response.data['refreshToken'] as String?;

        if (newAccessToken != null) {
          await _tokenStorage.saveAccessToken(newAccessToken);
        }
        if (newRefreshToken != null) {
          await _tokenStorage.saveRefreshToken(newRefreshToken);
        }
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Token refresh failed: $e', name: 'ApiClient');
      return false;
    }
  }

  void _addLoggingInterceptor(Dio dio, String tag) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          developer.log(
            '[$tag] → ${options.method} ${options.path}',
            name: 'ApiClient',
          );
          if (options.data != null) {
            developer.log('[$tag] Body: ${options.data}', name: 'ApiClient');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          developer.log(
            '[$tag] ← ${response.statusCode} ${response.requestOptions.path}',
            name: 'ApiClient',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          developer.log(
            '[$tag] ✖ ${error.response?.statusCode ?? 'N/A'} '
            '${error.requestOptions.path}: ${error.message}',
            name: 'ApiClient',
            error: error,
          );
          return handler.next(error);
        },
      ),
    );
  }

  void _addErrorInterceptor(Dio dio) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Transform DioException to ApiException for better handling
          final apiError = ApiException.fromDioError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: apiError,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }
}

/// Custom exception for API errors with user-friendly messages.
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? code;
  final dynamic originalError;

  ApiException({
    this.statusCode,
    required this.message,
    this.code,
    this.originalError,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          statusCode: null,
          message: '서버 연결 시간이 초과되었습니다. 다시 시도해주세요.',
          code: 'TIMEOUT',
          originalError: error,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          statusCode: null,
          message: '인터넷 연결을 확인해주세요.',
          code: 'CONNECTION_ERROR',
          originalError: error,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return ApiException(
          statusCode: null,
          message: '요청이 취소되었습니다.',
          code: 'CANCELLED',
          originalError: error,
        );

      default:
        return ApiException(
          statusCode: null,
          message: '알 수 없는 오류가 발생했습니다.',
          code: 'UNKNOWN',
          originalError: error,
        );
    }
  }

  static ApiException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // Try to extract server error message
    String? serverMessage;
    String? errorCode;
    if (data is Map<String, dynamic>) {
      serverMessage = data['message'] as String? ?? data['error'] as String?;
      errorCode = data['code'] as String?;
    }

    switch (statusCode) {
      case 400:
        return ApiException(
          statusCode: 400,
          message: serverMessage ?? '잘못된 요청입니다.',
          code: errorCode ?? 'BAD_REQUEST',
          originalError: error,
        );

      case 401:
        return ApiException(
          statusCode: 401,
          message: serverMessage ?? '인증이 필요합니다. 다시 로그인해주세요.',
          code: errorCode ?? 'UNAUTHORIZED',
          originalError: error,
        );

      case 403:
        return ApiException(
          statusCode: 403,
          message: serverMessage ?? '접근 권한이 없습니다.',
          code: errorCode ?? 'FORBIDDEN',
          originalError: error,
        );

      case 404:
        return ApiException(
          statusCode: 404,
          message: serverMessage ?? '요청한 리소스를 찾을 수 없습니다.',
          code: errorCode ?? 'NOT_FOUND',
          originalError: error,
        );

      case 409:
        return ApiException(
          statusCode: 409,
          message: serverMessage ?? '이미 존재하는 데이터입니다.',
          code: errorCode ?? 'CONFLICT',
          originalError: error,
        );

      case 422:
        return ApiException(
          statusCode: 422,
          message: serverMessage ?? '입력값을 확인해주세요.',
          code: errorCode ?? 'VALIDATION_ERROR',
          originalError: error,
        );

      case 429:
        return ApiException(
          statusCode: 429,
          message: '너무 많은 요청을 보냈습니다. 잠시 후 다시 시도해주세요.',
          code: errorCode ?? 'TOO_MANY_REQUESTS',
          originalError: error,
        );

      case 500:
      case 502:
      case 503:
        return ApiException(
          statusCode: statusCode,
          message: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
          code: errorCode ?? 'SERVER_ERROR',
          originalError: error,
        );

      default:
        return ApiException(
          statusCode: statusCode,
          message: serverMessage ?? '오류가 발생했습니다.',
          code: errorCode ?? 'UNKNOWN',
          originalError: error,
        );
    }
  }

  @override
  String toString() => 'ApiException: [$statusCode] $message (code: $code)';

  /// User-friendly error message for display in UI
  String get userMessage => message;
}

// ============================================================================
// Riverpod Providers
// ============================================================================

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  throw UnimplementedError(
    'apiClientProvider must be overridden with ProviderScope overrides. '
    'See main.dart for setup.',
  );
}

/// Provider for auth API Dio instance
@riverpod
Dio authDio(Ref ref) {
  return ref.watch(apiClientProvider).authDio;
}

/// Provider for community API Dio instance
@riverpod
Dio communityDio(Ref ref) {
  return ref.watch(apiClientProvider).communityDio;
}

/// Provider for chat API Dio instance
@riverpod
Dio chatDio(Ref ref) {
  return ref.watch(apiClientProvider).chatDio;
}
