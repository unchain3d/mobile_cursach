import 'package:dio/dio.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:mobile_cursach/data/services/auth_service.dart';
import 'package:mobile_cursach/data/services/local_storage.dart';
import 'package:mobile_cursach/data/services/profile_service.dart';

class AuthRepository {
  final _api = AuthService();
  final _profileApi = ProfileService();

  Future<String> login({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final res = await _api.login(username: username, password: password);

      final token = res.data?['access_token']?.toString();
      if (token == null || token.isEmpty) {
        throw Exception('Не вдалося отримати токен доступу.');
      }

      final payload = Jwt.parseJwt(token);

      final rawId = payload['id'];
      final userId = rawId is int ? rawId : int.tryParse(rawId.toString());
      if (userId == null) {
        throw Exception('Помилка: не вдалося отримати userId з токена.');
      }

      await LocalStorage.saveUserId(userId);

      final profile = await _profileApi.getProfile();
      final rawAdmin = profile['is_admin'];
      final isAdmin = rawAdmin == true || rawAdmin == 1 || rawAdmin == '1';

      await LocalStorage.saveIsAdmin(isAdmin);

      if (rememberMe) {
        await LocalStorage.saveToken(token);
      }

      return token;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final detail = _extractDetail(e);

      if (code == 401) throw Exception('Невірний логін або пароль.');
      if (code == 400 && detail != null) throw Exception(detail);
      if (code == 500) throw Exception('Помилка сервера. Спробуйте пізніше.');

      throw Exception(
        detail ?? 'Помилка мережі. Перевірте інтернет і спробуйте ще.',
      );
    } catch (_) {
      throw Exception('Сталася невідома помилка. Спробуйте ще раз.');
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
      final code = e.response?.statusCode;
      final detail = _extractDetail(e);

      if (code == 400 && detail != null) throw Exception(detail);
      if (code == 500) throw Exception('Помилка сервера. Спробуйте пізніше.');

      throw Exception(
        detail ?? 'Помилка мережі. Перевірте інтернет і спробуйте ще.',
      );
    } catch (_) {
      throw Exception('Сталася невідома помилка. Спробуйте ще раз.');
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
