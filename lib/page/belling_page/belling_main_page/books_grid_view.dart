import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:new_das_laybary_2/page/belling_page/belling_main_page/product_card.dart';

import '../../../ui_helper/ui_colors.dart';
import '../../add_page/add_page_db.dart';

class BookGridPage extends StatefulWidget {
  final Map<int, int> cart;
  final void Function(int) onAdd;
  final void Function(int) onRemove;

  const BookGridPage({
    super.key,
    required this.cart,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<BookGridPage> createState() => _BookGridPageState();
}


class _BookGridPageState extends State<BookGridPage> {
  List<Map<String, dynamic>> books = [];


  String selectedClass = "All Class";
  String selectedPublication = "All Publication";

  String selectedBookType = "All Books Type";

  List<String> classList = [];
  List<String> publicationList = [];
  List<String> mediumList = [];
  String selectedMedium = "All Books Type";




  @override
  void initState() {
    super.initState();
    _loadBooks();
    _loadFilters();
  }


  Future<void> _loadFilters() async {
    classList = [
      "All Class",
      ...(await BooksAddDB.instance.getDistinctClasses())
          .where((e) => e.isNotEmpty && e != "All Class")
          .toSet(),
    ];

    publicationList = [
      "All Publication",
      ...(await BooksAddDB.instance.getDistinctPublications())
          .where((e) => e.isNotEmpty && e != "All Publication")
          .toSet(),
    ];

    mediumList = [
      "All Books Type",
      ...(await BooksAddDB.instance.getDistinctMediums())
          .where((e) => e.isNotEmpty && e != "All Books Type")
          .toSet(),
    ];

    /// 🛡 safety: selected value list-এ না থাকলে reset
    if (!classList.contains(selectedClass)) {
      selectedClass = "All Class";
    }
    if (!publicationList.contains(selectedPublication)) {
      selectedPublication = "All Publication";
    }
    if (!mediumList.contains(selectedMedium)) {
      selectedMedium = "All Books Type";
    }

    setState(() {});
  }



  Future<void> _loadBooks() async {
    books = await BooksAddDB.instance.getAllBooks();
    setState(() {});
  }



  /// ================= FILTER =================
  List<Map<String, dynamic>> get filteredBooks {
    final list = books.where((b) {
      return (selectedClass == "All Class" ||
          b['class_name'] == selectedClass) &&
          (selectedPublication == "All Publication" ||
              b['publication_name'] == selectedPublication) &&
          (selectedMedium == "All Books Type" ||
              b['book_language'] == selectedMedium);
    }).toList();

    /// 🔥 Selected items first (use widget.cart)
    list.sort((a, b) {
      final aSelected = (widget.cart[a['id']] ?? 0) > 0;
      final bSelected = (widget.cart[b['id']] ?? 0) > 0;

      if (aSelected && !bSelected) return -1;
      if (!aSelected && bSelected) return 1;
      return 0;
    });

    return list;
  }




  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// ================= FILTER ROW =================
        Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child: _drop(
                    selectedClass,
                    classList,
                        (v) => setState(() => selectedClass = v),
                  ),
                ),

                const SizedBox(width: 8),
                Expanded(
                  child: _drop(
                    selectedPublication,
                    publicationList,
                        (v) => setState(() => selectedPublication = v),
                  ),
                ),

                const SizedBox(width: 8),
                Expanded(
                  child: _drop(
                    selectedMedium,
                    mediumList,
                        (v) => setState(() => selectedMedium = v),
                  ),
                ),


              ],
            ),
          ),
        ),

        /// ================= LIST =================
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: filteredBooks.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final b = filteredBooks[i];
              final id = b['id'];
              return BookListCard(
                book: b,
                id: id,
                initialQty: widget.cart[id] ?? 0,
                isSelected: (widget.cart[id] ?? 0) > 0,
                onAdd: widget.onAdd,
                onRemove: widget.onRemove,
              );

            },
          ),
        ),
      ],
    );
  }

  Widget _drop(
      String v,
      List<String> items,
      void Function(String) onChanged,
      ) {
    return DropdownButtonFormField<String>(
      value: items.contains(v) ? v : null,
      dropdownColor: AppColors.BLACK_7,
      decoration: const InputDecoration(
        filled: true,
        fillColor: AppColors.BLACK_6,
        border: OutlineInputBorder(),
        contentPadding:
        EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem<String>(
          value: e,
          child: Text(
            e,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }

}
