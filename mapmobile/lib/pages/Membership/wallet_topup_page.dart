import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapmobile/common/widgets/payment_web_view_widget.dart';
import 'package:mapmobile/common/widgets/show_message.dart';
import 'package:mapmobile/services/payment_service.dart';
import 'package:mapmobile/util/util.dart';

class WalletTopUpPage extends StatefulWidget {
  const WalletTopUpPage({super.key});

  @override
  State<WalletTopUpPage> createState() => _WalletTopUpPageState();
}

class _WalletTopUpPageState extends State<WalletTopUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  final _paymentService = PaymentService();

  final List<int> _presetAmounts = [50000, 100000, 200000, 500000];

  Future<void> _handleTopUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = int.parse(_amountController.text);
      final paymentData =
          await _paymentService.createPaymentUrl(amount: amount);
      final paymentUrl = paymentData['data'];

      if (!mounted) return;
      Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebViewWidget(paymentUrl: paymentUrl),
        ),
      ).then((result) {
        if (result != null && result) {
          // Payment was successful, pop with true to notify MembershipInfoPage
          Navigator.pop(context, true);
        }
      });
    } catch (e) {
      ShowMessage.showError(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nạp tiền vào ví'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Chọn số tiền',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _presetAmounts.map((amount) {
                      return ChoiceChip(
                        label: Text(
                          '${formatToVND(amount.toDouble())} VND',
                          style: TextStyle(
                            color: _amountController.text == amount.toString()
                                ? Colors.white
                                : const Color(0xFFB60C00),
                          ),
                        ),
                        selected: _amountController.text == amount.toString(),
                        onSelected: (selected) {
                          setState(() {
                            _amountController.text = amount.toString();
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFFB60C00),
                        side: const BorderSide(color: Color(0xFFB60C00)),
                        checkmarkColor: Colors.white,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Hoặc nhập số tiền tùy chọn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Số tiền (VND)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.money),
                      suffixText: 'VND',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số tiền';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null) {
                        return 'Vui lòng nhập số hợp lệ';
                      }
                      if (amount < 10000) {
                        return 'Số tiền tối thiểu là 10.000 VND';
                      }
                      if (amount > 10000000) {
                        return 'Số tiền tối đa là 10.000.000 VND';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleTopUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB60C00),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Tiếp tục thanh toán',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(
                        color: Color(0xFFB60C00),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
