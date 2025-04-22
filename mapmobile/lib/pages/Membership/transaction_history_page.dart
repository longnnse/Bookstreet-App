import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapmobile/services/customer_service.dart';
import 'package:mapmobile/services/point_history.dart';
import 'package:mapmobile/services/preferences_manager.dart';
import 'package:mapmobile/util/util.dart';
import 'package:mapmobile/pages/Order/order_detail_page.dart';

enum TransactionHistoryType {
  wallet,
  points,
  orders,
}

enum TransactionType {
  deposit,
  withdrawal,
}

enum PointStatus {
  deposit,
  withdrawal,
}

extension TransactionTypeExtension on TransactionType {
  static TransactionType fromValue(int value) {
    switch (value) {
      case 1:
        return TransactionType.deposit;
      case 3:
        return TransactionType.withdrawal;
      default:
        return TransactionType.deposit;
    }
  }

  IconData get icon => switch (this) {
        TransactionType.deposit => Icons.wallet,
        TransactionType.withdrawal => Icons.payment,
      };

  Color get color => switch (this) {
        TransactionType.deposit => Colors.green,
        TransactionType.withdrawal => Colors.red,
      };
}

extension PointStatusExtension on PointStatus {
  static PointStatus fromValue(int value) {
    switch (value) {
      case 2:
        return PointStatus.deposit;
      case 1:
        return PointStatus.withdrawal;
      default:
        return PointStatus.deposit;
    }
  }

  IconData get icon => switch (this) {
        PointStatus.deposit => Icons.add,
        PointStatus.withdrawal => Icons.remove,
      };

  Color get color => switch (this) {
        PointStatus.deposit => Colors.green,
        PointStatus.withdrawal => Colors.red,
      };
}

class TransactionHistoryPage extends StatefulWidget {
  final TransactionHistoryType type;

  const TransactionHistoryPage({
    super.key,
    required this.type,
  });

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final CustomerService _customerService = CustomerService();
  bool _isLoading = true;

  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _points = [];
  List<Map<String, dynamic>> _orders = [];
  final PointHistoryService _pointHistoryService = PointHistoryService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.type == TransactionHistoryType.points) {
        _loadPointHistory();
      } else if (widget.type == TransactionHistoryType.orders) {
        _loadOrders();
      } else {
        _loadTransactions();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _customerService.getTransactionHistory();

      setState(() {
        _transactions =
            transactions.map((item) => item as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load transactions: $e')),
      );
    }
  }

  Future<void> _loadPointHistory() async {
    final customerId = PreferencesManager.getUserData()?['user']['customerId'];
    if (customerId == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load point history: cannot get customer id'),
        ),
      );
      return;
    }

    try {
      final points =
          await _pointHistoryService.getPointHistory(customerId.toString());

      setState(() {
        _points = points.map((item) => item as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load point history: $e')),
      );
    }
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await _customerService.getOrderHistory();
      setState(() {
        _orders = orders.map((item) => item as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load orders: $e')),
      );
    }
  }

  Future<void> _refreshTransactions() async {
    if (widget.type == TransactionHistoryType.points) {
      await _loadPointHistory();
    } else if (widget.type == TransactionHistoryType.orders) {
      await _loadOrders();
    } else {
      await _loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == TransactionHistoryType.wallet
              ? 'Lịch sử giao dịch'
              : widget.type == TransactionHistoryType.points
                  ? 'Lịch sử tích điểm'
                  : 'Lịch sử đơn hàng',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTransactions,
        child: Stack(
          children: [
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (!_isLoading)
              _transactions.isEmpty && _points.isEmpty && _orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No data found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : widget.type == TransactionHistoryType.points
                      ? _pointHistoryWidget()
                      : widget.type == TransactionHistoryType.orders
                          ? _orderHistoryWidget()
                          : _transactionHistoryWidget(),
          ],
        ),
      ),
    );
  }

  Widget _pointHistoryWidget() {
    return ListView.builder(
      itemCount: _points.length,
      itemBuilder: (context, index) {
        final point = _points[index];

        final pointStatus = PointStatusExtension.fromValue(point['status']);
        final pointAmount = point['pointAmount'].toInt();
        final storeName = point['storeName'];
        final invoiceCode = point['invoiceCode'];

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: pointStatus.color.withAlpha(100),
              child: Icon(
                pointStatus.icon,
                color: pointStatus.color,
              ),
            ),
            title: Text(
              '$pointAmount điểm',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: pointStatus.color,
              ),
            ),
            subtitle: Text(
              'Tại $storeName cho hóa đơn $invoiceCode',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            trailing: Text(
              DateFormat('dd/MM/yyyy')
                  .format(DateTime.parse(point['statusChangedAt'])),
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chi tiết điểm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bạn được cộng $pointAmount điểm tại $storeName cho hóa đơn $invoiceCode',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _orderHistoryWidget() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      reverse: true,
      itemBuilder: (context, index) {
        final order = _orders[index];
        final orderStatus = _getOrderStatus(order['status'] ?? 1);
        final orderDate =
            DateTime.parse(order['createDate'] ?? DateTime.now().toString());
        final storeName = order['storeName'] ?? 'Unknown Store';
        final subTotal = order['subTotal'] ?? 0.0;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: orderStatus.color.withAlpha(100),
              child: Icon(
                orderStatus.icon,
                color: orderStatus.color,
              ),
            ),
            title: Text(
              'Đơn hàng #${order['orderId']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                Text(
                  DateFormat('HH:mm dd/MM/yyyy').format(orderDate),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatToVND(subTotal),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  orderStatus.text,
                  style: TextStyle(
                    color: orderStatus.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OrderDetailPage(orderId: order['orderId'].toString()),
                ),
              );
            },
          ),
        );
      },
    );
  }

  OrderStatus _getOrderStatus(int status) {
    switch (status) {
      case 1:
        return OrderStatus(
          text: 'Đang chờ xử lý',
          color: Colors.orange,
          icon: Icons.pending,
        );
      case 2:
        return OrderStatus(
          text: 'Đang xử lý',
          color: Colors.blue,
          icon: Icons.shopping_cart,
        );
      case 3:
        return OrderStatus(
          text: 'Hoàn thành',
          color: Colors.green,
          icon: Icons.check_circle,
        );
      case 4:
        return OrderStatus(
          text: 'Đã hủy',
          color: Colors.red,
          icon: Icons.cancel,
        );
      default:
        return OrderStatus(
          text: 'Không xác định',
          color: Colors.grey,
          icon: Icons.help,
        );
    }
  }

  Widget _transactionHistoryWidget() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];

        final transactionType =
            TransactionTypeExtension.fromValue(transaction['transactionType']);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: transactionType.color.withAlpha(100),
              child: Icon(
                transactionType.icon,
                color: transactionType.color,
              ),
            ),
            title: Text(
              transaction['description'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              DateFormat('HH:mm dd/MM/yyyy').format(DateTime.parse(
                  transaction['transactionDate'].toString().split('.')[0])),
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            trailing: Text(
              '${transactionType == TransactionType.deposit ? '+' : '-'}${formatToVND(transaction['amount'])}',
              style: TextStyle(
                color: transactionType.color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        );
      },
    );
  }
}

class OrderStatus {
  final String text;
  final Color color;
  final IconData icon;

  OrderStatus({
    required this.text,
    required this.color,
    required this.icon,
  });
}
