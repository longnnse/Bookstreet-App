import 'package:dio/dio.dart';
import 'package:mapmobile/services/api.dart';

Future<dynamic> getAllRecord(String? phone) async {
  final dio = Dio();
  final response = await dio.post('${baseURL}Customer/paginate', data: {
    "limit": -1,
    "filters": [
      {"field": "phone", "value": phone, "operand": 0}
    ]
  });
  return response.data;
}

Future<dynamic> getCustomer(int? customerId) async {
  final dio = Dio();
  final response = await dio.get('${baseURL}Customer/$customerId');
  return response.data;
}

Future<dynamic> getPointHistory(String? customerId, String? storeId) async {
  final dio = Dio();
  final response = await dio.post('${baseURL}PointHistory/paginate', data: {
    "limit": -1,
    "filters": [
      {"field": "customerId", "value": customerId, "operand": 0},
      {"field": "storeId", "value": storeId, "operand": 0}
    ]
  });
  return response.data;
}

Future<dynamic> getPointHistory2(String? phone) async {
  final dio = Dio();
  final response = await dio.post('${baseURL}PointHistory/paginate', data: {
    "limit": -1,
    "filters": [
      {"field": "Customer.Phone", "value": phone, "operand": 0}
    ]
  });
  return response.data;
}
