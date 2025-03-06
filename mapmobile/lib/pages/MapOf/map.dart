import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mapmobile/common/widgets/map_with_position_widget.dart';
import 'package:mapmobile/services/locationservice.dart';
import 'package:mapmobile/services/storeservice.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key, this.storeId});
  final String? storeId;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  Map<String, dynamic> store = {};
  Map<String, dynamic> location = {"xLocation": 0, "yLocation": 0};

  String? locationName;
  double? xLocation;
  double? yLocation;
  String? imageUrl;

  @override
  void initState() {
    super.initState();

    _fetchStoreAndLocation();
  }

  Future<void> _fetchStoreAndLocation() async {
    try {
      final res = await getStoreById(widget.storeId);
      final locres = await getLocById(res['locationId']);
      setState(() {
        location = locres;
        store = res;
        locationName = locres['locationName'];
        xLocation = locres['xLocation'];
        yLocation = locres['yLocation'];
        imageUrl = locres['locationImage'];
      });
    } catch (error) {
      print("Error fetching store or location: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Vị trí: $locationName")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MapWithPositionWidget(
                  mapImageUrl: imageUrl ?? "",
                  locationName: locationName ?? "",
                  storeName: store['storeName'] ?? "",
                  openingHours: store['openingHours'] ?? "",
                  closingHours: store['closingHours'] ?? "",
                  storeImageUrl: store['urlImage'] ?? ""),
            ],
          ),
        ));
  }
}
