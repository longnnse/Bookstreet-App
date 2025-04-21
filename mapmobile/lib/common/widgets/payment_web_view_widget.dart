import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mapmobile/common/widgets/show_message.dart';

class PaymentWebViewWidget extends StatefulWidget {
  final String paymentUrl;

  const PaymentWebViewWidget({super.key, required this.paymentUrl});

  @override
  State<PaymentWebViewWidget> createState() => _PaymentWebViewWidgetState();
}

class _PaymentWebViewWidgetState extends State<PaymentWebViewWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.paymentUrl))
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          if (url.contains("status=success")) {
            _handlePaymentSuccess(url);
          } else if (url.contains("status=failed")) {
            _handlePaymentFailure(url);
          }
        },
      ));
  }

  void _handlePaymentSuccess(String url) {
    ShowMessage.showSuccess(context, "Thanh toán thành công!");
    context.pop(true);
  }

  void _handlePaymentFailure(String url) {
    ShowMessage.showError(context, "Thanh toán thất bại!");
    context.pop();
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content:
            const Text('Bạn có chắc chắn muốn thoát khỏi trang thanh toán?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool result, data) {
        if (result) {
          _onWillPop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Thanh toán VNPay")),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}
