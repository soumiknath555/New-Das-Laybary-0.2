import 'package:flutter/material.dart';
import '../../ui_helper/ui_colors.dart';
import '../shope_name/shop_name_db.dart';
import 'purchase_book_list.dart';
import 'purchase_summary_panel.dart';
import '../add_page/add_page_db.dart';
import 'purchase_database.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  List<Map<String, dynamic>> books = [];
  List<Map<String, dynamic>> shops = [];
  final Map<int, int> cart = {};
  int? selectedShopId;
  bool loading = true;

  String? purchaseFrom;



  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Books load
    books = await BooksAddDB.instance.getAllBooks();

    // Shops load from ShopNameDB
    shops = await ShopNameDB.instance.getAll(); // <-- এখান থেকে shops আসবে

    setState(() => loading = false);
  }

  void addToCart(int bookId) {
    setState(() {
      cart[bookId] = (cart[bookId] ?? 0) + 1;
    });
  }

  void removeFromCart(int bookId) {
    setState(() {
      if (!cart.containsKey(bookId)) return;
      if (cart[bookId]! > 1) {
        cart[bookId] = cart[bookId]! - 1;
      } else {
        cart.remove(bookId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BLACK_9,
      appBar: AppBar(
        title: const Text("Purchase"),
        backgroundColor: AppColors.BLACK_9,
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Row(
        children: [

          /// 🔵 LEFT — PURCHASE BOOK LIST
          Expanded(
            flex: 2,
            child: PurchaseBookList(
              books: books,
              cart: cart,
              onAdd: addToCart,
              onRemove: removeFromCart,
            ),
          ),

          /// 🟢 RIGHT — PURCHASE FROM / SUMMARY
          Expanded(
            flex: 2,
            child: PurchaseSummaryPanel(
              books: books,
              shops: shops, // ShopNameDB থেকে আসা list
              cart: cart,
              selectedShopId: selectedShopId,
              onShopChanged: (v) =>
                  setState(() => selectedShopId = v),
            ),


          ),
        ],
      ),
    );
  }
}
