import 'package:flutter/material.dart';

class SellBillingDetailsPage extends StatelessWidget {
  final int invoiceId;

  const SellBillingDetailsPage({
    super.key,
    required this.invoiceId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121212),
      appBar: AppBar(
        title: Text("Bill Details #$invoiceId"),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          "Invoice item details will appear here",
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
