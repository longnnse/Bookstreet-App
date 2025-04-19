import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mapmobile/services/preferences_manager.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  static Dio? _dio; // Make it static and nullable

  factory NetworkService() {
    return _instance;
  }

  NetworkService._internal() {
    _initializeDio(); // Move initialization to a separate method
  }

  void _initializeDio() {
    if (_dio != null) return; // Prevent multiple initializations

    _dio = Dio(BaseOptions(
      baseUrl: "https://fptbs01.azurewebsites.net/api/",
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add pretty logger interceptor
    if (kDebugMode) {
      _dio?.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ));
    }

    // Add auth interceptor
    _dio?.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final userData = PreferencesManager.getUserData();
        if (userData != null) {
          options.headers['Authorization'] = 'Bearer ${userData['token']}';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          await PreferencesManager.removeUserData();
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio {
    if (_dio == null) {
      _initializeDio();
    }
    return _dio!;
  }
}
