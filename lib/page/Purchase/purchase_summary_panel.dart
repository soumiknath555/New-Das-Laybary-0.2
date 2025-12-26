import 'package:flutter/material.dart';
import '../../ui_helper/ui_colors.dart';
import 'purchase_database.dart';

class PurchaseSummaryPanel extends StatelessWidget {
  final List<Map<String, dynamic>> books;
  final List<Map<String, dynamic>> shops;
  final Map<int, int> cart;

  final int? selectedShopId;
  final void Function(int?) onShopChanged;

  const PurchaseSummaryPanel({
    super.key,
    required this.books,
    required this.shops,
    required this.cart,
    required this.selectedShopId,
    required this.onShopChanged,
  });

  /// ================= TOTAL AMOUNT =================
  int get totalAmount {
    int t = 0;
    for (final e in cart.entries) {
      final book = books.firstWhere((b) => b['id'] == e.key);
      final int price =
      (book['purchase_price'] ?? book['mrp'] ?? 0).toInt();
      t += price * e.value;
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.BLACK_8,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= SHOP DROPDOWN =================
          DropdownButtonFormField<int>(
            value: selectedShopId,
            isExpanded: true,
            dropdownColor: AppColors.BLACK_7,
            decoration: const InputDecoration(
              labelText: "Purchase From (Shop)",
              labelStyle: TextStyle(color: Colors.white70),
            ),
            items: shops.map<DropdownMenuItem<int>>((s) {
              return DropdownMenuItem<int>(
                value: s['id'],
                child: Text("${s['name']} (${s['location'] ?? ''})",
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: onShopChanged,
          ),


          const SizedBox(height: 20),

          /// ================= SUMMARY =================
          Text(
            "Items: ${cart.length}",
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 6),

          Text(
            "Total Amount: ₹$totalAmount",
            style: const TextStyle(
              color: Colors.orangeAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),

          /// ================= SAVE =================
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Save Purchase"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.GREEN_9,
              ),
              onPressed: (selectedShopId == null || cart.isEmpty)
                  ? null
                  : () async {
                final db =
                await PurchaseDatabase.instance.database;

                final invoiceId =
                await db.insert('purchase_invoice', {
                  "shop_id": selectedShopId,
                  "total_qty":
                  cart.values.fold<int>(0, (a, b) => a + b),
                  "total_amount": totalAmount,
                  "created_at":
                  DateTime.now().toIso8601String(),
                });

                for (final e in cart.entries) {
                  final book =
                  books.firstWhere((b) => b['id'] == e.key);
                  await db.insert('purchase_items', {
                    "invoice_id": invoiceId,
                    "book_id": e.key,
                    "qty": e.value,
                    "purchase_price":
                    (book['purchase_price'] ??
                        book['mrp'] ??
                        0)
                        .toInt(),
                  });
                }

                if (context.mounted) Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
