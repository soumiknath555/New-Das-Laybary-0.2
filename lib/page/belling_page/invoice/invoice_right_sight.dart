import 'package:flutter/material.dart';
import 'package:new_das_laybary_2/page/belling_page/invoice/pdf/billing_pdf.dart';
import 'package:new_das_laybary_2/page/belling_page/invoice/pdf/db_helper.dart';
import 'package:open_filex/open_filex.dart';

import 'invoice_left_preview.dart';

class InvoiceRightPanel extends StatelessWidget {
  final GlobalKey<InvoiceLeftPreviewState> leftPreviewKey;

  const InvoiceRightPanel({
    super.key,
    required this.leftPreviewKey,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          /// ================= OPEN BUTTON =================
          ElevatedButton.icon(
            icon: const Icon(Icons.open_in_new),
            label: const Text("Open"),
            onPressed: () async {

              final leftState = leftPreviewKey.currentState;
              if (leftState == null) return;

              final invoiceData = leftState.widget.calculateInvoice();
              final totalPayable = invoiceData['finalPayable'];

              final invoiceNo = await DBHelper.getNextInvoiceNo();

              /// SAVE INVOICE
              await DBHelper.saveInvoice({
                "invoice_no": invoiceNo,
                "customer_name": leftState.widget.nameCtrl.text,
                "customer_phone": leftState.widget.phoneCtrl.text,
                "customer_address": leftState.widget.addressCtrl.text,
                "school": leftState.widget.schoolName,
                "class": leftState.widget.className,
                "total_amount": totalPayable,
                "created_at": DateTime.now().toIso8601String(),
              });

              /// GENERATE PDF
              final file = await BillingPDF.generate(
                invoiceNo: invoiceNo,
                customerName: leftState.widget.nameCtrl.text,
                customerPhone: leftState.widget.phoneCtrl.text,
                customerAddress: leftState.widget.addressCtrl.text,
                school: leftState.widget.schoolName ?? '',
                className: leftState.widget.className ?? '',
                books: leftState.editableBooks.values.toList(),
                totalAmount: totalPayable,
              );

              /// OPEN PDF
              await OpenFilex.open(file.path);
            },
          ),

          const SizedBox(height: 10),

          /// ================= SAVE ONLY =================
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text("Save"),
            onPressed: () async {

              final leftState = leftPreviewKey.currentState;
              if (leftState == null) return;

              final invoiceData = leftState.widget.calculateInvoice();

              await DBHelper.saveInvoice({
                "invoice_no": await DBHelper.getNextInvoiceNo(),
                "customer_name": leftState.widget.nameCtrl.text,
                "customer_phone": leftState.widget.phoneCtrl.text,
                "customer_address": leftState.widget.addressCtrl.text,
                "school": leftState.widget.schoolName,
                "class": leftState.widget.className,
                "total_amount": invoiceData['finalPayable'],
                "created_at": DateTime.now().toIso8601String(),
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Invoice Saved")),
              );
            },
          ),

          const SizedBox(height: 10),

          /// ================= PRINT =================
          ElevatedButton.icon(
            icon: const Icon(Icons.print),
            label: const Text("Print"),
            onPressed: () async {
              // পরে printer package বসানো যাবে
            },
          ),

          const SizedBox(height: 10),

          /// ================= WHATSAPP =================
          ElevatedButton.icon(
            icon: const Icon(Icons.call),
            label: const Text("WhatsApp"),
            onPressed: () async {
              // pdf path নিয়ে whatsapp share করা যাবে
            },
          ),
        ],
      ),
    );
  }
}
