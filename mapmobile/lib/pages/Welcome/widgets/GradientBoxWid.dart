import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mapmobile/shared/box.dart';
import 'package:mapmobile/shared/text.dart';

List<Map<String, dynamic>> myList = [
  {
    'Icon': Icons.book,
    'Content': 'Thông tin sách',
    'link': '/books',
    'Color1': const Color.fromARGB(255, 255, 225, 197),
    'Color2': const Color.fromARGB(255, 255, 203, 14),
  },
  {
    'Icon': Icons.savings,
    'Content': 'Điểm tích lũy',
    'link': '/points',
    'Color1': Color.fromARGB(255, 255, 153, 153),
    'Color2': Color.fromARGB(255, 171, 0, 0),
  },
  {
    'Icon': Icons.redeem,
    'Content': 'Đồ lưu niệm',
    'link': '/souvenir',
    'Color1': const Color.fromARGB(255, 255, 201, 231),
    'Color2': const Color.fromARGB(255, 201, 0, 134),
  },
  {
    'Icon': Icons.event,
    'Content': 'Sự kiện',
    'link': '/event',
    'Color1': const Color.fromARGB(255, 216, 213, 255),
    'Color2': const Color.fromARGB(255, 78, 1, 179),
  },
];

class GradientWid extends StatelessWidget {
  const GradientWid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: myList.map((item) {
        return Flexible(
          flex: 1,
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.only(left: 20, top: 20, bottom: 50),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: item['Color2']),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GBoxWid(
                      Icon(
                        item['Icon'],
                        color: item['Color1'],
                        size: 50,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: const Alignment(0.8, 1),
                        colors: <Color>[
                          item['Color1'],
                          item['Color2']
                        ], // Gradient from https://learnui.design/tools/gradient-generator.html
                        tileMode: TileMode.mirror,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 40),
                      padding: const EdgeInsets.only(right: 50),
                      child: DynamicText(
                        text: item['Content'],
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto'),
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                  bottom: -10,
                  right: -10,
                  child: InkWell(
                    onTap: () {
                      print(item['link']);
                      context.push(item['link']);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 10),
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20))),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Icon(
                          Icons.north_east,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ))
            ],
          ),
        );
      }).toList(),
    );
  }
}

class GBoxWid extends StatelessWidget {
  const GBoxWid(this.icon,
      {super.key,
      this.gradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment(0.8, 1),
        colors: <Color>[
          Color(0xff1f005c),
          Color(0xff5b0060),
          Color(0xff870160),
          Color(0xffac255e),
          Color(0xffca485c),
          Color(0xffe16b5c),
          Color(0xfff39060),
          Color(0xffffb56b),
        ], // Gradient from https://learnui.design/tools/gradient-generator.html
        tileMode: TileMode.mirror,
      )});
  final Icon icon;
  final LinearGradient gradient;
  @override
  Widget build(BuildContext context) {
    return GradientBox(
      gradient: gradient,
      widget: Container(
        decoration: const BoxDecoration(),
        padding: const EdgeInsets.all(10),
        child: icon,
      ),
    );
  }
}
