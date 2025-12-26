import 'package:flutter/material.dart';
import 'package:new_das_laybary_2/page/dashboard/sell_billing_page/sell_bill_ditels_page.dart';
import '../../belling_page/billing_database.dart';

class SellBillingPage extends StatefulWidget {
  const SellBillingPage({super.key});

  @override
  State<SellBillingPage> createState() => _SellBillingPageState();
}

class _SellBillingPageState extends State<SellBillingPage> {
  bool loading = true;
  List<Map<String, dynamic>> invoices = [];

  @override
  void initState() {
    super.initState();
    _loadTodayInvoices();
  }

  Future<void> _loadTodayInvoices() async {
    final db = await BillingDatabase.instance.database;

    final today = DateTime.now();
    final start = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();

    final result = await db.query(
      'invoices',
      where: 'createdAt >= ?',
      whereArgs: [start],
      orderBy: 'id DESC',
    );

    setState(() {
      invoices = result;
      loading = false;
    });
  }

  Future<void> _confirmDelete(int id) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this bill?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (result == true) {
      _deleteInvoice(id);
    }
  }


  Future<void> _deleteInvoice(int id) async {
    final db = await BillingDatabase.instance.database;
    await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
    _loadTodayInvoices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121212),
      appBar: AppBar(
        title: const Text("Sell Billing"),
        backgroundColor: Colors.black,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : invoices.isEmpty
          ? const Center(
        child: Text(
          "No bills today",
          style: TextStyle(color: Colors.white70),
        ),
      )
          : ListView.builder(
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final inv = invoices[index];

          return Card(
            color: Colors.grey.shade900,
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SellBillingDetailsPage(
                      invoiceId: inv['id'],
                    ),
                  ),
                );
              },
              title: Text(
                "Bill #${inv['id']}  •  ${inv['name'] ?? 'Customer'}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Phone: ${inv['phone'] ?? '-'}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "Address: ${inv['address'] ?? '-'}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              trailing: Column(
              mainAxisSize: MainAxisSize.min, // ⭐ এটা যোগ করো
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "₹ ${inv['finalPayable']}",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => _confirmDelete(inv['id']),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),

              ],
            ),

          ),
          );
        },
      ),
    );
  }
}
