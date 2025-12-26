import 'package:flutter/material.dart';
import 'package:new_das_laybary_2/page/belling_page/billing_database.dart';
import 'package:new_das_laybary_2/page/dashboard/sell_billing_page/sell_biling_page.dart';
import '../belling_page/billing_database.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int todaySell = 0;
  int todayAmount = 0;

  int totalSell = 0;
  int totalAmount = 0;

  bool loading = true;


  @override
  void initState() {
    super.initState();
    _loadTodaySell();
  }

  Future<void> _loadTodaySell() async {
    final today = await BillingDatabase.instance.getTodaySell();
    final total = await BillingDatabase.instance.getTotalSell();

    setState(() {
      todaySell = today["totalSell"] ?? 0;
      todayAmount = today["totalAmount"] ?? 0;

      totalSell = total["totalSell"] ?? 0;
      totalAmount = total["totalAmount"] ?? 0;

      loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121212),
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _todaySellCard(context),

            _totalSellCard(),
          ],
        ),
      ),

    );
  }


  Widget _todaySellCard(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 200,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SellBillingPage(),
            ),
          );
        },
        child: Card(
          color: Colors.green.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "TODAY SELL",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "Total Customers: $todaySell",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  "₹ $todayAmount",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  /// ================= TODAY SELL CARD =================
  Widget _totalSellCard() {
    return SizedBox(
      width: 300,
      height: 200,
      child: Card(
        color: Colors.blueGrey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "TOTAL SELL",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "$totalSell টি ইনভয়েস",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "₹ $totalAmount",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
