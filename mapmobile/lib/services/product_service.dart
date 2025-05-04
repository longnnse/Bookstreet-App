import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mapmobile/services/network_service.dart';

class ProductService {
  final Dio _dio = NetworkService().dio;

  Future<dynamic> filterProducts({
    int? categoryId,
    int? genreId,
    String? search,
    int? streetId,
    int? storeId,
    int? distributorId,
    double? minPrice,
    double? maxPrice,
    int? productTypeId,
  }) async {
    try {
      var filterData = [];

      // Add product type filter if specified
      if (productTypeId != null) {
        filterData = [
          {"field": "ProductTypeId", "value": "$productTypeId", "operand": 0}
        ];
      }

      // Add category filter for all
      if (categoryId != null && categoryId != 0) {
        filterData = [
          ...filterData,
          {"field": "CategoryId", "value": "$categoryId", "operand": 0}
        ];
      }

      // Add genre filter for books
      if (productTypeId == 1 && genreId != null && genreId != 0) {
        filterData = [
          ...filterData,
          {"field": "Book.GenreId", "value": "$genreId", "operand": 0}
        ];
      }

      // Add street filter
      if (streetId != null && streetId != 0) {
        filterData = [
          ...filterData,
          {"field": "StreetId", "value": "$streetId", "operand": 0}
        ];
      }

      // Add store filter
      if (storeId != null && storeId != 0) {
        filterData = [
          ...filterData,
          {"field": "storeid", "value": "$storeId", "operand": 0}
        ];
      }

      // Add search filter
      if (search != null && search.trim() != "") {
        filterData = [
          ...filterData,
          {"field": "productName", "value": search, "operand": 6}
        ];
      }

      // Add distributor filter for books
      if (productTypeId == 1 && distributorId != null && distributorId != 0) {
        filterData = [
          ...filterData,
          {
            "field": "book.distributorid",
            "value": "$distributorId",
            "operand": 0
          }
        ];
      }

      // Add price range filter
      if (minPrice != null && minPrice != 0 ||
          maxPrice != null && maxPrice != 0) {
        filterData = [
          ...filterData,
          {"field": "price", "value": minPrice.toString(), "operand": 3},
          {"field": "price", "value": maxPrice.toString(), "operand": 5}
        ];
      }

      final response = await _dio
          .post('Product/paginate', data: {"limit": -1, "filters": filterData});
      return response.data['data']['list'];
    } catch (e) {
      debugPrint('❌ Error getting products: $e');
      rethrow;
    }
  }

  Future<dynamic> getProductById(String? id) async {
    final response = await _dio.get('Product/$id');
    return response.data['data'];
  }
}
