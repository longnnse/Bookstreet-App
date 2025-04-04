import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mapmobile/services/network_service.dart';
import 'package:mapmobile/services/preferences_manager.dart';

class AuthService {
  final Dio _dio = NetworkService().dio;

  Future<dynamic> register({
    String? email,
    String? password,
    String? fullName,
    String? username,
  }) async {
    final response = await _dio.post('Auth/Register', data: {
      'email': email,
      'password': password,
      'fullName': fullName,
      'username': username,
    });
    return response.data;
  }

  Future<dynamic> login({String? username, String? password}) async {
    try {
      debugPrint('📡 Attempting login for user: $username');
      final response = await _dio.post('Auth/Login', data: {
        'username': username,
        'password': password,
      });

      // Save token if login is successful
      if (response.data['data'] != null) {
        await PreferencesManager.saveUserData(response.data['data']);
        debugPrint('✅ Login successful and token saved');
      }

      return response.data;
    } catch (e) {
      debugPrint('❌ Login error: $e');
      rethrow;
    }
  }

  Future<dynamic> getMembershipInfo(String id) async {
    final response = await _dio.get('Auth/$id');
    return response.data;
  }

  Future<void> logout() async {
    await PreferencesManager.removeUserData();
    debugPrint('✅ Logged out successfully');
  }
}
