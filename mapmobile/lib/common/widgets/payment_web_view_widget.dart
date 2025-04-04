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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thanh toán VNPay")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
