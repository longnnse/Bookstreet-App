import 'package:dio/dio.dart';
import 'package:mapmobile/services/api.dart';

Future<dynamic> getStoreById(String? id) async {
  final dio = Dio();
  final response = await dio.get('${baseURL}Store/$id');
  return response.data;
}

Future<dynamic> getAllBookStore() async {
  final dio = Dio();
  final response = await dio.get('${baseURL}Store');
  return response.data;
}
