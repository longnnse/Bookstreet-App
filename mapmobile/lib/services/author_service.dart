import 'package:dio/dio.dart';
import 'package:mapmobile/services/api.dart';
import 'package:mapmobile/services/network_service.dart';

class AuthorService {
  final Dio _dio = NetworkService().dio;

  Future<dynamic> getAuthorById(String? id) async {
    final response = await _dio.get('${baseURL}Author/$id');
    return response.data['data'];
  }

  Future<dynamic> getAllAuthor() async {
    final response = await _dio.get('${baseURL}Author');
    return response.data['data']['list'];
  }
}
