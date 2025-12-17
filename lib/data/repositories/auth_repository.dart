import 'package:dio/dio.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:mobile_cursach/data/services/auth_service.dart';
import 'package:mobile_cursach/data/services/local_storage.dart';

class AuthRepository {
  final _api = AuthService();

  Future<String> login({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final res = await _api.login(username: username, password: password);

      final token = res.data?['access_token']?.toString();
      final role = res.data?['role']?.toString();

      if (token == null || token.isEmpty) {
        throw Exception('Не вдалося отримати токен доступу.');
      }

      final payload = Jwt.parseJwt(token);
      final rawId = payload['id'];
      final userId = rawId is int ? rawId : int.tryParse(rawId.toString());
      if (userId != null) {
        await LocalStorage.saveUserId(userId);
      }

      final isAdmin = role == 'admin';
      await LocalStorage.saveIsAdmin(isAdmin);

      await LocalStorage.saveToken(token);

      await LocalStorage.saveRememberMe(rememberMe);

      return token;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final detail = _extractDetail(e);

      if (code == 401) throw Exception('Невірний логін або пароль.');
      if (code == 400 && detail != null) throw Exception(detail);
      if (code == 500) throw Exception('Помилка сервера.');

      throw Exception(detail ?? 'Помилка мережі.');
    } catch (e) {
      throw Exception('Сталася помилка: $e');
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await _api.register(username: username, email: email, password: password);
    } on DioException catch (e) {
      final detail = _extractDetail(e);
      throw Exception(detail ?? 'Помилка мережі.');
    } catch (_) {
      throw Exception('Помилка реєстрації.');
    }
  }

  String? _extractDetail(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['detail'] != null) {
      return data['detail'].toString();
    }
    return null;
  }
}