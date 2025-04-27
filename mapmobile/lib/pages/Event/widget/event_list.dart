import 'package:flutter/material.dart';
import 'package:mapmobile/pages/Event/widget/event_card.dart';
import 'package:mapmobile/pages/event_detail/event_detail_page.dart';

class Eventlist extends StatelessWidget {
  final List<dynamic> eventList;

  const Eventlist({super.key, required this.eventList});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final event = eventList[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Hero(
              tag: 'event_${event['id']}',
              child: EventCard(
                event: event,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailPage(event: event),
                    ),
                  );
                },
              ),
            ),
          );
        },
        childCount: eventList.length,
      ),
    );
  }
}
