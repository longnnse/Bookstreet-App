import 'package:dio/dio.dart';
import 'package:mapmobile/services/network_service.dart';

class DistributorService {
  final Dio _dio = NetworkService().dio;
  Future<dynamic> getDistributorById(String? id) async {
    final response = await _dio.get('Distributor/$id');
    return response.data;
  }

  Future<dynamic> getAllDistributor() async {
    final response = await _dio.get('Distributor');
    return response.data['data'];
  }
}
