import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:new_das_laybary_2/ui_helper/text_style.dart';
import '../../ui_helper/ui_colors.dart';
import 'add_page.dart';
import 'add_page_db.dart';

class AddBooksPage extends StatefulWidget {
  const AddBooksPage({super.key});

  @override
  State<AddBooksPage> createState() => _AddBooksPageState();
}

class _AddBooksPageState extends State<AddBooksPage> {
  late Future<List<Map<String, dynamic>>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  String? selectedClass = "All Class";
  String? selectedPublication = "All Publication";
  String? selectedMedium = "All Books Type";

  List<String> classList = [];
  List<String> publicationList = [];
  List<String> mediumList = [];

  List<Map<String, dynamic>> books = [];
  bool loading = true;

  void _loadBooks() {
    _booksFuture = BooksAddDB.instance.getAllBooks();
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

  List<Map<String, dynamic>> get filteredBooks {
    return books.where((book) {
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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BLACK_9,
      appBar: AppBar(
        backgroundColor: AppColors.BLACK_9,
        title: const Text("Books", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.GREEN_9,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPage()),
          );
          _loadBooks();
          setState(() {});
        },
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No books added yet!",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          books = snapshot.data!;

          // 🔥 dropdown list fill from DB (unique values)
          classList = books
              .map((b) => b['class_name']?.toString())
              .where((v) => v != null && v.isNotEmpty)
              .toSet()
              .cast<String>()
              .toList();

          publicationList = books
              .map((b) => b['publication_name']?.toString())
              .where((v) => v != null && v.isNotEmpty)
              .toSet()
              .cast<String>()
              .toList();

          mediumList = books
              .map((b) => b['book_language']?.toString())
              .where((v) => v != null && v.isNotEmpty)
              .toSet()
              .cast<String>()
              .toList();



          return Column(
            children: [


              /// 🔽 FILTER BAR (new, only this is added)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [

                    DropdownButton<String>(
                      value: selectedClass,
                      dropdownColor: AppColors.BLACK_7,
                      items: ["All Class", ...classList].map((v) {
                        return DropdownMenuItem(
                          value: v,
                          child: Text(v, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => selectedClass = v),
                    ),

                    const SizedBox(width: 12),

                    DropdownButton<String>(
                      value: selectedPublication,
                      dropdownColor: AppColors.BLACK_7,
                      items: ["All Publication", ...publicationList].map((v) {
                        return DropdownMenuItem(
                          value: v,
                          child: Text(v, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => selectedPublication = v),
                    ),

                    const SizedBox(width: 12),

                    DropdownButton<String>(
                      value: selectedMedium,
                      dropdownColor: AppColors.BLACK_7,
                      items: ["All Books Type", ...mediumList].map((v) {
                        return DropdownMenuItem(
                          value: v,
                          child: Text(v, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => selectedMedium = v),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];



                    return Card(
                      color: AppColors.BLACK_7,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<Uint8List?>(
                              future: BooksAddDB.instance.getFirstImageByBookId(book['id']),
                              builder: (context, snapshot) {
                                return _bookImage(snapshot.data);
                              },
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: _bookDetails(book)),
                            _actionButtons(book),
                          ],
                        ),
                      ),
                    );
                  },

                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ---------- IMAGE ----------
  Widget _bookImage(Uint8List? image) {
    return Container(
      width: 210,
      height: 250, // ✅ height 150
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.BLACK_6,
      ),
      child: image == null
          ? const Icon(Icons.book, color: Colors.white54, size: 40)
          : ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }


  /// ---------- DETAILS ----------
  Widget _bookDetails(Map<String, dynamic> book) {
    final int qty = book['quantity'] ?? 1;

    // per piece price (DB value)
    final num mrp = book['mrp'] ?? 0;
    final num sell = book['sell_price'] ?? 0;
    final num buy = book['purchase_price'] ?? 0;
    final num profit = book['profit'] ?? 0;

    // stock wise price
    final num stockMrp = mrp * qty;
    final num stockSell = sell * qty;
    final num stockBuy = buy * qty;
    final num stockProfit = profit * qty;

    TextStyle labelStyle =
    const TextStyle(color: Colors.white60, fontSize: 12);

    TextStyle snLabelStyle =
    const TextStyle(color: Colors.green, fontSize: 16);

    TextStyle valueStyle =
    const TextStyle(color: Colors.white, fontSize: 13);

    final String bookMedium =
    (book['book_language'] ?? '').toString();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// ================= STOCK WISE =================

    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Text(
            "Stock Wise",
            style: snTextStyle25Bold(color: Colors.green),
          ),

          const SizedBox(height: 4),

          /// TITLE
          Text(
            book['title'] ?? '',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          /// AUTHOR
          if (book['author'] != null && book['author'].toString().isNotEmpty)
            Text("Author: ${book['author']}", style: valueStyle),

          const SizedBox(height: 4),

          /// 🔥 BOOK MEDIUM (TEXT / SOHIKA)
          if (bookMedium.isNotEmpty)
            Row(
              children: [
                const Text("Medium: ",
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: mediumColors[bookMedium] ?? Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Text(
                    bookMedium,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 6),

          /// PUBLICATION / TYPE / CLASS
          if (book['publication_name'] != null)
            Text(
              "Publication: ${book['publication_name']}",
              style: valueStyle,
            ),
          if (book['book_type_name'] != null)
            Text(
              "Book Type: ${book['book_type_name']}",
              style: valueStyle,
            ),
          if (book['class_name'] != null)
            Text(
              "Class: ${book['class_name']}",
              style: valueStyle,
            ),

          const SizedBox(height: 8),

          /// 🔥 STOCK WISE PRICE DETAILS
          Wrap(
            spacing: 10,
            runSpacing: 4,
            children: [
              _chip("MRP ₹$stockMrp"),
              _chip("Sell ₹$stockSell"),
              _chip("Buy ₹$stockBuy"),
              _chip("Profit ₹$stockProfit"),
            ],
          ),

          const SizedBox(height: 6),

          /// DISCOUNTS
          Text(
            "Sell Disc: ${book['sell_discount']}% | Purchase Disc: ${book['purchase_discount']}%",
            style: labelStyle,
          ),

          const SizedBox(height: 4),

          /// STOCK
          Text(
            "Stock: $qty | Price Type: ${book['price_type']}",
            style: labelStyle,
          ),

          const SizedBox(height: 4),

          /// SHOP LIST
          if (book['shop_list'] != null &&
              book['shop_list'].toString().isNotEmpty)
            Text(
              "Shops: ${book['shop_list']}",
              style: labelStyle,
            ),

          const SizedBox(height: 6),

          /// DESCRIPTION
          if (book['description'] != null &&
              book['description'].toString().isNotEmpty)
            Text(
              book['description'],
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
        ],
      ),
    ),


    const SizedBox(width: 30),

        Container(
          color: Colors.white,
          height: 250,
          width: 3,
        ),

        const SizedBox(width: 30),

        /// ================= PIECE WISE =================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Piece Wise",
                  style: snTextStyle25Bold(color: Colors.green)),

              /// TITLE
              Text(
                book['title'] ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              /// AUTHOR
              if (book['author'] != null)
                Text("Author: ${book['author']}", style: valueStyle),


              const SizedBox(height: 4),

              /// 🔥 BOOK MEDIUM (TEXT / SOHIKA)
              if (bookMedium.isNotEmpty)
                Row(
                  children: [
                    const Text("Medium: ",
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: mediumColors[bookMedium] ?? Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Text(
                        bookMedium,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 6),

              /// PUBLICATION / TYPE / CLASS
              if (book['publication_name'] != null)
                Text("Publication: ${book['publication_name']}",
                    style: valueStyle),

              if (book['book_type_name'] != null)
                Text("Book Type: ${book['book_type_name']}",
                    style: valueStyle),
              if (book['class_name'] != null)
                Text("Class: ${book['class_name']}", style: valueStyle),

              const SizedBox(height: 8),

              /// 🔥 PIECE WISE PRICE DETAILS (DB VALUE)
              Wrap(
                spacing: 10,
                runSpacing: 4,
                children: [
                  _chip("MRP ₹$mrp"),
                  _chip("Sell ₹$sell"),
                  _chip("Buy ₹$buy"),
                  _chip("Profit ₹$profit"),
                ],
              ),

              const SizedBox(height: 6),

              /// INFO
              Row(
                children: [
                  Text("Per 1 Piece Price", style: labelStyle),
                  SizedBox(width: 12),

                  /// DISCOUNTS
                  Text(
                    "Sell Disc: ${book['sell_discount']}% | Purchase Disc: ${book['purchase_discount']}%",
                    style: snLabelStyle,
                  ),

                ],
              ),

              const SizedBox(height: 4),

              /// STOCK
              Text(
                "Stock: $qty | Price Type: ${book['price_type']}",
                style: labelStyle,
              ),

              const SizedBox(height: 4),

              /// SHOP LIST
              if (book['shop_list'] != null &&
                  book['shop_list'].toString().isNotEmpty)
                Text(
                  "Shops: ${book['shop_list']}",
                  style: labelStyle,
                ),

              const SizedBox(height: 6),

              /// DESCRIPTION
              if (book['description'] != null &&
                  book['description'].toString().isNotEmpty)
                Text(
                  book['description'],
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }



  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.BLACK_6,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 12,
        ),
      ),
    );
  }

  int _perPiece(num total, int qty) {
    if (qty <= 0) return 0;
    return (total / qty).round();
  }





  /// ---------- EDIT & DELETE ----------
  Widget _actionButtons(Map<String, dynamic> book) {

    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blueAccent),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddPage(book: book), // 👈 এইখানে book pass হচ্ছে
              ),
            );

            _loadBooks();
            setState(() {});
          },
        ),



        IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () => _confirmDelete(book['id']), // ✅ id এখান থেকে
        ),
      ],
    );
  }

  /// ---------- DELETE CONFIRM ----------
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.BLACK_7,
        title: const Text("Delete Book", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to delete this book?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await BooksAddDB.instance.deleteBook(id);
              _loadBooks();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Book deleted successfully")),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
