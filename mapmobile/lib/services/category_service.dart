import 'package:mapmobile/services/api.dart';
import 'package:mapmobile/services/network_service.dart';

class CategoryService {
  final _dio = NetworkService().dio;

  Future<dynamic> getAllCategory(String productTypeId) async {
    final response = await _dio.post('${baseURL}Category/paginate', data: {
      "limit": -1,
      "filters": [
        {"field": "productTypeId", "value": productTypeId, "operand": 0}
      ]
    });
    return response.data['data']['list'];
  }
}
