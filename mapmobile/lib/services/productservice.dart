import 'package:dio/dio.dart';
import 'package:mapmobile/services/api.dart';

Future<dynamic> getAllProduct() async {
  final dio = Dio();
  final response = await dio.get('${baseURL}Product');
  return response;
}

Future<dynamic> getBook({
  int? categoryId,
  int? genreId,
  String? search,
  int? streetId,
  int? storeId,
  int? distributorId,
  double? minPrice,
  double? maxPrice,
}) async {
  var filterData = [
    {"field": "ProductTypeId", "value": "1", "operand": 0}
  ];
  if (categoryId != null && categoryId != 0) {
    filterData = [
      ...filterData,
      {"field": "CategoryId", "value": "$categoryId", "operand": 0}
    ];
  }

  if (genreId != null && genreId != 0) {
    filterData = [
      ...filterData,
      {"field": "Book.GenreId", "value": "$genreId", "operand": 0}
    ];
  }

  if (streetId != null && streetId != 0) {
    filterData = [
      ...filterData,
      {"field": "StreetId", "value": "$streetId", "operand": 0}
    ];
  }

  if (storeId != null && storeId != 0) {
    filterData = [
      ...filterData,
      {"field": "storeid", "value": "$storeId", "operand": 0}
    ];
  }

  if (search != null && search.trim() != "") {
    filterData = [
      ...filterData,
      {"field": "productName", "value": search, "operand": 6}
    ];
  }

  if (distributorId != null && distributorId != 0) {
    filterData = [
      ...filterData,
      {"field": "book.distributorid", "value": "$distributorId", "operand": 0}
    ];
  }

  if (minPrice != null && minPrice != 0 || maxPrice != null && maxPrice != 0) {
    filterData = [
      ...filterData,
      {"field": "price", "value": minPrice.toString(), "operand": 3},
      {"field": "price", "value": maxPrice.toString(), "operand": 5}
    ];
  }

  final dio = Dio();
  final response = await dio.post('${baseURL}Product/paginate',
      data: {"limit": -1, "filters": filterData});
  return response;
}

Future<dynamic> getSouvenir(
    {int? categoryId, int? genreId, String? search, int? streetId}) async {
  var filterData = [
    {"field": "ProductTypeId", "value": "2", "operand": 0}
  ];
  if (categoryId != null && categoryId != 0) {
    filterData = [
      ...filterData,
      {"field": "CategoryId", "value": "$categoryId", "operand": 0}
    ];
  }

  if (genreId != null && genreId != 0) {
    filterData = [
      ...filterData,
      {"field": "Book.GenreId", "value": "$genreId", "operand": 0}
    ];
  }

  if (streetId != null && streetId != 0) {
    filterData = [
      ...filterData,
      {"field": "StreetId", "value": "$streetId", "operand": 0}
    ];
  }

  if (search != null && search.trim() != "") {
    filterData = [
      ...filterData,
      {"field": "productName", "value": search, "operand": 6}
    ];
  }

  final dio = Dio();
  final response = await dio.post('${baseURL}Product/paginate',
      data: {"limit": -1, "filters": filterData});
  return response;
}

Future<dynamic> getProductById(String? id) async {
  final dio = Dio();
  final response = await dio.get('${baseURL}Product/$id');
  return response.data;
}
