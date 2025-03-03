import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  const SearchTextField({super.key, required this.onTextChange});
  final Function onTextChange;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      child: TextField(
        onChanged: (value) {
          print("text change ...$value");
          onTextChange(value);
        },
        decoration: const InputDecoration(
            suffixIcon: Icon(Icons.search),
            hintText: 'Tên',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            contentPadding:
                EdgeInsets.symmetric(vertical: -10, horizontal: 10)),
      ),
    );
  }
}
