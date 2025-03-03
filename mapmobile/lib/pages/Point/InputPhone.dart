import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapmobile/shared/header.dart';
import 'package:mapmobile/shared/text.dart';
import 'package:mapmobile/util/util.dart';

class Inputphone extends StatefulWidget {
  const Inputphone({super.key});

  @override
  State<Inputphone> createState() => _InputphoneState();
}

class _InputphoneState extends State<Inputphone> {
  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    // Giải phóng controller khi widget bị huỷ
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double parentwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Container(margin: const EdgeInsets.only(bottom: 40), child: Header()),
          Container(
            margin: const EdgeInsets.only(bottom: 60),
            child: const DynamicText(
                text: "Điểm tích lũy của bạn",
                textStyle: TextStyle(
                    color: Color.fromARGB(255, 182, 12, 0),
                    fontSize: 40,
                    fontWeight: FontWeight.bold)),
          ),
          Container(
            width: parentwidth / 2,
            margin: const EdgeInsets.only(bottom: 30),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                  fillColor: const Color.fromARGB(255, 218, 240, 255),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Điền số điện thoại')));
                return;
              }

              if (!isValidPhoneNumber(_controller.text)) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sai số điện thoại')));
                return;
              }

              context.push("/pointHistory/${_controller.text}");
            },
            style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8))),
                backgroundColor: const Color.fromARGB(255, 206, 14, 0)),
            child: const DynamicText(
              text: "Tra cứu",
              textStyle: TextStyle(color: Colors.white),
            ),
          )
        ],
      )),
    );
  }
}
