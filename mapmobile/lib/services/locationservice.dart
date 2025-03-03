import 'package:dio/dio.dart';
import 'package:mapmobile/services/api.dart';

Future<dynamic> getLocById(int? id) async {
  final dio = Dio();
  final response = await dio.get('${baseURL}Location/$id');
  return response.data;
}

Future<dynamic> getAllLoc() async {
  final dio = Dio();
  final response = await dio.get('${baseURL}Location');
  return response.data;
}
