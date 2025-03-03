import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapmobile/shared/text.dart';
import 'package:mapmobile/util/util.dart';

class Eventwidget extends StatelessWidget {
  const Eventwidget({super.key, required this.event});
  final event;
  @override
  Widget build(BuildContext context) {
    final imageURL = isImageUrl(event['urlImage'])
        ? event['urlImage']
        : 'https://fptbs.azurewebsites.net/api/File/image/39db9df0-dfea-4df6-bf95-4571a96d613a.jpg';
    return InkWell(
      onTap: () {
        context.push("/event/${event['id']}");
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: const Color.fromARGB(255, 220, 220, 220))),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(imageURL),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DynamicText(
                      text: "Event",
                      textStyle: TextStyle(
                          color: Color.fromARGB(255, 255, 98, 0),
                          fontWeight: FontWeight.w600)),
                  DynamicText(
                    text: event['title'],
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  Row(
                    children: [
                      DynamicText(
                        text: formatDateTime(event['starDate']),
                        textStyle: const TextStyle(color: Colors.blue),
                      ),
                      const Text(" - ", style: TextStyle(color: Colors.blue)),
                      DynamicText(
                          text: formatDateTime(event['endDate']),
                          textStyle: const TextStyle(color: Colors.blue))
                    ],
                  ),
                  DynamicText(text: 'Host: ${event['hostName']}')
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
