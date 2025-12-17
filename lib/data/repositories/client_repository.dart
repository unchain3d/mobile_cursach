import 'package:mobile_cursach/data/models/subscription_plan.dart';
import 'package:mobile_cursach/data/models/trainer.dart';
import 'package:mobile_cursach/data/services/client_service.dart';

class ClientRepository {
  final ClientService _service = ClientService();

  Future<List<Trainer>> getTrainers() async {
    try {
      return await _service.getTrainers();
    } catch (e) {
      rethrow;
    }
  }

  Future<Trainer?> getTrainerById(int id) async {
    try {
      return await _service.getTrainerById(id);
    } catch (e) {
      return null;

    }
  }

  Future<List<String>> getTrainerSlots(int trainerId, String date) async {
    try {
      return await _service.getTrainerSlots(trainerId, date);
    } catch (e) {
      return [];
    }
  }

  Future<List<TimeSlot>> getAvailableSlots(int trainerId, DateTime date) async {
    try {
      return await _service.getAvailableSlots(trainerId, date);
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> bookSession({
    required int trainerId,
    required String date,
    required String time,
  }) async {
    try {
      return await _service.bookSession(
        trainerId: trainerId,
        date: date,
        time: time,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SubscriptionPlan>> getSubscriptions() async {
    try {
      return await _service.getSubscriptions();
    } catch (e) {
      return [];
    }
  }

  Future<void> buySubscription(int subscriptionId) async {
    try {
      await _service.buySubscription(subscriptionId);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      return await _service.getProfile();
    } catch (e) {
      return {};
    }
  }

  Future<List<dynamic>> getMySessions() async {
    try {
      return await _service.getMySessions();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> completeSession(int sessionId) async {
    try {
      return await _service.completeSession(sessionId);
    } catch (e) {
      rethrow;
    }
  }
}
