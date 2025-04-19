import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_item.dart';

class CartService {
  static const String _cartKey = 'user_cart';

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

    int existingIndex =
        currentCart.indexWhere((i) => i.productId == item.productId);
    if (existingIndex != -1) {
      currentCart[existingIndex].quantity += 1;
    } else {
      currentCart.add(item);
    }

    await prefs.setString(
      _cartKey,
      jsonEncode(currentCart.map((i) => i.toJson()).toList()),
    );
  }

  Future<void> removeFromCart(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    List<CartItem> currentCart = await getCartItems();
    currentCart.removeWhere((item) => item.productId == productId);

    await prefs.setString(
      _cartKey,
      jsonEncode(currentCart.map((i) => i.toJson()).toList()),
    );
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
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  
}
