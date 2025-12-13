import 'package:dio/dio.dart';
import 'package:mobile_cursach/data/services/api_client.dart';
import 'package:mobile_cursach/data/services/local_storage.dart';

class AuthService {
  final Dio _dio = ApiClient.dio;

  Future<Response<dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    return await _dio.post(
      'auth/register',
      data: {'username': username, 'email': email, 'password': password},
    );
  }

  Future<Response<dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post<dynamic>(
      'auth/login',
      data: FormData.fromMap({'username': username, 'password': password}),
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    if (response.statusCode == 200 && response.data != null) {
      final token = response.data['access_token'];

      if (token != null) {
        await LocalStorage.saveToken(token.toString());
      }
    }
    return response;
  }
}
