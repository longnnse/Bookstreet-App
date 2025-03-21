import 'package:flutter/material.dart';
import 'package:mapmobile/models/map_model.dart';
import 'package:mapmobile/shared/currenttime.dart';
import 'package:mapmobile/shared/text.dart';
import 'package:mapmobile/util/util.dart';
import 'package:provider/provider.dart';

class Header extends StatelessWidget {
  const Header({super.key});

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
                const Currenttime(),
                BoldLGText(
                  text: getCurrentDate(),
                  color: Colors.black54,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
