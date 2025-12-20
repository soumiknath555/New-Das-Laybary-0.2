import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class SnMultiSelectDropdown<T> extends StatefulWidget {
  final List<MultiSelectItem<T>> items;
  final String hint;
  final Function(List<T>) onConfirm;
  final List<T>? initialValue;

  const SnMultiSelectDropdown({
    Key? key,
    required this.hint,
    required this.items,
    required this.onConfirm,
    this.initialValue,
  }) : super(key: key);

  @override
  State<SnMultiSelectDropdown<T>> createState() =>
      _SnMultiSelectDropdownState<T>();
}

class _SnMultiSelectDropdownState<T>
    extends State<SnMultiSelectDropdown<T>> {

  List<T> selectedItems = [];

  @override
  void initState() {
    super.initState();
    selectedItems = widget.initialValue ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return MultiSelectDialogField<T>(
      items: widget.items,
      initialValue: selectedItems,

      title: Text(
        widget.hint,
        style: const TextStyle(color: Colors.white),
      ),

      buttonText: Text(
        selectedItems.isEmpty
            ? widget.hint
            : "${selectedItems.length} shop selected",
        style: const TextStyle(color: Colors.white),
      ),

      itemsTextStyle: const TextStyle(color: Colors.white),
      selectedItemsTextStyle:
      const TextStyle(color: Colors.greenAccent),

      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),

      selectedColor: Colors.green,

      onConfirm: (value) {
        setState(() {
          selectedItems = value;
        });
        widget.onConfirm(value);
      },
    );
  }
}
