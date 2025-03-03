import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapmobile/models/map_model.dart';
import 'package:mapmobile/services/streetservice.dart';
import 'package:mapmobile/shared/networkimagefallback.dart';
import 'package:mapmobile/shared/text.dart';
import 'package:provider/provider.dart';

class MapPicking extends StatefulWidget {
  const MapPicking({super.key});

  @override
  State<MapPicking> createState() => _MapPickingState();
}

class _MapPickingState extends State<MapPicking> {
  List<dynamic> street = [];

  @override
  void initState() {
    super.initState();

    getAllStreet().then((res) {
      setState(() {
        street = res;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double parentwidth = MediaQuery.of(context).size.width;
    return Consumer<MapModel>(builder: (context, value, child) {
      final model = context.read<MapModel>();
      return Scaffold(
        body: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const DynamicText(
              text: "Chọn đường sách bạn muốn xem",
              textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: street.map((st) {
                return Column(
                  children: [
                    DynamicText(text: st['streetName']),
                    InkWell(
                      onTap: () {
                        model.setStreetId(st['streetId']);
                        model.setStreetName(st['streetName']);
                        model.setImage(st['urlImage']);
                        model.setLocations(st['locations']);
                        context.push("/kiosPicking");
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: const Color.fromARGB(255, 219, 219, 219)),
                        width: parentwidth / 2.5,
                        child: NetworkImageWithFallback(
                            imageUrl: st['urlImage'],
                            fallbackWidget: const Icon(Icons.error)),
                      ),
                    )
                  ],
                );
              }).toList(),
            ),
          ],
        )),
      );
    });
  }
}
