import 'package:dio/dio.dart';
import 'package:mapmobile/services/api.dart';

Future<dynamic> getEvent({String? search}) async {
  var filterData = [];

  if (search != null && search.trim() != "") {
    filterData = [
      ...filterData,
      {"field": "title", "value": search, "operand": 6}
    ];
  }
  final dio = Dio();
  final response = await dio.post('${baseURL}Event/paginate',
      data: {"limit": -1, "filters": filterData});
  return response;
}

Future<dynamic> getEventByStreetId(int? streetId) async {
  var filterData = [];

  final dio = Dio();
  final response = await dio.get('${baseURL}Event/Street/$streetId');
  return response.data;
}

Future<dynamic> getEventById({String? id}) async {
  final dio = Dio();
  final response = await dio.get('${baseURL}Event/$id');
  return response.data;
}
