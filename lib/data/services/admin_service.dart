import 'package:dio/dio.dart';
import 'package:mobile_cursach/data/services/api_client.dart';

class AdminService {
  final Dio _dio = ApiClient.dio;

  Future<List<dynamic>> getTrainers() async {
    final res = await _dio.get('/admin/trainers');
    return (res.data is List) ? res.data as List<dynamic> : [];
  }

  Future<Map<String, dynamic>> createTrainer(Map<String, dynamic> data) async {
    final res = await _dio.post('/admin/trainers', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateTrainer(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/admin/trainers/$id', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<void> deleteTrainer(int id) async {
    await _dio.delete('/admin/trainers/$id');
  }

  Future<List<dynamic>> getSubscriptions() async {
    final res = await _dio.get('/admin/subscriptions');
    return (res.data is List) ? res.data as List<dynamic> : [];
  }

  Future<Map<String, dynamic>> createSubscription(Map<String, dynamic> data) async {
    final res = await _dio.post('/admin/subscriptions', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateSubscription(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/admin/subscriptions/$id', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<void> deleteSubscription(int id) async {
    await _dio.delete('/admin/subscriptions/$id');
  }

  Future<List<dynamic>> getUsersReport() async {
    final res = await _dio.get('/admin/reports/users');
    return (res.data is List) ? res.data as List<dynamic> : [];
  }

  Future<Map<String, dynamic>> getFinanceReport(String month) async {
    final res = await _dio.get(
      '/admin/reports/finance',
      queryParameters: {'month': month},
    );
    return (res.data is Map) ? res.data as Map<String, dynamic> : {};
  }
}
