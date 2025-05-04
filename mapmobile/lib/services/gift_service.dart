import 'package:mapmobile/services/api.dart';
import 'package:mapmobile/services/network_service.dart';

class GiftService {
  final _dio = NetworkService().dio;

  Future<dynamic> getAllGift() async {
    final response = await _dio.post('${baseURL}Gift/paginate', data: {
      "limit": -1,
    });
    return response.data['data']['list'];
  }

  Future<dynamic> getGiftById(String id) async {
    final response = await _dio.get('${baseURL}Gift/$id');
    return response.data['data'];
  }
}
