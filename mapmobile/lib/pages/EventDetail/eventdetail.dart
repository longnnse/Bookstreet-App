import 'package:flutter/material.dart';
import 'package:mapmobile/shared/header.dart';
import 'package:mapmobile/services/eventservice.dart';
import 'package:mapmobile/shared/networkimagefallback.dart';
import 'package:mapmobile/shared/text.dart';
import 'package:mapmobile/util/util.dart';

class EventDetail extends StatefulWidget {
  const EventDetail({super.key, this.eventId});
  final String? eventId;

  @override
  State<EventDetail> createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  dynamic event = {};
  @override
  void initState() {
    super.initState();
    getEventById(id: widget.eventId).then((res) {
      setState(() {
        event = res;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Header(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 80, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    clipBehavior: Clip.hardEdge,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: NetworkImageWithFallback(
                        imageUrl: event['urlImage'] ?? '',
                        fallbackWidget: Icon(Icons.error)),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        DynamicText(
                          text: event['starDate'] != null
                              ? formatDateTime(event['starDate'])
                              : '',
                          textStyle: const TextStyle(
                              color: Color.fromARGB(255, 224, 15, 0),
                              fontSize: 20),
                        ),
                        const Text(
                          " - ",
                          style: const TextStyle(
                              color: Color.fromARGB(255, 224, 15, 0),
                              fontSize: 20),
                        ),
                        DynamicText(
                          text: event['endDate'] != null
                              ? formatDateTime(event['endDate'])
                              : '',
                          textStyle: const TextStyle(
                              color: Color.fromARGB(255, 224, 15, 0),
                              fontSize: 20),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 20),
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 1, color: Colors.grey))),
                    child: DynamicText(
                      text: event['title'] ?? '',
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ),
                  const DynamicText(
                      text: 'Chi tiết',
                      textStyle:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  Row(
                    children: [
                      Container(
                          margin: EdgeInsets.only(right: 10),
                          child: Icon(Icons.people)),
                      DynamicText(
                        text: event['hostName'] != null
                            ? 'Host: ${event['hostName']}'
                            : "Host: ",
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      )
                    ],
                  ),
                  DynamicText(text: event['description'] ?? '')
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
