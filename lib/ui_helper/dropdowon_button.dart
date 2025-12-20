import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class SnDropdown extends StatelessWidget {
  final List<String> items;
  final String? value;
  final String hintText;
  final ValueChanged<String?> onChanged;

  const SnDropdown({
    Key? key,
    required this.items,
    required this.value,
    required this.hintText,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,

        hint: Text(
          hintText,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),

        value: value,

        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.black87,        // 🔥 Dropdown item background
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }).toList(),

        selectedItemBuilder: (context) {
          return items.map((item) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            );
          }).toList();
        },

        onChanged: onChanged,

        buttonStyleData: ButtonStyleData(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          decoration: BoxDecoration(
            color: Colors.black87,          // 🔥 Dropdown whole box background
            border: Border.all(
              color: Colors.blueAccent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        menuItemStyleData: const MenuItemStyleData(
          height: 40,
        ),
      ),
    );
  }
}
