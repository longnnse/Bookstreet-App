import 'package:flutter/material.dart';
import 'package:mapmobile/models/kios_model.dart';
import 'package:mapmobile/models/map_model.dart';
import 'package:mapmobile/services/storeservice.dart';
import 'package:mapmobile/shared/header.dart';
import 'package:mapmobile/shared/networkimagefallback.dart';
import 'package:mapmobile/shared/text.dart';
import 'package:provider/provider.dart';

class FullMap extends StatefulWidget {
  const FullMap({super.key});

  @override
  State<FullMap> createState() => _FullMapState();
}

class _FullMapState extends State<FullMap> {
  dynamic selectedStore = null;

  dynamic getStoreOnTap(String storeId) {
    getStoreById(storeId).then((res) {
      setState(() {
        selectedStore = res;
      });
      showStore();
    });
  }

  dynamic showStore() {
    showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              clipBehavior: Clip.hardEdge,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 530,
                      width: double.infinity,
                      child: Container(),
                    ),
                    SizedBox(
                      height: 400,
                      width: double.infinity,
                      child: Image.asset(
                        "assets/images/bookDialogBanner.jpeg",
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    Positioned(
                        bottom: 0,
                        left: 30,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 200,
                              child: NetworkImageWithFallback(
                                  imageUrl: selectedStore['urlImage'],
                                  fallbackWidget: const Icon(Icons.error)),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: DynamicText(
                                text: selectedStore['storeName'],
                                textStyle: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ))
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  margin: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer),
                          DynamicText(
                              text:
                                  "${selectedStore['openingHours'] ?? ""} - ${selectedStore['closingHours'] ?? ""}",
                              textStyle: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      DynamicText(
                          text: selectedStore['description'],
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold))
                    ],
                  ),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    double parentwidth = MediaQuery.of(context).size.width;
    double parentheight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 40),
              child: Header(),
            ),
            Consumer<MapModel>(builder: (context, value, child) {
              final model = context.read<MapModel>();
              return Stack(
                children: [
                  Consumer<MapModel>(builder: (context, value, child) {
                    final model = context.read<MapModel>();
                    return NetworkImageWithFallback(
                        imageUrl: model.imageUrl,
                        fallbackWidget: const Icon(Icons.error));
                  }),
                  ...model.locations.map((loc) {
                    if (loc['xLocation'] != null &&
                        loc['yLocation'] != null &&
                        loc['storeId'] != 0) {
                      return Positioned(
                        left: loc['xLocation'] * parentwidth - parentwidth / 34,
                        top: loc['yLocation'] * parentheight / 2.1 +
                            loc['yLocation'] * parentheight / 20 -
                            20,
                        child: InkWell(
                          onTap: () => getStoreOnTap(loc['storeId'].toString()),
                          child: Container(
                            width: parentwidth / 17,
                            height: parentheight / 10,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            clipBehavior: Clip.hardEdge,
                            child: NetworkImageWithFallback(
                                imageUrl: loc['storeImage'] ?? "",
                                fallbackWidget: const Icon(Icons.error)),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }),
                  Consumer<KiosModel>(builder: (context, value, child) {
                    final kmodel = context.read<KiosModel>();

                    return Positioned(
                        left: kmodel.xLocation * parentwidth - parentwidth / 36,
                        top: kmodel.yLocation * parentheight / 2.1,
                        child: const Column(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                            DynamicText(
                              text: "you are here",
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            )
                          ],
                        ));
                  })
                ],
              );
            })
          ],
        ),
      ),
    );
  }
}
