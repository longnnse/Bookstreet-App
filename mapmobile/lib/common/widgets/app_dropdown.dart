import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDropdown extends StatefulWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final List<DropdownValue> items;
  final ValueChanged<DropdownValue?> onChanged;

  @override
  State<AppDropdown> createState() => _AppDropdownState();
}

class _AppDropdownState extends State<AppDropdown> {
  DropdownValue? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<DropdownValue>(
          hint: const Text('Lựa chọn ...'),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            suffixIcon: selectedValue != null
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedValue = null;
                      });
                      widget.onChanged(null);
                    },
                    child: const Icon(Icons.clear, color: Colors.red),
                  )
                : null,
          ),
          value: widget.items.contains(selectedValue) ? selectedValue : null,
          icon: const SizedBox.shrink(),
          items: widget.items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: SizedBox(
                      width: 150.w,
                      child: Text(
                        item.displayText,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (DropdownValue? value) {
            setState(() {
              selectedValue = value;
            });
            widget.onChanged(value);
          },
        )
      ],
    );
  }
}

class DropdownValue {
  final dynamic value;
  final String displayText;

  DropdownValue({required this.value, required this.displayText});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DropdownValue && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
