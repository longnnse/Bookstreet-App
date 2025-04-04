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
      appBar: AppBar(
        title: const Text('Chọn vị trí kios của bạn'),
      ),
      body: SafeArea(
        child: Consumer<MapModel>(
          builder: (context, value, child) {
            final model = context.read<MapModel>();
            if (model.locations.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.lightBlueAccent.withAlpha(100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withAlpha(100),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: DynamicText(
                              text: "${loc['kiosName']} tại ${loc['areaName']}",
                              textStyle: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            );
          },
        ),
      ),
    );
  }
}
