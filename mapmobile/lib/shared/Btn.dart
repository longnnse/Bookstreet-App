import 'package:flutter/material.dart';
import 'package:mapmobile/shared/text.dart';

class Btn extends StatelessWidget {
  Btn(
      {super.key,
      required this.content,
      this.bgColor = const Color.fromARGB(255, 198, 13, 0),
      this.color = Colors.white,
      required this.onTap});
  final String content;
  final Color bgColor;
  final Color color;
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 60),
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(10)),
        child: DynamicText(
          text: content,
          textStyle:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
