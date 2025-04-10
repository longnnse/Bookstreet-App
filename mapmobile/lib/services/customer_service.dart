import 'package:dio/dio.dart';
import 'package:mapmobile/services/network_service.dart';

class CustomerService {
  final Dio _dio = NetworkService().dio;

  Future<Map<String, dynamic>> getWalletBalance() async {
    final response = await _dio.get('Customer/wallets');
    return response.data['data'];
  }

  Future<List<dynamic>> getTransactionHistory() async {
    final response = await _dio.post('Customer/transactions', data: {
      'page': 0,
      'limit': -1,
    });
    return response.data['data']['list'];
  }
}
