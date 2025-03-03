import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapmobile/services/customerservice.dart';
import 'package:mapmobile/shared/text.dart';
import 'package:mapmobile/util/util.dart';
import 'package:mapmobile/shared/header.dart';

class PointHistory extends StatefulWidget {
  const PointHistory({super.key, this.phone});
  final String? phone;
  @override
  State<PointHistory> createState() => _PointHistoryState();
}

class _PointHistoryState extends State<PointHistory> {
  List<dynamic> histories = [];
  dynamic Cusinfo = {};
  @override
  void initState() {
    super.initState();
    getPointHistory2(widget.phone).then((res) {
      setState(() {
        histories = res['data']['list'];
      });
      getCustomer(histories[0]['customerId']).then((cusInfo) {
        setState(() {
          Cusinfo = cusInfo;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double parentwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 40),
              child: Header(),
            ),
            const Center(
              child: const DynamicText(
                  text: "Lịch sử tích điểm",
                  textStyle: TextStyle(
                      color: Color.fromARGB(255, 182, 12, 0),
                      fontSize: 40,
                      fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  DynamicText(
                    text:
                        "Xin chào ${Cusinfo['customerName'] ?? ""} - ${Cusinfo['point'] ?? 0} điểm",
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Color.fromARGB(255, 182, 12, 0)),
                  )
                ],
              ),
            ),
            Container(
              width: parentwidth / 5 * 3,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 0.3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DynamicText(
                    text: "Lịch sử tích điểm",
                    textStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  ...histories.map((h) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 3,
                              child: Wrap(
                                children: [
                                  DynamicText(
                                    text: h['giftId'] == null
                                        ? "Bạn nhận được ${h['pointAmount'] ?? 0} điểm cho đơn hàng ${h['amount'] ?? 0} đồng tại cửa hàng ${h['storeName']}"
                                        : "Bạn đã sử dụng ${h['pointAmount'] ?? 0} điểm để đổi ${h['quantity'] ?? 0} ${h['gift'] != null ? h['gift']['giftName'] : ""} tại cửa hàng ${h['storeName']}. Số điểm hiện tại là ${h['currentPoint'] ?? 0} điêm",
                                    textStyle: TextStyle(
                                        color: h['giftId'] == null
                                            ? Colors.green
                                            : Colors.red),
                                  )
                                ],
                              ),
                            ),
                            Flexible(
                                flex: 1,
                                child: DynamicText(
                                    text: formatDateTime(h['createdAt'])))
                          ])),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8))),
                          backgroundColor:
                              const Color.fromARGB(255, 206, 14, 0)),
                      child: const DynamicText(
                        text: "Quay lại",
                        textStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
