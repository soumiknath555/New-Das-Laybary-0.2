import 'package:flutter/material.dart';

import '../../../ui_helper/ui_colors.dart';
import '../../settings/app_details/app_details_db.dart';
import '../../settings/app_details/app_details_page.dart';

class InvoiceLeftPreview extends StatefulWidget {
  final Map<int, int> cart;
  final List<Map<String, dynamic>> books;

  final TextEditingController nameCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController extraDiscountCtrl;

  final String? schoolName;
  final String? className;

  final Map<String, dynamic> Function() calculateInvoice;
  final VoidCallback onExtraDiscountChanged;

  const InvoiceLeftPreview({
    super.key,
    required this.cart,
    required this.books,
    required this.nameCtrl,
    required this.addressCtrl,
    required this.phoneCtrl,
    required this.extraDiscountCtrl,
    required this.calculateInvoice,
    required this.onExtraDiscountChanged,
    this.schoolName,
    this.className,
  });

  @override
  State<InvoiceLeftPreview> createState() => InvoiceLeftPreviewState();
}

class InvoiceLeftPreviewState extends State<InvoiceLeftPreview> {

  late Map<int, Map<String, dynamic>> editableBooks;

  // App Details State
  String shopName = '';
  String address = '';
  String phone = '';
  String whatsapp = '';
  String notice = '';
  String msg1 = '';
  String msg2 = '';
  String msg3 = '';

  @override
  void initState() {
    super.initState();
    _loadAppDetails();

    editableBooks = {};
    for (final entry in widget.cart.entries) {
      final book =
      widget.books.firstWhere((b) => b['id'] == entry.key);

      editableBooks[entry.key] = {
        ...book,
        'qty': entry.value,
      };
    }
  }

  Future<void> _loadAppDetails() async {
    final data = await AppDetailsDB.instance.getDetails(); // getDetails returns Map<String, dynamic>
    if (!mounted) return;

    setState(() {
      shopName = data?['shop_name'] ?? '';
      address = data?['address'] ?? '';
      phone = data?['phone'] ?? '';
      whatsapp = data?['whatsapp'] ?? '';
      notice = data?['notice'] ?? '';
      msg1 = data?['msg1'] ?? '';
      msg2 = data?['msg2'] ?? '';
      msg3 = data?['msg3'] ?? '';
    });

  }

  /// ===== EDIT DIALOG (LEFT FILE LOGIC) =====



  void _openEditDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.BLACK_8,
          title: const Text(
            "Edit Books",
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 700,
            child: ListView(
              shrinkWrap: true,
              children: editableBooks.entries.map((entry) {
                final book = entry.value;

                final qtyCtrl =
                TextEditingController(text: book['qty'].toString());
                final sellCtrl =
                TextEditingController(text: book['sell_price'].toString());
                final discCtrl =
                TextEditingController(text: book['sell_discount'].toString());

                return Card(
                  color: AppColors.BLACK_7,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${book['title']} | ${book['publication_name'] ?? ''} || ${book['author'] ?? ''}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            _editField("Qty", qtyCtrl),
                            _editField("Sell", sellCtrl),
                            _editField("Disc", discCtrl),
                          ],
                        ),

                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              final int qty = int.tryParse(qtyCtrl.text) ?? 1;
                              final int mrp = (book['mrp'] ?? 0).toInt();

                              int sell = int.tryParse(sellCtrl.text) ?? book['sell_price'];
                              int discount = int.tryParse(discCtrl.text) ?? book['sell_discount'];

                              // ✅ CASE 1: Sell value change হলে → Discount calculate
                              if (sellCtrl.text.isNotEmpty) {
                                discount = mrp > 0
                                    ? (((mrp - sell) * 100) ~/ mrp)
                                    : 0;
                              }

                              // ✅ CASE 2: Discount change হলে → Sell calculate
                              if (discCtrl.text.isNotEmpty && sellCtrl.text.isEmpty) {
                                sell = mrp - ((mrp * discount) ~/ 100);
                              }

                              book['qty'] = qty;
                              book['sell_price'] = sell;
                              book['sell_discount'] = discount;
                            });

                            // ✅ Dialog close করে আগের page এ ফিরে যাবে
                            Navigator.pop(context);
                          },
                          child: const Text("Apply"),
                        ),

                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }


  Widget _editField(String label, TextEditingController ctrl) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Builder(
          builder: (context) {
            int totalQty = 0;
            int totalMrp = 0;
            int totalSaved = 0;
            int totalPayable = 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ===== APP DETAILS =====
                Center(child: _appDetailsSectionTop()),

                const SizedBox(height: 20),

                /// ===== CUSTOMER INFO =====
                _input(widget.nameCtrl, "Customer Name"),
                const SizedBox(height: 8),
                _input(widget.addressCtrl, "Customer Address"),
                const SizedBox(height: 8),
                _input(
                  widget.phoneCtrl,
                  "Phone Number",
                  keyboard: TextInputType.phone,
                ),

                const SizedBox(height: 10),

                /// ===== SCHOOL + CLASS =====
                Text(
                  "School: ${widget.schoolName ?? ''}  |  Class: ${widget.className ?? ''}",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                /// ===== BOOK TABLE =====

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Selected Books",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.greenAccent),
                      tooltip: "Edit Books",
                      onPressed: _openEditDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 8),


                DataTable(
                  headingTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  dataTextStyle: const TextStyle(color: Colors.white70),
                  columnSpacing: 14,
                  columns: const [
                    DataColumn(label: Text("Book")),
                    DataColumn(label: Text("Author")),
                    DataColumn(label: Text("Medium")),
                    DataColumn(label: Text("Class")),
                    DataColumn(label: Text("Qty")),
                    DataColumn(label: Text("MRP")),
                    DataColumn(label: Text("Disc")),
                    DataColumn(label: Text("Sell")),
                    DataColumn(label: Text("Save")),
                    DataColumn(label: Text("Total")),
                  ],
                  rows: editableBooks.entries.map((e) {
                    final Map<String, dynamic> book = e.value;

                    final int qty = (book['qty'] ?? 1).toInt();
                    final int mrp = (book['mrp'] ?? 0).toInt();
                    final int sell = (book['sell_price'] ?? 0).toInt();

                    final String priceType =
                    (book['price_type'] ?? 'flat').toString().toLowerCase();
                    final int discountValue =
                    (book['sell_discount'] ?? 0).toInt();

                    final int savePerBook = mrp - sell;
                    final int total = sell * qty;


                    totalQty += qty;
                    totalMrp += mrp * qty;
                    totalPayable += sell * qty;
                    totalSaved += (mrp - sell) * qty;


                    return DataRow(
                      cells: [
                        /// 📘 Book
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book['title'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              if ((book['publication_name'] ?? '').toString().isNotEmpty)
                                Text(
                                  "(${book['publication_name']})",
                                  style: const TextStyle(color: Colors.purpleAccent, fontSize: 12),
                                ),
                            ],
                          ),
                        ),

                        /// Author
                        DataCell(Text(book['author'] ?? '-' ,style: TextStyle(color: Colors.deepOrange  ,fontSize: 16 ,fontWeight: FontWeight.bold),                                   )),

                        /// Medium
                        DataCell(Text(book['book_language'] ?? '-' ,style: TextStyle(color: Colors.lime  ,fontSize: 16 ,fontWeight: FontWeight.bold),                                   )),

                        /// Class
                        DataCell(Text(book['class_name'] ?? '-',style: TextStyle(color: Colors.purpleAccent  ,fontSize: 16 ,fontWeight: FontWeight.bold),                                   )),

                        /// Qty
                        DataCell(Text("$qty",style: TextStyle(color: Colors.cyanAccent  ,fontSize: 16 ,fontWeight: FontWeight.bold),)),

                        /// MRP
                        DataCell(Text("₹$mrp",style: TextStyle(color: Colors.white  ,fontSize: 16 ,fontWeight: FontWeight.bold),)),

                        /// Discount
                        DataCell(
                          priceType.contains("flat") || discountValue <= 0
                              ? const SizedBox() // ❌ Flat হলে কিছুই দেখাবে না
                              : Text(
                            "$discountValue%",
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),


                        /// Sell
                        DataCell(Text("₹$sell",style: TextStyle(color: Colors.blueAccent  ,fontSize: 16 ,fontWeight: FontWeight.bold),)),

                        /// Save
                        DataCell(Text(
                          "₹$savePerBook",
                          style: const TextStyle(color: Colors.lightGreenAccent),
                        )),

                        /// Total
                        DataCell(Text(
                          "₹$total",
                          style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ],
                    );
                  }).toList(),

                ),


                const SizedBox(height: 16),
                const Divider(color: Colors.white24),

                /// ===== EXTRA DISCOUNT =====
                _input(
                  widget.extraDiscountCtrl,
                  "Extra Discount (₹)",
                  keyboard: TextInputType.number,
                  onChanged: widget.onExtraDiscountChanged,
                ),

                const SizedBox(height: 12),

                /// ===== SUMMARY =====
                Builder(builder: (_) {
                  final data = widget.calculateInvoice();
                  final int extra =
                      int.tryParse(widget.extraDiscountCtrl.text) ?? 0;

                  final int finalPayable =
                  (totalPayable - extra).clamp(0, totalPayable).toInt();

                  return Column(
                    children: [
                      _summary("Total Books", "$totalQty pcs" ,color: Colors.cyanAccent),
                      _summary("Total MRP", "₹$totalMrp"),
                      _summary(
                        "You Saved",
                        "₹${(totalSaved + extra).toInt()}",
                        color: Colors.greenAccent,
                      ),
                      if (data['extraDiscount'] > 0)
                        _summary(
                          "Extra Discount",
                          "-₹${data['extraDiscount']}",
                          color: Colors.greenAccent,
                        ),
                      const Divider(color: Colors.white24),
                      _summary(
                        "Amount to Pay",
                        "₹$finalPayable",
                        bold: true,
                        color: Colors.orangeAccent,
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 30),

                /// ===== THANK YOU =====
                Center(child: _appDetailsSectionBottom())
              ],
            );
          },
        ),
      ),
    );
  }

  /// ===== APP DETAILS SECTION =====
  Widget _appDetailsSectionTop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (shopName.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                shopName,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        if (address.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                address,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        if (phone.isNotEmpty || whatsapp.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${phone.isNotEmpty ? phone : ''}      ${whatsapp.isNotEmpty ? whatsapp : ''}",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
      ],
    );
  }


  Widget _appDetailsSectionBottom() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (notice.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  notice,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        if (msg1.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                msg1,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        if (msg2.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                msg2,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        if (msg3.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                msg3,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
      ],
    );
  }

  Widget _input(
      TextEditingController ctrl,
      String label, {
        TextInputType keyboard = TextInputType.text,
        VoidCallback? onChanged,
      }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      onChanged: (_) => onChanged?.call(),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
      ),
    );
  }

  Widget _summary(
      String label,
      String value, {
        bool bold = false,
        Color color = Colors.white,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white70)),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight:
                bold ? FontWeight.bold : FontWeight.normal,
                fontSize: bold ? 18 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
