import 'package:flutter/material.dart';
import 'package:mapmobile/models/map_model.dart';
import 'package:mapmobile/pages/cart/cart_page.dart';
import 'package:mapmobile/services/auth_service.dart';
import 'package:mapmobile/services/cart_service.dart';
import 'package:mapmobile/services/preferences_manager.dart';
import 'package:mapmobile/shared/text.dart';
import 'package:provider/provider.dart';
import 'package:mapmobile/pages/auth/login_page.dart';
import 'package:mapmobile/common/widgets/cart_button.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.callback});
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 1))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Consumer<MapModel>(
                builder: (context, value, child) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GradientText(
                          value.streetName,
                          style: const TextStyle(fontSize: 25),
                        ),
                        const Text(
                          "Mỗi trải nhiệm, một niềm vui",
                          style: TextStyle(fontSize: 15),
                        )
                      ],
                    )),
            Row(
              children: [
                CartButton(
                  customOnPressed: () async {
                    if (PreferencesManager.getUserData() != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartPage(),
                        ),
                      );
                    } else {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                      if (result != null && result) {
                        callback();
                      }
                    }
                  },
                ),
                const SizedBox(width: 24),
                if (PreferencesManager.getUserData() != null)
                  Column(
                    children: [
                      Text(
                        'Xin chào, ${PreferencesManager.getUserData()?['user']['fullName'] ?? ''}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          await AuthService().logout();
                          await CartService().clearCart();
                          callback();
                        },
                        child: const Text(
                          'Đăng xuất',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                      if (result != null && result) {
                        callback();
                      }
                    },
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
