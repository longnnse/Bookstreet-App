import 'package:dio/dio.dart';
import 'package:mapmobile/services/api.dart';

Future<dynamic> getDistributorById(String? id) async {
  final dio = Dio();
  final response = await dio.get('${baseURL}Distributor/$id');
  return response.data;
}

Future<dynamic> getAllDistributor() async {
  final dio = Dio();
  final response = await dio.get('${baseURL}Distributor');
  return response.data;
}
