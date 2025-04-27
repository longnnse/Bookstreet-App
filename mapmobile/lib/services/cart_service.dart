import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapmobile/models/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const String _cartKey = 'user_cart';

  // 👇 Notifier để các widget khác có thể lắng nghe thay đổi
  static final ValueNotifier<int> cartCountNotifier = ValueNotifier<int>(0);

  Future<void> _updateNotifier() async {
    final items = await getCartItems();
    final count = items.fold(0, (sum, item) => sum + item.quantity);
    cartCountNotifier.value = count;
  }

  Future<List<CartItem>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartData = prefs.getString(_cartKey);
    if (cartData == null) return [];
    List<dynamic> items = jsonDecode(cartData);
    return items.map((item) => CartItem.fromJson(item)).toList();
  }

  Future<void> addToCart(CartItem item) async {
    final prefs = await SharedPreferences.getInstance();
    List<CartItem> currentCart = await getCartItems();

    // First check by productId
    int existingIndexByProductId =
        currentCart.indexWhere((i) => i.productId == item.productId);

    // Then check by ISBN
    int existingIndexByIsbn =
        currentCart.indexWhere((i) => i.isbn == item.isbn);

    if (existingIndexByProductId != -1) {
      // If found by productId, increment quantity
      currentCart[existingIndexByProductId].quantity += 1;
    } else if (existingIndexByIsbn != -1) {
      // If found by ISBN but different productId, increment quantity
      currentCart[existingIndexByIsbn].quantity += 1;
    } else {
      // If not found by either, add new item
      currentCart.add(item);
    }

    await prefs.setString(
      _cartKey,
      jsonEncode(currentCart.map((i) => i.toJson()).toList()),
    );

    await _updateNotifier();
  }

  Future<void> removeFromCart(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    List<CartItem> currentCart = await getCartItems();
    currentCart.removeWhere((item) => item.productId == productId);

    await prefs.setString(
      _cartKey,
      jsonEncode(currentCart.map((i) => i.toJson()).toList()),
    );

    await _updateNotifier(); // 👈 Gọi cập nhật
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    List<CartItem> currentCart = await getCartItems();

    int index = currentCart.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      currentCart[index].quantity = quantity;
      if (quantity <= 0) {
        currentCart.removeAt(index);
      }
    }

    await prefs.setString(
      _cartKey,
      jsonEncode(currentCart.map((i) => i.toJson()).toList()),
    );

    await _updateNotifier(); // 👈 Gọi cập nhật
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
    cartCountNotifier.value = 0; // 👈 reset notifier
  }
}
