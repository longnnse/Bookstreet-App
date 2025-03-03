import 'package:flutter/material.dart';
import 'package:mapmobile/shared/header.dart';
import 'package:mapmobile/pages/Event/widget/Eventlist.dart';
import 'package:mapmobile/services/eventservice.dart';

class Event extends StatefulWidget {
  const Event({super.key});

  @override
  State<Event> createState() => _EventState();
}

class _EventState extends State<Event> {
  List<dynamic> eventList = [];

  Future<void> onTextChange(String text) async {
    print("text change api... $text");
    getEvent(search: text).then((res) {
      print("get event ${res.data['data']['list']}");
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
          child: Column(
        children: [
          Container(margin: const EdgeInsets.only(bottom: 40), child: Header()),
          Eventlist(eventList: eventList)
        ],
      )),
    );
  }
}
