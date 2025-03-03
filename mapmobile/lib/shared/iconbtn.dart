import 'package:flutter/material.dart';

class IconBtn extends StatelessWidget {
  IconBtn(
      {super.key,
      required this.icon,
      this.bgColor = const Color.fromARGB(255, 198, 13, 0),
      this.color = Colors.white,
      required this.onTap});
  final IconData icon;
  final Color bgColor;
  final Color color;
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(10)),
        child: Icon(
          icon,
          color: color,
        ),
      ),
    );
  }
}
