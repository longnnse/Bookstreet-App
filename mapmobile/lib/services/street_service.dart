import 'package:dio/dio.dart';
import 'package:mapmobile/services/api.dart';
import 'package:mapmobile/services/network_service.dart';

class Streetservice {
  final Dio _dio = NetworkService().dio;
  Future<dynamic> getAllStreet() async {
    final response = await _dio.get('${baseURL}Street/tree');
    return response.data;
  }
}
