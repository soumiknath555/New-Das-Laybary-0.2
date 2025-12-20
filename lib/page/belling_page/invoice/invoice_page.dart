import 'package:flutter/material.dart';

class InvoicePage extends StatelessWidget {
  final Map<int, int> cart;
  final List<Map<String, dynamic>> books;

  const InvoicePage({
    super.key,
    required this.cart,
    required this.books,
  });

  @override
  Widget build(BuildContext context) {
    int totalAmount = 0;
    int totalProfit = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoice"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ...cart.entries.map((e) {
            final book = books.firstWhere((b) => b['id'] == e.key);

            final int qty = e.value;
            final int sell = (book['sell_price'] ?? 0).toInt();
            final int purchase = (book['purchase_price'] ?? 0).toInt();

            final int subTotal = sell * qty;
            final int profit = (sell - purchase) * qty;

            totalAmount += subTotal;
            totalProfit += profit;

            return Card(
              child: ListTile(
                title: Text(book['title'] ?? ''),
                subtitle: Text("Qty: $qty × ₹$sell"),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("₹$subTotal",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      "+₹$profit",
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          Card(
            color: Colors.black12,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Amount: ₹$totalAmount",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    "Total Profit: ₹$totalProfit",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
