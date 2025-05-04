import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:mapmobile/common/widgets/show_message.dart';
import 'package:mapmobile/models/cart_item.dart';
import 'package:mapmobile/services/cart_service.dart';
import 'package:mapmobile/services/order_service.dart';
import 'package:mapmobile/pages/cart/checkout_success_page.dart';

class OrderConfirmationPage extends StatefulWidget {
  final List<CartItem> cartItems;
  const OrderConfirmationPage({
    super.key,
    required this.cartItems,
  });

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  String _otp = '';
  bool isLoading = true;
  final OrderService _orderService = OrderService();
  final CartService _cartService = CartService();

  Map<String, dynamic> orderDetails = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _orderService.createOrder(widget.cartItems).then((order) {
        if (order['success']) {
          setState(() => isLoading = false);
          ShowMessage.showSuccess(context, order['message']);
          orderDetails = order;
        } else {
          setState(() => isLoading = false);
          ShowMessage.showError(context, order['message']);
          Navigator.pop(context);
        }
      });
    });
  }

  Future<void> _onOTPCompleted(String otp) async {
    setState(() => isLoading = true);

    // Then checkout with OTP
    final data = await _orderService.checkoutOrder(
      orderId: orderDetails['data']['orderId']['orderId'],
      otp: otp,
    );

    if (data['success']) {
      await _cartService.clearCart();
      setState(() => isLoading = false);

      // Calculate total price
      double totalPrice = widget.cartItems
          .fold(0, (sum, item) => sum + (item.price * item.quantity));

      // Navigate to success page
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CheckoutSuccessPage(
              orderId: orderDetails['data']['orderId']['orderId'].toString(),
              cartItems: widget.cartItems,
              totalPrice: totalPrice,
              orderDate: orderDetails['data']['orderId']['createDate'],
            ),
          ),
        );
      }
    } else {
      setState(() => isLoading = false);
      ShowMessage.showError(context, data['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Xác nhận đơn hàng',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nhập mã OTP',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Vui lòng nhập mã OTP 6 chữ số đã được gửi đến số điện thoại của bạn',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    OtpTextField(
                      numberOfFields: 6,
                      borderColor: Colors.blue,
                      focusedBorderColor: Colors.blue,
                      showFieldAsBox: true,
                      borderRadius: BorderRadius.circular(12),
                      fieldWidth: 45,
                      fieldHeight: 60,
                      keyboardType: TextInputType.number,
                      textStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      onSubmit: (String code) {
                        setState(() {
                          _otp = code;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          _onOTPCompleted(_otp);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Không nhận được mã OTP?",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Implement resend OTP logic
                          },
                          child: const Text(
                            'Gửi lại',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
