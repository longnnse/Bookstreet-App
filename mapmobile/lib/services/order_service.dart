import 'package:dio/dio.dart';
import 'package:mapmobile/models/cart_item.dart';
import 'package:mapmobile/services/network_service.dart';

class OrderService {
  final Dio _dio = NetworkService().dio;

  Future<dynamic> createOrder(List<CartItem> cartItems) async {
    final response = await _dio.post('Order/CreateOrder', data: {
      'orderDetails': cartItems
          .map((item) => {
                'productId': int.parse(item.productId),
                'quantity': item.quantity,
              })
          .toList(),
    });
    return response.data;
  }

  Future<dynamic> checkoutOrder({
    int? orderId,
    String? otp,
  }) async {
    final response = await _dio.post('Order/CheckoutOrder', data: {
      'orderId': orderId,
      'otp': otp,
    });
    return response.data;
  }
}
