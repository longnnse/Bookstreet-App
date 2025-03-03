import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapmobile/models/map_model.dart';
import 'package:provider/provider.dart';

String getCurrentTime() {
  DateTime now = DateTime.now();
  int hour = now.hour;
  int minute = now.minute;
  String period = hour >= 12 ? 'pm' : 'am';

  // Convert 24-hour time to 12-hour time
  if (hour == 0) {
    hour = 12; // Midnight case
  } else if (hour > 12) {
    hour -= 12;
  }

  // Format minute to always be two digits
  String minuteStr = minute < 10 ? '0$minute' : '$minute';

  return '$hour:$minuteStr $period';
}

String getCurrentDate() {
  DateTime now = DateTime.now();
  int day = now.day;
  int month = now.month;
  int year = now.year;

  // Format day and month to always be two digits
  String dayStr = day < 10 ? '0$day' : '$day';
  String monthStr = month < 10 ? '0$month' : '$month';

  return '$dayStr.$monthStr.$year';
}

bool isImageUrl(String url) {
  final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'tiff'];
  final urlPattern = RegExp(
    r'^(http(s?):)([/|.|\w|\s|-])*\.(?:' + imageExtensions.join('|') + r')$',
    caseSensitive: false,
  );
  return urlPattern.hasMatch(url);
}

String formatToVND(double amount) {
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫', // Vietnamese Dong symbol
    decimalDigits: 2, // Number of decimal places
  );
  return currencyFormat.format(amount);
}

String formatDateTime(String input) {
  DateTime dateTime = DateTime.parse(input);
  return DateFormat('dd/MM/yyyy').format(dateTime);
}

bool isValidPhoneNumber(String phoneNumber) {
  // Biểu thức chính quy để kiểm tra số điện thoại có đúng 10 chữ số
  final RegExp regex = RegExp(r'^\d{10}$');
  return regex.hasMatch(phoneNumber);
}

MapModel getStreet(BuildContext context) {
  final model = Provider.of<MapModel>(context, listen: false);
  return model;
}
