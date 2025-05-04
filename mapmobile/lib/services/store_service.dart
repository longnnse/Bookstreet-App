import 'package:dio/dio.dart';
import 'package:mapmobile/services/api.dart';
import 'package:mapmobile/services/network_service.dart';

class StoreService {
  final Dio _dio = NetworkService().dio;
  Future<dynamic> getStoreById(String? id) async {
    final response = await _dio.get('${baseURL}Store/$id');
    return response.data['data'];
  }

  Future<dynamic> getAllBookStore() async {
    final dio = Dio();
    final response = await _dio.get('${baseURL}Store');
    return response.data['data'];
  }
}
