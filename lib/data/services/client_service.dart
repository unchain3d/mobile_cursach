import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile_cursach/data/models/subscription_plan.dart';
import 'package:mobile_cursach/data/models/trainer.dart';
import 'package:mobile_cursach/data/services/api_client.dart';

class ClientService {
  final Dio _dio = ApiClient.dio;

  Future<List<Trainer>> getTrainers() async {
    try {
      final response = await _dio.get('/client/trainers');
      final List data = response.data;
      return data.map((json) => Trainer.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ ClientService.getTrainers error: $e');
      rethrow;
    }
  }

  Future<Trainer?> getTrainerById(int id) async {
    try {
      final response = await _dio.get('/client/trainers/$id');
      return Trainer.fromJson(response.data);
    } catch (e) {
      debugPrint('❌ ClientService.getTrainerById error: $e');
      return null;
    }
  }

  Future<List<String>> getTrainerSlots(int trainerId, String date) async {
    try {
      final response = await _dio.get(
        '/client/trainers/$trainerId/available-slots',
        queryParameters: {'date': date},
      );

      return (response.data as List).map((e) {
        if (e is Map && e.containsKey('time')) {
          return e['time'].toString().substring(0, 5);
        }
        return e.toString();
      }).toList();
    } catch (e) {
      debugPrint('❌ ClientService.getTrainerSlots error: $e');
      return [];
    }
  }

  Future<List<TimeSlot>> getAvailableSlots(int trainerId, DateTime date) async {
    final dateStr =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    try {
      final response = await _dio.get(
        '/client/trainers/$trainerId/available-slots',
        queryParameters: {'date': dateStr},
      );
      return (response.data as List).map((e) => TimeSlot.fromJson(e)).toList();
    } catch (e) {
      debugPrint('❌ ClientService.getAvailableSlots error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> bookSession({
    required int trainerId,
    required String date,
    required String time,
  }) async {
    try {
      final String sessionTime = "${date}T$time:00";

      final response = await _dio.post(
        '/client/book-session',
        data: {'trainer_id': trainerId, 'session_time': sessionTime},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ ClientService.bookSession error: $e');
      rethrow;
    }
  }

  Future<List<SubscriptionPlan>> getSubscriptions() async {
    try {
      final response = await _dio.get('/client/subscriptions');
      return (response.data as List)
          .map((e) => SubscriptionPlan.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint('❌ ClientService.getSubscriptions error: $e');
      return [];
    }
  }

  Future<void> buySubscription(int subscriptionId) async {
    try {
      await _dio.post(
        '/client/purchase-subscription',
        data: {'subscription_id': subscriptionId},
      );
    } catch (e) {
      debugPrint('❌ ClientService.buySubscription error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/client/profile');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ ClientService.getProfile error: $e');
      return {};
    }
  }

  Future<List<dynamic>> getMySessions() async {
    try {
      final response = await _dio.get('/client/sessions');
      if (response.data is List) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint('❌ ClientService.getMySessions error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> completeSession(int sessionId) async {
    try {
      final response = await _dio.post('/client/complete-session/$sessionId');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ ClientService.completeSession error: $e');
      rethrow;
    }
  }
}
