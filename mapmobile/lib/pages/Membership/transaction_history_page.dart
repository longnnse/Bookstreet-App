import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapmobile/services/customer_service.dart';
import 'package:mapmobile/util/util.dart';

enum TransactionType {
  wallet,
  points,
}

class TransactionHistoryPage extends StatefulWidget {
  final TransactionType type;

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadTransactions();
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

  Future<void> _refreshTransactions() async {
    await _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTransactions,
          ),
        ],
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
              _transactions.isEmpty
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
                            'No transactions found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.withAlpha(100),
                              child: Icon(
                                widget.type == TransactionType.wallet
                                    ? Icons.account_balance_wallet
                                    : Icons.stars,
                                color: Colors.green,
                              ),
                            ),
                            title: Text(
                              transaction['description'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat('HH:mm dd/MM/yyyy').format(
                                  DateTime.parse(transaction['transactionDate']
                                      .toString()
                                      .split('.')[0])),
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Text(
                              widget.type == TransactionType.wallet
                                  ? '${transaction['amount'] >= 0 ? '+' : '-'}${formatToVND(transaction['amount'])}'
                                  : '${transaction['amount'] >= 0 ? '+' : '-'}${transaction['amount'].toInt()} points',
                              style: TextStyle(
                                color: transaction['amount'] >= 0
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ],
        ),
      ),
    );
  }
}
