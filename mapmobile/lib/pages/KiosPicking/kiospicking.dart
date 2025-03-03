import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapmobile/models/kios_model.dart';
import 'package:mapmobile/models/map_model.dart';
import 'package:mapmobile/shared/text.dart';
import 'package:provider/provider.dart';

class KiosPicking extends StatelessWidget {
  const KiosPicking({super.key});

  @override
  Widget build(BuildContext context) {
    double parentwidth = MediaQuery.of(context).size.width;
    double parentheight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const DynamicText(
                text: "Chọn vị trí kios của bạn",
                textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Consumer<MapModel>(
                builder: (context, value, child) {
                  final model = context.read<MapModel>();
                  return Row(
                    children: [
                      Flexible(flex: 1, child: Container()),
                      Flexible(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            height: parentheight - 100,
                            child: ListView.builder(
                              itemCount: model.locations.length,
                              itemBuilder: (context, index) {
                                dynamic loc = model.locations[index];
                                if (loc['kiosName'] != null) {
                                  return Consumer<KiosModel>(
                                      builder: (context, value, child) {
                                    final kiosmodel = context.read<KiosModel>();
                                    return InkWell(
                                      onTap: () {
                                        kiosmodel
                                            .setKiosId(loc['kiosId'])
                                            .setkiosName(loc['kiosName'])
                                            .setxLocation(loc['xLocation'])
                                            .setyLocation(loc['yLocation']);
                                        context.go("/Welcome");
                                      },
                                      child: Container(
                                        width: parentwidth / 2,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: const Color.fromARGB(
                                                255, 212, 229, 255)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 5),
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: DynamicText(
                                          text:
                                              "${loc['kiosName']} tại ${loc['areaName']}",
                                        ),
                                      ),
                                    );
                                  });
                                } else
                                  return Container();
                              },
                            ),
                          )),
                      Flexible(flex: 1, child: Container())
                    ],
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
