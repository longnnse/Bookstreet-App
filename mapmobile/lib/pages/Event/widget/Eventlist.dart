import 'package:flutter/material.dart';
import 'package:mapmobile/models/map_model.dart';
import 'package:mapmobile/pages/Event/widget/Eventwidget.dart';
import 'package:mapmobile/services/eventservice.dart';
import 'package:mapmobile/util/util.dart';
import 'package:provider/provider.dart';

class Eventlist extends StatefulWidget {
  const Eventlist({super.key, required this.eventList});
  final List<dynamic> eventList;

  @override
  State<Eventlist> createState() => _EventlistState();
}

class _EventlistState extends State<Eventlist> {
  List<dynamic> events = [];

  @override
  void initState() {
    super.initState();
    MapModel model = getStreet(context);
    getEventByStreetId(model.streetId).then((res) {
      setState(() {
        events = res;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemwidth = MediaQuery.of(context).size.width / 4 - 40;
    final deviceHeight = MediaQuery.of(context).size.height - 40;
    return SizedBox(
      height: deviceHeight - 100,
      child: SingleChildScrollView(
        child: Container(
          child: Consumer<MapModel>(
            builder: (context, value, child) {
              final model = context.read<MapModel>();
              return Wrap(
                spacing: 40,
                runSpacing: 10,
                children: [
                  ...events.map((event) {
                    return SizedBox(
                        width: itemwidth, child: Eventwidget(event: event));
                  })
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
