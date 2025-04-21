import 'package:flutter/material.dart';
import 'package:mapmobile/pages/cart/order_confirmation_page.dart';
import '../../models/cart_item.dart';
import '../../services/cart_service.dart';
import '../../util/util.dart';

class CartPage extends StatefulWidget {
  const CartPage({
    super.key,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();

  List<CartItem> cartItems = [];
  bool isLoading = true;
  List<String> selectedItems = [];
  bool isSelectAll = false;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() => isLoading = true);
    final items = await _cartService.getCartItems();
    setState(() {
      cartItems = items;
      isLoading = false;
    });
  }

  void _toggleSelectAll() {
    setState(() {
      isSelectAll = !isSelectAll;
      if (isSelectAll) {
        selectedItems = cartItems.map((item) => item.productId).toList();
      } else {
        selectedItems.clear();
      }
    });
  }

  void _toggleItemSelection(String productId) {
    setState(() {
      if (selectedItems.contains(productId)) {
        selectedItems.remove(productId);
        isSelectAll = false;
      } else {
        selectedItems.add(productId);
        if (selectedItems.length == cartItems.length) {
          isSelectAll = true;
        }
      }
    });
  }

  Future<void> _removeSelectedItems() async {
    for (String productId in selectedItems) {
      await _cartService.removeFromCart(productId);
    }
    setState(() {
      selectedItems.clear();
      isSelectAll = false;
    });
    _loadCartItems();
  }

  double get totalAmount {
    return cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  Widget _buildCartItem(CartItem item) {
    final TextEditingController quantityController =
        TextEditingController(text: item.quantity.toString());
    bool isSelected = selectedItems.contains(item.productId);

    return Dismissible(
      key: Key(item.productId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        await _cartService.removeFromCart(item.productId);
        _loadCartItems();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleItemSelection(item.productId),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatToVND(item.price),
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () async {
                      int newQuantity = item.quantity - 1;
                      if (newQuantity > 0) {
                        await _cartService.updateQuantity(
                          item.productId,
                          newQuantity,
                        );
                        quantityController.text = newQuantity.toString();
                        _loadCartItems();
                      }
                    },
                  ),
                  SizedBox(
                    width: 40,
                    child: TextFormField(
                      controller: quantityController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) async {
                        if (value.isNotEmpty) {
                          int newQuantity = int.tryParse(value) ?? 1;
                          if (newQuantity > 0) {
                            await _cartService.updateQuantity(
                              item.productId,
                              newQuantity,
                            );
                            _loadCartItems();
                          }
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () async {
                      int newQuantity = item.quantity + 1;
                      await _cartService.updateQuantity(
                        item.productId,
                        newQuantity,
                      );
                      quantityController.text = newQuantity.toString();
                      _loadCartItems();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (cartItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isSelectAll,
                            onChanged: (_) => _toggleSelectAll(),
                          ),
                          Text(
                            selectedItems.isEmpty
                                ? 'Chọn tất cả'
                                : 'Đã chọn ${selectedItems.length}/${cartItems.length}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          if (selectedItems.isNotEmpty)
                            TextButton.icon(
                              onPressed: () async {
                                final shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Xóa sản phẩm đã chọn'),
                                    content: Text(
                                        'Bạn có chắc chắn muốn xóa ${selectedItems.length} sản phẩm đã chọn?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Xóa',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );

                                if (shouldDelete == true) {
                                  await _removeSelectedItems();
                                }
                              },
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              label: const Text(
                                'Xóa',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: cartItems.isEmpty
                      ? const Center(
                          child: Text(
                            'Giỏ hàng trống',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) =>
                              _buildCartItem(cartItems[index]),
                        ),
                ),
                if (cartItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(200),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Tổng tiền:',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              formatToVND(totalAmount),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderConfirmationPage(
                                  cartItems: cartItems,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                          ),
                          child: const Text(
                            'Thanh toán',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
