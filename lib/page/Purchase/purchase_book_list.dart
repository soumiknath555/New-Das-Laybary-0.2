import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../ui_helper/ui_colors.dart';
import '../add_page/add_page_db.dart';

class PurchaseBookList extends StatefulWidget {
  final List<Map<String, dynamic>> books;
  final Map<int, int> cart;
  final void Function(int) onAdd;
  final void Function(int) onRemove;

  const PurchaseBookList({
    super.key,
    required this.books,
    required this.cart,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<PurchaseBookList> createState() => _PurchaseBookListState();
}

class _PurchaseBookListState extends State<PurchaseBookList> {
  String selectedClass = "All Class";
  String selectedPublication = "All Publication";
  String selectedMedium = "All Medium";

  List<String> classList = [];
  List<String> publicationList = [];
  List<String> mediumList = [];

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    classList = [
      "All Class",
      ...(await BooksAddDB.instance.getDistinctClasses())
          .where((e) => e.isNotEmpty)
          .toSet()
    ];

    publicationList = [
      "All Publication",
      ...(await BooksAddDB.instance.getDistinctPublications())
          .where((e) => e.isNotEmpty)
          .toSet()
    ];

    mediumList = [
      "All Medium",
      ...(await BooksAddDB.instance.getDistinctMediums())
          .where((e) => e.isNotEmpty)
          .toSet()
    ];

    setState(() {});
  }

  /// 🔥 FILTERED LIST
  List<Map<String, dynamic>> get filteredBooks {
    return widget.books.where((b) {
      return (selectedClass == "All Class" ||
          b['class_name'] == selectedClass) &&
          (selectedPublication == "All Publication" ||
              b['publication_name'] == selectedPublication) &&
          (selectedMedium == "All Medium" ||
              b['book_language'] == selectedMedium);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// ================= DROPDOWN ROW =================
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: _drop(
                  selectedClass,
                  classList,
                      (v) => setState(() => selectedClass = v),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _drop(
                  selectedPublication,
                  publicationList,
                      (v) => setState(() => selectedPublication = v),
                ),
              ),
              const SizedBox(width: 6),
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

        /// ================= LIST =================
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: filteredBooks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final book = filteredBooks[i];
              final int id = book['id'];
              final int qty = widget.cart[id] ?? 0;

              return _PurchaseCard(
                book: book,
                id: id,
                qty: qty,
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
      String value,
      List<String> items,
      void Function(String) onChanged,
      ) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      dropdownColor: AppColors.BLACK_7,
      decoration: const InputDecoration(
        filled: true,
        fillColor: AppColors.BLACK_6,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem<String>(
          value: e,
          child: Text(e,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

/// =======================================================
/// PURCHASE CARD
/// =======================================================

class _PurchaseCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final int id;
  final int qty;
  final void Function(int) onAdd;
  final void Function(int) onRemove;

  const _PurchaseCard({
    required this.book,
    required this.id,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final int stock = book['quantity'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.BLACK_7,
        borderRadius: BorderRadius.circular(10),
        border:
        qty > 0 ? Border.all(color: Colors.greenAccent, width: 2) : null,
      ),
      child: Row(
        children: [
          /// IMAGE
          SizedBox(
            width: 90,
            height: 120,
            child: FutureBuilder<Uint8List?>(
              future: BooksAddDB.instance.getFirstImageByBookId(id),
              builder: (_, s) {
                if (!s.hasData) {
                  return const Icon(Icons.book,
                      color: Colors.white54, size: 40);
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.memory(s.data!, fit: BoxFit.cover),
                );
              },
            ),
          ),

          const SizedBox(width: 10),

          /// DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book['title'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                _info("MRP", "₹${book['mrp']}"),
                _info("Purchase", "₹${book['purchase_price']}"),
                _info(
                  "Stock",
                  "$stock",
                  color: stock > 0 ? Colors.blue : Colors.redAccent,
                ),
              ],
            ),
          ),

          /// QTY CONTROL (🔥 FIXED)
          qty == 0
              ? IconButton(
            icon:
            const Icon(Icons.add, color: Colors.greenAccent),
            onPressed: stock <= 0 ? null : () => onAdd(id),
          )
              : Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove,
                    color: Colors.redAccent),
                onPressed: () => onRemove(id),
              ),
              Text(
                "$qty",
                style: const TextStyle(
                    color: Colors.white, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.add,
                    color: Colors.greenAccent),
                onPressed:
                stock <= 0 ? null : () => onAdd(id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value, {Color color = Colors.white70}) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        "$label: $value",
        style: TextStyle(color: color, fontSize: 13),
      ),
    );
  }
}
