import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../ui_helper/ui_colors.dart';
import '../add_page/add_page_db.dart';
import '../school_name/school_wise_book/select_school_wise_book_db.dart';
import 'invoice/invoice_page.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({super.key});

  @override
  State<BillingPage> createState() => _BillingPageState();
}


/// 🏫 School + Class selection
Map<String, dynamic>? selectedSchool;
String? selectedSchoolClass;

/// dropdown data
List<Map<String, dynamic>> schoolList = [];
List<String> schoolClassList = [];




class _BillingPageState extends State<BillingPage> {

  /// ✅ DISCOUNT TEXT (Percent / Flat)
  String getDiscountText(Map<String, dynamic> book) {
    final int discount = (book['sell_discount'] ?? 0).toInt();
    final String rawType =
    (book['price_type'] ?? '').toString().trim().toLowerCase();

    if (discount <= 0) return "—";

    /// ✅ FLAT (সবচেয়ে safe check)
    if (rawType.contains("flat")) {
      return "-₹$discount";
    }

    /// ✅ otherwise PERCENTAGE (default)
    return "$discount%";
  }


  /// ================== DROPDOWN FILTERS ==================
  String? selectedClass = "All Class";
  String? selectedPublication = "All Publication";
  String? selectedMedium = "All Books Type";

  List<String> classList = [];
  List<String> publicationList = [];
  List<String> mediumList = [];



  List<Map<String, dynamic>> books = [];
  bool loading = true;

  /// 🛒 CART (bookId -> qty)
  final Map<int, int> cart = {};

  /// 🔹 Auto selected books (school wise)
  final Set<int> autoSelectedBookIds = {};


  ///     School Wise book

  int? selectedSchoolId;
  String? selectedSchoolClass;



  @override
  void initState() {
    super.initState();
    _loadBooks();
    _loadSchools();
  }


  Future<void> _loadSchools() async {
    final db = await SchoolBookDB.instance.database;

    final data = await db.rawQuery(
      "SELECT DISTINCT school_id, school_name FROM school_books",
    );

    setState(() {
      schoolList = data;
    });
  }

  Future<void> _loadSchoolClasses(int schoolId) async {
    final db = await SchoolBookDB.instance.database;

    final data = await db.rawQuery(
      "SELECT DISTINCT save_class FROM school_books WHERE school_id = ?",
      [schoolId],
    );

    setState(() {
      schoolClassList =
          data.map((e) => e['save_class'].toString()).toList();
      selectedSchoolClass = null;
    });
  }

  Future<void> _loadSelectedBooksForSchoolClass() async {
    if (selectedSchoolId == null || selectedSchoolClass == null) return;

    final db = await SchoolBookDB.instance.database;

    final data = await db.query(
      "school_books",
      where: "school_id = ? AND save_class = ?",
      whereArgs: [selectedSchoolId, selectedSchoolClass],
    );

    setState(() {
      cart.clear();
      autoSelectedBookIds.clear();

      for (final row in data) {
        final int bookId = int.parse(row['book_id'].toString());

        cart[bookId] = 1; // qty 1
        autoSelectedBookIds.add(bookId); // 🔥 mark auto selected
      }
    });
  }





  Future<void> _loadBooks() async {
    final data = await BooksAddDB.instance.getAllBooks();
    setState(() {

      // Extract unique values for dropdowns
      classList = data.map((b) => (b['class_name'] ?? '').toString()).toSet().toList()..removeWhere((e) => e.isEmpty);
      publicationList = data.map((b) => (b['publication_name'] ?? '').toString()).toSet().toList()..removeWhere((e) => e.isEmpty);
      mediumList = data.map((b) => (b['book_language'] ?? '').toString()).toSet().toList()..removeWhere((e) => e.isEmpty);


      books = data;
      loading = false;
    });
  }

  final Map<String, Color> mediumColors = {
    "Text": Colors.blueAccent,
    "Pen": Colors.deepPurple,
    "Pencil": Colors.orange,
    "Khata": Colors.brown,
    "Helping Tools": Colors.teal,
    "Chatro bondhu": Colors.pink,
    "Sohika": Colors.green,
  };


  void addToCart(int bookId) {
    setState(() {
      cart[bookId] = (cart[bookId] ?? 0) + 1;
    });
  }

  void removeFromCart(int bookId) {
    setState(() {
      if (cart.containsKey(bookId)) {
        if (cart[bookId]! > 1) {
          cart[bookId] = cart[bookId]! - 1;
        } else {
          cart.remove(bookId);
        }
      }
    });
  }

  int get totalAmount {
    int total = 0;
    for (final entry in cart.entries) {
      final book = books.firstWhere((b) => b['id'] == entry.key);
      final int price = (book['sell_price'] ?? 0).toInt();
      total += price * entry.value;
    }
    return total;
  }

  /// ================== FILTERED BOOKS ==================
  List<Map<String, dynamic>> get filteredBooks {
    final list = books.where((book) {
      final matchesClass =
          selectedClass == "All Class" || book['class_name'] == selectedClass;
      final matchesPublication =
          selectedPublication == "All Publication" ||
              book['publication_name'] == selectedPublication;
      final matchesMedium =
          selectedMedium == "All Books Type" ||
              book['book_language'] == selectedMedium;
      return matchesClass && matchesPublication && matchesMedium;
    }).toList();

    /// 🔥 selected books first
    list.sort((a, b) {
      final aSelected = cart.containsKey(a['id']);
      final bSelected = cart.containsKey(b['id']);
      if (aSelected && !bSelected) return -1;
      if (!aSelected && bSelected) return 1;
      return 0;
    });

    return list;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BLACK_9,
      appBar: AppBar(
        backgroundColor: AppColors.BLACK_9,
        title: const Text("Billing",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.white),
      )
          : Row(
        children: [
          /// ================= LEFT: BOOK LIST =================
          Expanded(
            flex: 2,
            child: Column(
              children: [

                /// ================= FILTER DROPDOWNS =================
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [

                      /// CLASS
                      DropdownButton<String>(
                        value: selectedClass,
                        dropdownColor: AppColors.BLACK_7,
                        items: ["All Class", ...classList].map((v) {
                          return DropdownMenuItem(
                            value: v,
                            child: Text(v, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(() => selectedClass = v!);
                        },
                      ),

                      const SizedBox(width: 12),

                      /// PUBLICATION
                      DropdownButton<String>(
                        value: selectedPublication,
                        dropdownColor: AppColors.BLACK_7,
                        items: ["All Publication", ...publicationList].map((v) {
                          return DropdownMenuItem(
                            value: v,
                            child: Text(v, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(() => selectedPublication = v!);
                        },
                      ),

                      const SizedBox(width: 12),

                      /// MEDIUM
                      DropdownButton<String>(
                        value: selectedMedium,
                        dropdownColor: AppColors.BLACK_7,
                        items: ["All Books Type", ...mediumList].map((v) {
                          return DropdownMenuItem(
                            value: v,
                            child: Text(v, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(() => selectedMedium = v!);
                        },
                      ),
                    ],
                  ),
                ),

                /// ================= GRIDVIEW =================
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredBooks.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.50,
                    ),
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      final int id = book['id'];
                      final bool isSelected = cart.containsKey(id);
                      final int qty = cart[id] ?? 0;
                      final String bookMedium =
                      (book['book_language'] ?? '').toString();



                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.BLACK_7,
                          borderRadius: BorderRadius.circular(8),

                          /// ✅ ONLY THIS IS NEW (GREEN BORDER)
                          border: isSelected
                              ? Border.all(color: Colors.greenAccent, width: 3)
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// BOOK IMAGE
                            Center(
                              child: FutureBuilder<Uint8List?>(
                                future: BooksAddDB.instance.getFirstImageByBookId(id),
                                builder: (_, snap) {
                                  if (!snap.hasData) {
                                    return Container(
                                      width: 150,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: AppColors.BLACK_6,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.book,
                                          color: Colors.white54, size: 50),
                                    );
                                  }
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      snap.data!,
                                      width: 150,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 8),

                      /// TITLE
                            Text(
                              (book['title'] ?? '').toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            /// AUTHOR
                            if (book['author'] != null)
                              Text(
                                "Author: ${book['author']}",
                                style: const TextStyle(color: Colors.white70),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                            const SizedBox(height: 4),

                            /// PUBLICATION
                            if (book['publication_name'] != null)
                              Text(
                                "Publication: ${book['publication_name']}",
                                style: const TextStyle(color: Colors.white70),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                            /// MEDIUM
                            if (bookMedium.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Container(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: mediumColors[bookMedium] ?? Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    bookMedium,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 6),

                            /// PRICE
                            Row(
                              children: [
                                Text(
                                  "₹${book['mrp'] ?? 0}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    decoration: TextDecoration.lineThrough,
                                    decorationThickness: 2,
                                    decorationColor: Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Stock: ${book['quantity'] ?? 0}",
                                  style: const TextStyle(
                                    color: Colors.orangeAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),

                            Text(
                              "Sell: ₹${book['sell_price'] ?? 0}",
                              style: const TextStyle(color: Colors.green),
                            ),

                            Text(
                              "Disc: ${getDiscountText(book)}",
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const Spacer(),

                            /// ADD / REMOVE
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (qty == 0)
                                  IconButton(
                                    icon: Icon(Icons.add_circle,
                                        color: AppColors.GREEN_9, size: 40),
                                    onPressed: () => addToCart(id),
                                  )
                                else ...[
                                  IconButton(
                                    icon: const Icon(Icons.remove,
                                        color: Colors.redAccent),
                                    onPressed: () => removeFromCart(id),
                                  ),
                                  Text(
                                    qty.toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  IconButton(
                                    icon:
                                    Icon(Icons.add, color: AppColors.GREEN_9),
                                    onPressed: () => addToCart(id),
                                  ),
                                ]
                              ],
                            ),
                          ],
                        ),
                      );

                    },
                  ),
                ),
              ],
            ),
          ),



          /// ================= RIGHT: PREVIEW =================
          Expanded(
            flex: 2,
            child: Container(
              color: AppColors.BLACK_8,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// ================= DROPDOWN ROW =================
                  Row(
                    children: [
                      /// ===== SCHOOL DROPDOWN =====
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: selectedSchoolId,
                          isExpanded: true,
                          dropdownColor: AppColors.BLACK_7,
                          decoration: const InputDecoration(
                            labelText: "Select School",
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white24),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.greenAccent),
                            ),
                          ),
                          items: schoolList.map<DropdownMenuItem<int>>((s) {
                            return DropdownMenuItem<int>(
                              value: s['school_id'],
                              child: Text(
                                s['school_name'],
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              selectedSchoolId = v;
                              selectedSchoolClass = null;
                              schoolClassList.clear();
                              cart.clear();
                            });
                            _loadSchoolClasses(v);
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// ===== CLASS DROPDOWN =====
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedSchoolClass,
                          isExpanded: true,
                          dropdownColor: AppColors.BLACK_7,
                          decoration: const InputDecoration(
                            labelText: "Select Class",
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white24),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.greenAccent),
                            ),
                          ),
                          items: schoolClassList.map((c) {
                            return DropdownMenuItem<String>(
                              value: c,
                              child: Text(
                                c,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => selectedSchoolClass = v);
                            _loadSelectedBooksForSchoolClass();
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// ================= TABLE + SUMMARY =================
                  Expanded(
                    child: cart.isEmpty
                        ? const Center(
                      child: Text(
                        "No books selected",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                        : SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// ================= DATATABLE =================
                            DataTable(
                              columnSpacing: 15,
                              headingRowHeight: 56,
                              dataRowMinHeight: 56,
                              dataRowMaxHeight: 56,
                              headingTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              dataTextStyle:
                              const TextStyle(color: Colors.white70),
                              columns: const [
                                DataColumn(label: Text("Book")),
                                DataColumn(label: Text("Profit")), // ✅ NEW
                                DataColumn(label: Text("Author")),
                                DataColumn(label: Text("Publication")),
                                DataColumn(label: Text("Medium")),
                                DataColumn(label: Text("Class")),
                                DataColumn(label: Text("MRP")),
                                DataColumn(label: Text("Sell")),
                                DataColumn(label: Text("Disc")),
                                DataColumn(label: Text("Qty")),
                                DataColumn(label: Text("Total")),
                              ],
                              rows: cart.entries.map((entry) {
                                final book = books
                                    .firstWhere((b) => b['id'] == entry.key);

                                final int qty = entry.value;
                                final int mrp =
                                (book['mrp'] ?? 0).toInt();
                                final int sell =
                                (book['sell_price'] ?? 0).toInt();
                                final int purchase =
                                (book['purchase_price'] ?? mrp).toInt();

                                final int profit =
                                    (sell - purchase) * qty;

                                final String discText =
                                getDiscountText(book);
                                final int total = sell * qty;

                                return DataRow(
                                  cells: [
                                    DataCell(Text(book['title'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.white))),
                                    DataCell(
                                      Text(
                                        "₹$profit",
                                        style: TextStyle(
                                          color: profit >= 0
                                              ? Colors.greenAccent
                                              : Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(book['author'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.orangeAccent))),
                                    DataCell(Text(
                                        book['publication_name'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.blueAccent))),
                                    DataCell(Text(
                                        book['book_language'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.purpleAccent))),
                                    DataCell(Text(
                                        book['class_name'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.white))),
                                    DataCell(Text("₹$mrp")),
                                    DataCell(Text("₹$sell",
                                        style: const TextStyle(
                                            color: Colors.greenAccent))),
                                    DataCell(Text(discText,
                                        style: const TextStyle(
                                            color: Colors.redAccent))),
                                    DataCell(Text("$qty")),
                                    DataCell(Text("₹$total",
                                        style: const TextStyle(
                                            color: Colors.orangeAccent))),
                                  ],
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            /// ================= SUMMARY =================
                            Builder(builder: (_) {
                              int totalQty = 0;
                              int totalAmount = 0;
                              int totalProfit = 0;

                              for (final entry in cart.entries) {
                                final book = books.firstWhere(
                                        (b) => b['id'] == entry.key);
                                final int qty = entry.value;
                                final int sell =
                                (book['sell_price'] ?? 0).toInt();
                                final int purchase =
                                (book['purchase_price'] ??
                                    book['mrp'] ??
                                    0)
                                    .toInt();

                                totalQty += qty;
                                totalAmount += sell * qty;
                                totalProfit +=
                                    (sell - purchase) * qty;
                              }

                              return Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("📚 Total Copies: $totalQty",
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                      Text("💰 Total Amount: ₹$totalAmount",
                                          style: const TextStyle(
                                              color: Colors.orangeAccent,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      Text("💹 Total Profit: ₹$totalProfit",
                                          style: TextStyle(
                                              color: totalProfit >= 0
                                                  ? Colors.greenAccent
                                                  : Colors.redAccent,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 10),

                                    ],
                                  ),

                                  SizedBox(width: 400),

                                  FloatingActionButton.extended(
                                    backgroundColor:
                                    AppColors.GREEN_9,
                                    icon: const Icon(
                                        Icons.receipt_long),
                                    label:
                                    const Text("Invoice"),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              InvoicePage(
                                                cart: cart,
                                                books: books,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),





        ],
      ),



        /// TOTAL BAR
      bottomNavigationBar: cart.isEmpty
          ? null
          : Container(
        padding: const EdgeInsets.all(12),
        color: AppColors.BLACK_7,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Items: ${cart.length}",
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              "Total ₹$totalAmount",
              style: TextStyle(
                  color: AppColors.GREEN_9,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
