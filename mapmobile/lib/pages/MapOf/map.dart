import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mapmobile/common/widgets/map_with_position_widget.dart';
import 'package:mapmobile/services/locationservice.dart';
import 'package:mapmobile/services/storeservice.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key, this.storeId, this.locationId});
  final String? storeId;
  final int? locationId;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  Map<String, dynamic> store = {};

  String? locationName;
  String? imageUrl;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (widget.storeId != null) {
        await _fetchStore();
      }
      await _fetchLocation();
      setState(() {});
    });
  }

  Future<void> _fetchStore() async {
    try {
      final res = await getStoreById(widget.storeId);
      store = res;
    } catch (error) {
      debugPrint("Error fetching store: $error");
    }
  }

  Future<void> _fetchLocation() async {
    try {
      int? locationId;

      if (widget.locationId != null) {
        locationId = widget.locationId;
      }

      if (widget.storeId != null) {
        locationId = store['locationId'];
      }

      if (locationId == null) {
        return;
      }

      final locres = await getLocById(locationId);
      locationName = locres['locationName'];
      imageUrl = locres['locationImage'];
    } catch (error) {
      debugPrint("Error fetching location: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vị trí: ${locationName ?? ''}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: imageUrl == null
            ? const Center(child: CircularProgressIndicator())
            : MapWithPositionWidget(
                mapImageUrl: imageUrl ?? "",
                locationName: locationName ?? "",
                store: store,
              ),
      ),
    );
  }
}
