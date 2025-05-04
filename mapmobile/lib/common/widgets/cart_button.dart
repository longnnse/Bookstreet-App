import 'package:flutter/material.dart';
import 'package:mapmobile/pages/cart/cart_page.dart';
import 'package:mapmobile/services/cart_service.dart';
import 'package:mapmobile/services/preferences_manager.dart';

class CartButton extends StatelessWidget {
  const CartButton({super.key, this.customOnPressed});
  final VoidCallback? customOnPressed;

  @override
  Widget build(BuildContext context) {
    return PreferencesManager.getUserData() != null
        ? ValueListenableBuilder<int>(
            valueListenable: CartService.cartCountNotifier,
            builder: (context, count, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      if (customOnPressed != null) {
                        customOnPressed!();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartPage(),
                          ),
                        );
                      }
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          )
        : const SizedBox();
  }
}
