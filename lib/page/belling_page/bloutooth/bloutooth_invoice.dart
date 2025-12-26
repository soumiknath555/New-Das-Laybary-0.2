import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InvoicePage extends StatelessWidget {
  final String invoiceData;

  const InvoicePage({super.key, required this.invoiceData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Invoice")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Text(invoiceData),
      ),
    );
  }
}
