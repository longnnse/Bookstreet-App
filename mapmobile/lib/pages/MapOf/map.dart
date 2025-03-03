import 'package:flutter/material.dart';
import 'package:mapmobile/models/kios_model.dart';
import 'package:mapmobile/models/map_model.dart';
import 'package:mapmobile/shared/header.dart';
import 'package:mapmobile/services/locationservice.dart';
import 'package:mapmobile/services/storeservice.dart';
import 'package:mapmobile/shared/networkimagefallback.dart';
import 'package:mapmobile/shared/text.dart';
import 'package:provider/provider.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key, this.storeId});
  final String? storeId;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  dynamic store = {};
  dynamic location = {"xLocation": 0, "yLocation": 0};
  @override
  void initState() {
    super.initState();
    getStoreById(widget.storeId).then((res) {
      getLocById(res['locationId']).then((locres) {
        print("location");
        print(locres);
        setState(() {
          location = locres;
          store = res;
        });
        print(location);
      });
    }).catchError((error) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    double parentwidth = MediaQuery.of(context).size.width;
    double parentheight = MediaQuery.of(context).size.height;
    double left = location['xLocation'] * parentwidth;
    double top = location['yLocation'] * parentheight / 2.1 +
        location['yLocation'] * parentheight / 20 -
        20;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 40),
              child: Header(),
            ),
            Stack(
              children: [
                Consumer<MapModel>(builder: (context, value, child) {
                  final model = context.read<MapModel>();
                  return NetworkImageWithFallback(
                      imageUrl: model.imageUrl,
                      fallbackWidget: const Icon(Icons.error));
                }),
                Positioned(
                    left: left,
                    top: top,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 30,
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color:
                                    const Color.fromARGB(255, 226, 245, 255)),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: NetworkImageWithFallback(
                                      imageUrl: store['urlImage'] ?? "",
                                      fallbackWidget: const Icon(Icons.error)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      DynamicText(
                                        text: store['storeName'] ?? "",
                                        textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            color: Colors.blue,
                                          ),
                                          DynamicText(
                                              text:
                                                  "${location['locationName'] ?? ""}")
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.schedule,
                                            color: Colors.green,
                                          ),
                                          DynamicText(
                                              text:
                                                  "${store['openingHours'] ?? ""} - ${store['closingHours'] ?? ""}")
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ])),
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
                                fontWeight: FontWeight.bold, color: Colors.red),
                          )
                        ],
                      ));
                })
              ],
            )
          ],
        ),
      ),
    );
  }
}
