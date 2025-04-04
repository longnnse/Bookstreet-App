import 'package:flutter/material.dart';
import 'package:mapmobile/models/map_model.dart';
import 'package:mapmobile/services/auth_service.dart';
import 'package:mapmobile/services/preferences_manager.dart';
import 'package:mapmobile/shared/text.dart';
import 'package:provider/provider.dart';

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
                      callback();
                    },
                    child: const Text(
                      'Đăng xuất',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              )
          ],
        ),
      ),
    );
  }
}
