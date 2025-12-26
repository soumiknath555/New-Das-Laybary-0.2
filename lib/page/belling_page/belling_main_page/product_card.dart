import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../ui_helper/ui_colors.dart';
import '../../add_page/add_page_db.dart';

/// =======================================================
/// BOOK LIST CARD
/// =======================================================

class BookListCard extends StatelessWidget {
  final Map book;
  final int id;
  final int initialQty;
  final void Function(int) onAdd;
  final void Function(int) onRemove;

  /// 🔥 notifier এখানেই বানানো
  final ValueNotifier<int> cartQtyNotifier;

  final bool isSelected;


  BookListCard({
    super.key,
    required this.book,
    required this.id,
    required this.initialQty,
    required this.onAdd,
    required this.onRemove,
    required this.isSelected, // ✅ ADD THIS
  }) : cartQtyNotifier = ValueNotifier<int>(initialQty);


  String _discountText() {
    final d = book['sell_discount'];
    final t = (book['price_type'] ?? "").toString();
    if (d == null || d == 0) return "";
    return t.contains("flat") ? "-₹$d" : "-$d%";
  }

  final Map<String, Color> mediumColors = {
    "Text": Colors.blueAccent,
    "Pen": Colors.deepPurple,
    "Pencil": Colors.orange,
    "Test Paper": Colors.red,
    "Project": Colors.purpleAccent,
    "Others": Colors.cyanAccent,
    "Khata": Colors.brown,
    "Helping Tools": Colors.teal,
    "Chatro bondhu": Colors.pink,
    "Sohika": Colors.green,
  };


  void _showFullImage(BuildContext context, Uint8List img) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(child: Image.memory(img, fit: BoxFit.contain)),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _mediumChip(String? medium) {
    if (medium == null || medium.isEmpty) return const SizedBox();

    return Row(
      children: [
        const Text(
          "Medium:",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: mediumColors[medium] ?? Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            medium,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }



  Widget _row(
      String label,
      String? value,
      Color valueColor, {
        double labelSize = 12,
        double valueSize = 12,
      }) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label ",
              style: TextStyle(
                color: Colors.white,
                fontSize: labelSize,
              ),
            ),
            TextSpan(
              text: "($value)",
              style: TextStyle(
                color: valueColor,
                fontSize: valueSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stock = book['quantity'] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.BLACK_7,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.greenAccent, width: 2)
              : null,
        ),

        child: Row(
          children: [
            /// IMAGE
            SizedBox(
              width: 120,
              child: FutureBuilder<Uint8List?>(
                future: BooksAddDB.instance.getFirstImageByBookId(id),
                builder: (_, s) {
                  if (!s.hasData) {
                    return const Icon(Icons.book,
                        color: Colors.white54, size: 40);
                  }
                  return Stack(
                    children: [
                      Image.memory(
                        s.data!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () =>
                              _showFullImage(context, s.data!),
                          child: const Icon(Icons.remove_red_eye,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            /// DETAILS + QTY
            Expanded(
              child: Row(
                children: [
                  /// DETAILS
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 📘 BOOK NAME
                      Text(
                        book['title'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),

                      const SizedBox(height: 2),

                      /// ✍️ AUTHOR
                      Row(
                        children: [
                          _row(
                            "Author:",
                            book['author'],
                            Colors.orangeAccent,
                            valueSize: 18,
                          ),
                          const SizedBox(width: 10),
                          _mediumChip(book['book_language']),
                        ],
                      ),


                      /// 🏢 PUBLICATION + CLASS
                      Row(
                        children: [
                          _row(
                            "Publication:",
                            book['publication_name'],
                            Colors.blueAccent,
                            valueSize: 18
                          ),
                          const SizedBox(width: 15),
                          _row(
                            "Class:",
                            book['class_name'],
                            Colors.cyanAccent,
                            valueSize: 18
                          ),
                        ],
                      ),

                      /// 💰 MRP + DISCOUNT
                      Row(
                        children: [
                          _row(
                            "MRP:",
                            "₹${book['mrp']}",
                            Colors.white70,
                            valueSize: 18
                          ),
                          const SizedBox(width: 15),

                          if ((book['price_type'] ?? '') == "Discount")
                            _row(
                              "Discount:",
                              _discountText(),
                              Colors.redAccent,
                              valueSize: 18,
                            ),

                        ],
                      ),

                      /// ✅ SELL PRICE
                      _row(
                        "Sell:",
                        "₹${book['sell_price']}",
                        Colors.greenAccent,
                        valueSize: 18
                      ),

                      /// 📦 STOCK
                      _row(
                        "Stock:",
                        "${book['quantity']}",
                        book['quantity'] > 0
                            ? Colors.blue
                            : Colors.redAccent,
                        valueSize: 18
                      ),
                    ],
                  ),


                  const Spacer(),

                  /// 🔥 QTY CONTROL
                  QtyControl(
                    stock: stock,
                    qtyNotifier: cartQtyNotifier,
                    onAdd: () {
                      cartQtyNotifier.value++;
                      onAdd(id);
                    },
                    onRemove: () {
                      cartQtyNotifier.value--;
                      onRemove(id);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================================================
/// ONLY TEXT REBUILDS HERE
/// =======================================================

class QtyControl extends StatelessWidget {
  final int stock;
  final ValueNotifier<int> qtyNotifier;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const QtyControl({
    super.key,
    required this.stock,
    required this.qtyNotifier,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: qtyNotifier,
      builder: (_, qty, __) {
        /// 🟢 INITIAL → ONLY +
        if (qty == 0) {
          return IconButton(
            icon: const Icon(Icons.add, color: Colors.greenAccent),
            onPressed: stock <= 0 ? null : onAdd,
          );
        }

        /// 🟢 AFTER ADD → - qty +
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.redAccent),
              onPressed: onRemove,
            ),
            Text(
              "$qty",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.greenAccent),
              onPressed: stock <= 0 ? null : onAdd,
            ),
          ],
        );
      },
    );
  }
}

