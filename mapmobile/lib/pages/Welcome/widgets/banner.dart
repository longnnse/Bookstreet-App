import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapmobile/pages/Welcome/widgets/GradientBoxWid.dart';

class MyBanner extends StatelessWidget {
  const MyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            context.push("/map");
          },
          child: Container(
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            margin: const EdgeInsets.only(bottom: 30),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Image.asset('assets/images/mallbanner.jpg',
                fit: BoxFit.contain),
          ),
        ),
        const GradientWid()
      ],
    );
  }
}
