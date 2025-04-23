import 'package:flutter/material.dart';
import 'package:mapmobile/common/widgets/show_message.dart';
import 'package:mapmobile/pages/Membership/transaction_history_page.dart';
import 'package:mapmobile/pages/Membership/wallet_topup_page.dart';
import 'package:mapmobile/services/customer_service.dart';
import 'package:mapmobile/services/preferences_manager.dart';
import 'package:mapmobile/util/util.dart';

class MembershipInfoPage extends StatefulWidget {
  const MembershipInfoPage({super.key});

  @override
  State<MembershipInfoPage> createState() => _MembershipInfoPageState();
}

class _MembershipInfoPageState extends State<MembershipInfoPage> {
  final CustomerService _customerService = CustomerService();
  bool _isLoading = true;
  Map<String, dynamic> _walletBalance = {};
  String _userName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _userName = PreferencesManager.getUserData()?['user']['fullName'];
      await _loadMembershipInfo();
    });
  }

  Future<void> _loadMembershipInfo() async {
    try {
      final walletBalance = await _customerService.getWalletBalance();
      setState(() {
        _walletBalance = walletBalance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ShowMessage.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin thành viên'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadMembershipInfo,
        child: ListView(
          children: [
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào, $_userName!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB60C00),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildWalletCard(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildPointsCard()),
                        Expanded(child: _buildOrderCard()),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ví thành viên',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.account_balance_wallet, size: 32),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Số dư hiện tại',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${formatToVND(_walletBalance['balance'])} VND',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB60C00),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WalletTopUpPage(),
                        ),
                      );
                      if (result != null && result) {
                        _loadMembershipInfo();
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Nạp tiền',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB60C00),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionHistoryPage(
                          type: TransactionHistoryType.wallet,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.history),
                    label: const Text('Lịch sử giao dịch'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFB60C00),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFB60C00)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Điểm tích lũy',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.stars, size: 32),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Điểm hiện tại',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_walletBalance['points'] ?? 0} điểm',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB60C00),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionHistoryPage(
                        type: TransactionHistoryType.points,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('Xem lịch sử điểm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFB60C00),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFFB60C00)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lịch sử đơn hàng',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.receipt_long, size: 24),
              ],
            ),
            const SizedBox(height: 120),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionHistoryPage(
                        type: TransactionHistoryType.orders,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('Xem lịch sử mua hàng'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFB60C00),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFFB60C00)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
