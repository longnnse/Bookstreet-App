import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapmobile/shared/header.dart';
import 'package:mapmobile/services/customerservice.dart';
import 'package:mapmobile/shared/text.dart';

class Overall extends StatefulWidget {
  const Overall({super.key, this.phone});
  final String? phone;

  @override
  State<Overall> createState() => _OverallState();
}

class _OverallState extends State<Overall> {
  List<dynamic> records = [];

  @override
  void initState() {
    super.initState();

    getAllRecord(widget.phone).then((res) {
      setState(() {
        records = res['data']['list'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double parentwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 40),
            child: Header(),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 60),
            child: const DynamicText(
                text: "Thông tin điểm",
                textStyle: TextStyle(
                    color: Color.fromARGB(255, 182, 12, 0),
                    fontSize: 40,
                    fontWeight: FontWeight.bold)),
          ),
          Container(
            width: parentwidth / 2,
            margin: const EdgeInsets.only(bottom: 40),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 231, 226, 255)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DynamicText(
                      text: "Điểm tại các nhà sách",
                      textStyle: TextStyle(fontSize: 20),
                    ),
                    Icon(Icons.sentiment_satisfied)
                  ],
                ),
                const DynamicText(text: "Các tích lũy của bạn"),
                ...records.map((r) => Container(
                      decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(width: 0.3))),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DynamicText(
                            text: r['storeName'],
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              DynamicText(text: '${r['point']} pts'),
                              InkWell(
                                child: InkWell(
                                  onTap: () {
                                    context.push(
                                        '/pointHistory/${r['customerId']}/${r['storeId']}');
                                  },
                                  child: Container(
                                    color: Colors.red,
                                    padding: const EdgeInsets.all(2),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ))
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.push("/welcome");
            },
            style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8))),
                backgroundColor: const Color.fromARGB(255, 206, 14, 0)),
            child: const DynamicText(
              text: "Thoát",
              textStyle: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
