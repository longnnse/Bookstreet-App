import 'package:dio/dio.dart';
import 'package:mapmobile/services/api.dart';

Future<dynamic> getAllGenre() async {
  final dio = Dio();
  final response = await dio.get('${baseURL}Genre');
  return response;
}

Future<dynamic> getGenreByCate(int categoryId) async {
  final dio = Dio();
  final response = await dio.post('${baseURL}Genre/paginate', data: {
    "limit": -1,
    "filters": [
      {"field": "categoryId", "value": "$categoryId", "operand": 0}
    ]
  });
  return response;
}
