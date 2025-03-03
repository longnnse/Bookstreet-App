import 'package:dio/dio.dart';
import 'package:mapmobile/services/api.dart';

Future<dynamic> getAllCate(String productTypeId) async {
  final dio = Dio();
  final response = await dio.post('${baseURL}Category/paginate', data: {
    "limit": -1,
    "filters": [
      {"field": "productTypeId", "value": productTypeId, "operand": 0}
    ]
  });
  return response;
}
