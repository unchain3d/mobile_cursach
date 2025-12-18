import 'package:mobile_cursach/data/services/admin_service.dart';

class AdminRepository {
  final AdminService _service = AdminService();

  Future<List<Map<String, dynamic>>> getTrainers() async {
    final data = await _service.getTrainers();
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> createTrainer(Map<String, dynamic> data) =>
      _service.createTrainer(data);

  Future<Map<String, dynamic>> updateTrainer(int id, Map<String, dynamic> data) =>
      _service.updateTrainer(id, data);

  Future<void> deleteTrainer(int id) => _service.deleteTrainer(id);

  Future<List<Map<String, dynamic>>> getSubscriptions() async {
    final data = await _service.getSubscriptions();
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> createSubscription(Map<String, dynamic> data) =>
      _service.createSubscription(data);

  Future<Map<String, dynamic>> updateSubscription(int id, Map<String, dynamic> data) =>
      _service.updateSubscription(id, data);

  Future<void> deleteSubscription(int id) => _service.deleteSubscription(id);

  Future<List<Map<String, dynamic>>> getUsersReport() async {
    final data = await _service.getUsersReport();
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> getFinanceReport(String month) async {
    final data = await _service.getFinanceReport(month);
    return Map<String, dynamic>.from(data);
  }
}
