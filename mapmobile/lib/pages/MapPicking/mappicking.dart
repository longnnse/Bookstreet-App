import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapmobile/models/map_model.dart';
import 'package:mapmobile/services/street_service.dart';
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
  final Streetservice _service = Streetservice();

  @override
  void initState() {
    super.initState();

    _service.getAllStreet().then((res) {
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
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: street.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const DynamicText(
                      text: "Chọn đường sách bạn muốn xem",
                      textStyle:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 3 / 2,
                        ),
                        itemCount: street.length,
                        itemBuilder: (context, index) {
                          final st = street[index];
                          return GestureDetector(
                            onTap: () {
                              model.setStreetId(st['streetId']);
                              model.setStreetName(st['streetName']);
                              model.setImage(st['urlImage']);
                              model.setLocations(st['locations']);
                              context.push("/kiosPicking");
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withAlpha(100),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: NetworkImageWithFallback(
                                          imageUrl: st['urlImage'],
                                          fallbackWidget:
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  DynamicText(
                                    text: st['streetName'],
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        )),
      );
    });
  }
}
