import 'package:flutter/material.dart';
import 'package:mapmobile/pages/Event/widget/event_list.dart';
import 'package:mapmobile/shared/header.dart';
import 'package:mapmobile/services/eventservice.dart';

class Event extends StatefulWidget {
  const Event({super.key});

  @override
  State<Event> createState() => _EventState();
}

class _EventState extends State<Event> {
  List<dynamic> eventList = [];

  Future<void> onTextChange(String text) async {
    debugPrint("text change api... $text");
    getEvent(search: text).then((res) {
      debugPrint("get event ${res.data['data']['list']}");
      setState(() {
        eventList = res.data['data']['list'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getEvent().then((res) {
      setState(() {
        eventList = res.data['data']['list'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin: const EdgeInsets.only(bottom: 40),
                  child: const Header()),
              Eventlist(eventList: eventList)
            ],
          ),
        ),
      )),
    );
  }
}
