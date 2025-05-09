import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mapmobile/services/network_service.dart';

class EventService {
  final Dio _dio = NetworkService().dio;

  Future<dynamic> getEvent({String? search, required int streetId}) async {
    try {
      var filterData = [
        {
          "field": "Location.Area.StreetId",
          "value": streetId.toString(),
          "operand": 0
        },
      ];

      if (search != null && search.trim() != "") {
        filterData = [
          ...filterData,
          {"field": "title", "value": search, "operand": 6},
        ];
      }

      final response = await _dio
          .post('Event/paginate', data: {"limit": -1, "filters": filterData});
      return response.data['data']['list'];
    } catch (e) {
      debugPrint('❌ Get event error: $e');
      rethrow;
    }
  }

  Future<dynamic> getEventById({String? id}) async {
    try {
      final response = await _dio.get('Event/$id');
      return response.data['data'];
    } catch (e) {
      debugPrint('❌ Get event by ID error: $e');
      rethrow;
    }
  }
}
