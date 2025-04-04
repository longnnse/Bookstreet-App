import 'package:dio/dio.dart';
import 'package:mapmobile/services/network_service.dart';

class PaymentService {
  final Dio _dio = NetworkService().dio;

  Future<dynamic> createPaymentUrl({
    int? amount,
  }) async {
    final response = await _dio.post('VNPay/CreatePaymentUrl', data: {
      'amount': amount,
    });
    return response.data;
  }

  Future<dynamic> paymentCallback() async {
    final response = await _dio.get('VNPay/PaymentCallback');
    return response.data;
  }
}
