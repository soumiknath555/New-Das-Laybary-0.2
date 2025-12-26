import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;  // 🔴 path ঠিক করো

import '../../settings/app_details/app_details_page.dart';
import '../billing_database.dart';
import 'invoice_left_preview.dart';
import 'invoice_right_sight.dart';



class InvoicePage extends StatefulWidget {

  final Map<int, int> cart;
  final List<Map<String, dynamic>> books;
  final String? schoolName;
  final String? className;

  const InvoicePage({
    super.key,
    required this.cart,
    required this.books,
    this.schoolName,
    this.className,
  });

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final extraDiscountCtrl = TextEditingController(text: "0");

  /// ⭐ GLOBAL KEY (LEFT PREVIEW CONTROL)
  final GlobalKey<InvoiceLeftPreviewState> leftPreviewKey =
  GlobalKey<InvoiceLeftPreviewState>();

  String selectedPrinter = "normal";

  /// ================= PDF SUCCESS DIALOG =================
  void _showPdfSuccessDialog(String path) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("PDF Created"),
        content: Text("Saved at:\n$path"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }



  Future<void> _saveInvoice() async {
    final data = calculateInvoice();


    await BillingDatabase.instance.saveInvoice(
      invoiceData: data,
      cart: widget.cart,
      books: widget.books,
      name: nameCtrl.text,
      phone: phoneCtrl.text,
      address: addressCtrl.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invoice Saved & Stock Updated")),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Invoice",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              // Navigate to AppDetailsPage
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AppDetailsPage(),
                ),
              );

              // যদি AppDetailsPage থেকে true return হয় → reload data
              if (result == true) {
                setState(() {
                  // refresh invoice page or any UI updates if needed
                });
              }
            },
          ),

        ],
      ),
      body: Row(
        children: [

          /// ================= LEFT =================
          InvoiceLeftPreview(
            key: leftPreviewKey,
            cart: widget.cart,
            books: widget.books,
            nameCtrl: nameCtrl,
            addressCtrl: addressCtrl,
            phoneCtrl: phoneCtrl,
            extraDiscountCtrl: extraDiscountCtrl,
            calculateInvoice: calculateInvoice,
            onExtraDiscountChanged: () => setState(() {}),
            schoolName: widget.schoolName,
            className: widget.className,
          ),

          /// ================= RIGHT =================


          InvoiceRightPanel(leftPreviewKey: leftPreviewKey)


        ],
      ),
    );
  }

  /// ================= INVOICE CALCULATION =================
  Map<String, dynamic> calculateInvoice() {
    int totalQty = 0;
    int totalMrp = 0;
    int totalSaved = 0;
    int totalPayable = 0;

    /// 🔥 SOLD ITEMS LIST (NEW)
    final List<Map<String, dynamic>> items = [];

    for (final e in widget.cart.entries) {
      final book =
      widget.books.firstWhere((b) => b['id'] == e.key);

      final int qty = e.value;
      final int mrp = (book['mrp'] ?? 0).toInt();
      final int discount = (book['sell_discount'] ?? 0).toInt();

      totalQty += qty;
      totalMrp += mrp * qty;
      totalSaved += discount * qty;
      totalPayable += (mrp - discount) * qty;

      /// 🔥 EACH SOLD BOOK
      items.add({
        "book_id": e.key,
        "qty": qty,
      });
    }

    /// ✅ EXTRA DISCOUNT
    final int extra =
        int.tryParse(extraDiscountCtrl.text) ?? 0;

    /// ✅ FINAL PAYABLE
    final int finalPayable =
    (totalPayable - extra).clamp(0, totalPayable).toInt();

    /// 🧪 DEBUG (IMPORTANT)
    debugPrint("🔥 SOLD ITEMS => $items");

    return {
      "totalQty": totalQty,
      "totalMrp": totalMrp,
      "totalSaved": totalSaved,
      "extraDiscount": extra,
      "finalPayable": finalPayable,

      /// 🔥 THIS WAS MISSING
      "items": items,
    };
  }

}





