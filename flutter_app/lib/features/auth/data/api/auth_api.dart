import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../domain/models/user.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String baseUrl}) = _AuthApi;

  /// Raw login — token is in the `Authorization` response header, not the body.
  @POST('/auth/login')
  Future<HttpResponse<Map<String, dynamic>>> loginRaw(@Body() Map<String, dynamic> body);

  /// Register sends email verification; no token in response.
  @POST('/auth/register')
  Future<HttpResponse<Map<String, dynamic>>> register(@Body() Map<String, dynamic> body);

  /// Refresh uses the HttpOnly `refreshToken` cookie automatically.
  @POST('/auth/refresh')
  Future<HttpResponse<Map<String, dynamic>>> refreshToken();

  @GET('/user/profile')
  Future<User> getProfile(@Header('Authorization') String token);
}
