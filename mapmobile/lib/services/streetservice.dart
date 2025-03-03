import 'package:dio/dio.dart';
import 'package:mapmobile/services/api.dart';

Future<dynamic> getAllStreet() async {
  final dio = Dio();
  final response = await dio.get('${baseURL}Street/tree');
  return response.data;
}
