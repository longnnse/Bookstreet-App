import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapmobile/shared/currenttime.dart';
import 'package:mapmobile/shared/iconbtn.dart';
import 'package:mapmobile/shared/text.dart';
import 'package:mapmobile/shared/textfield.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.onTextChange});
  final Function onTextChange;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Flexible(
              flex: 1,
              child: Row(
                children: [
                  IconBtn(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () {
                      context.pop();
                    },
                  ),
                  IconBtn(
                    icon: Icons.home,
                    onTap: () {
                      context.push("/welcome");
                    },
                  ),
                  SizedBox(
                      width: 300,
                      child: SearchTextField(
                        onTextChange: onTextChange,
                      ))
                ],
              )),
          const Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [BoldLGText(text: "VN"), Currenttime()],
              ))
        ],
      ),
    );
  }
}
