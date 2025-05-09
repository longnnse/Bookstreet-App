import 'package:dio/dio.dart';
import 'package:mapmobile/services/network_service.dart';

class PointHistoryService {
  final Dio _dio = NetworkService().dio;

  Future<List<dynamic>> getPointHistory(String customerId) async {
    final response = await _dio.post('PointHistory/paginate', data: {
      'page': 0,
      'limit': 0,
      "orders": [
        {"field": "createDate", "dir": "desc"}
      ]
    });
    return response.data['data']['list'];
  }
}
