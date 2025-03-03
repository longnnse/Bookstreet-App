import 'package:flutter/material.dart';
import 'package:mapmobile/shared/text.dart';

class Currenttime extends StatelessWidget {
  const Currenttime({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int hour = now.hour;
    int minute = now.minute;
    String period = hour >= 12 ? 'pm' : 'am';
    IconData icon = period == 'am' ? Icons.light_mode : Icons.dark_mode;

    // Convert 24-hour time to 12-hour time
    if (hour == 0) {
      hour = 12; // Midnight case
    } else if (hour > 12) {
      hour -= 12;
    }

    // Format minute to always be two digits
    String minuteStr = minute < 10 ? '0$minute' : '$minute';
    return Container(
      child: Row(
        children: [
          BoldLGText(text: '$hour:$minuteStr'),
          Icon(
            icon,
            size: 30,
          )
        ],
      ),
    );
  }
}
