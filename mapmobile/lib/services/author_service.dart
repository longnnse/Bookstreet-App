import 'package:dio/dio.dart';
import 'package:mapmobile/services/api.dart';

Future<dynamic> getAuthorById(String? id) async {
  final dio = Dio();
  final response = await dio.get('${baseURL}Author/$id');
  return response.data;
}

Future<dynamic> getAllAuthor() async {
  final dio = Dio();
  final response = await dio.get('${baseURL}Author');
  return response.data;
}
