import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../settings/app_details/app_details_db.dart';

class BillingPDF {
  static Future<File> generate({
    required int invoiceNo,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required String school,
    required String className,
    required List<Map<String, dynamic>> books,
    required int totalAmount,
  }) async {
    final pdf = pw.Document();

    /// ===== APP DETAILS =====
    final app = await AppDetailsDB.instance.getDetails();
    if (app == null) {
      throw Exception("App details not found");
    }

    /// ===== FONTS (UNICODE SAFE) =====
    final regularFont =
    pw.Font.ttf(await rootBundle.load("assets/fonts/NotoSans-Regular.ttf"));
    final boldFont =
    pw.Font.ttf(await rootBundle.load("assets/fonts/NotoSans-Bold.ttf"));

    final now = DateTime.now();

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          margin: pw.EdgeInsets.zero,
          theme: pw.ThemeData.withFont(
            base: regularFont,
            bold: boldFont,
          ),
        ),
        build: (context) {

          /// ===== SUMMARY CALCULATION =====
          int totalQty = 0;
          int totalMrp = 0;
          int totalSaved = 0;
          int amountToPay = 0;

          for (final b in books) {
            final int qty = (b['qty'] ?? 1).toInt();
            final int mrp = (b['mrp'] ?? 0).toInt();
            final int sell = (b['sell_price'] ?? 0).toInt();

            totalQty += qty;
            totalMrp += mrp * qty;
            totalSaved += (mrp - sell) * qty;
            amountToPay += sell * qty;
          }

          return pw.Padding(

          padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                /// ===== SHOP HEADER =====
                pw.Center(
                  child: pw.Text(
                    app['shop_name'] ?? '',
                    style: pw.TextStyle(fontSize: 24, font: boldFont),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    app['address'] ?? '',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    "${app['phone']}${app['whatsapp']}",
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),

                pw.Divider(),

                /// ===== INVOICE INFO =====
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Invoice No: ${invoiceNo.toString().padLeft(0, '0')}",
                      style: pw.TextStyle(font: boldFont, fontSize: 10),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          "Date: ${now.day}/${now.month}/${now.year}",
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          "Time: ${now.hour}:${now.minute.toString().padLeft(2, '0')}  ${_dayName(now.weekday)}",
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),

                /// ===== CUSTOMER =====
                pw.Text("Customer: $customerName"),
                pw.Text("Phone: $customerPhone"),
                pw.Text("Address: $customerAddress"),
                pw.Text("School: $school  ||      $className"),

                pw.SizedBox(height: 10),

                /// ===== BOOK TABLE =====
                pw.Table(
                  border: pw.TableBorder.all(width: 0.5),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(4),
                    1: pw.FlexColumnWidth(4),
                    2: pw.FlexColumnWidth(1.5),
                    3: pw.FlexColumnWidth(1),
                    4: pw.FlexColumnWidth(1),
                    5: pw.FlexColumnWidth(0.8),
                    6: pw.FlexColumnWidth(1),
                  },
                  children: [

                    /// HEADER
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _th("Book"),
                        _th("Author"),
                        _th("Class"),
                        _th("MRP"),
                        _th("Sell"),
                        _th("Save"),
                        _th("Total"),
                      ],
                    ),

                    /// ROWS
                    ...books.map((b) {
                      final qty = (b['qty'] ?? 1).toInt();
                      final mrp = (b['mrp'] ?? 0).toInt();
                      final sell = (b['sell_price'] ?? 0).toInt();

                      final sellTotal = sell * qty;
                      final saveTotal = (mrp - sell) * qty;

                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  b['title'] ?? '',
                                  style: pw.TextStyle(font: boldFont, fontSize: 10),
                                ),
                                if ((b['publication_name'] ?? '').toString().isNotEmpty)
                                  pw.Text(
                                    "(${b['publication_name']})",
                                    style: const pw.TextStyle(
                                      fontSize: 8,
                                      color: PdfColors.grey700,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          _td(b['author'] ?? ''),
                          _td(b['class_name'] ?? ''),
                          _td("₹$mrp"),
                          _td("₹$sell"),
                          _td("₹$saveTotal"),
                          _td("₹$sellTotal"),
                        ],
                      );
                    }).toList(),
                  ],
                ),

                /// ===== SUMMARY =====
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _summary("Total Books", "$totalQty pcs" ,  color: PdfColors.black,),
                      _summary("Total MRP", "₹$totalMrp" , color: PdfColors.black,),
                      _summary("Total Saved", "₹$totalSaved", color: PdfColors.black,),
                      pw.Divider(),
                      _summary(
                        "Amount to Pay",
                        "₹$amountToPay",
                        bold: true,
                        color: PdfColors.black,
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),

                pw.Divider(),

                pw.Column(
                  children: [

                    pw.Center(
                      child: pw.Text(
                        app['msg1'] ?? '',
                      ),
                    ),
                    pw.Center(
                      child: pw.Text(
                        app['msg2'] ?? '',
                      ),
                    ),

                    pw.Center(
                      child: pw.Text(
                        app['msg3'] ?? '',
                      ),
                    ),

                    pw.Center(
                      child: pw.Text(
                        app['notice'] ?? '',
                        style: pw.TextStyle(fontSize: 14, font: boldFont),
                      ),
                    ),
                  ]
                ),


              ],
            )

          );
        },
      ),
    );

    /// ===== SAVE FILE =====
    final dir =
    Directory(r"C:\Users\Soumik Nath\New Das Laybary\Invoice Pdf");

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final file = File(
      "${dir.path}/Invoice_${invoiceNo.toString().padLeft(4, '0')}.pdf",
    );

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _th(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
    ),
  );

  static pw.Widget _td(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
  );


  static pw.Widget _summary(String label, String value,
      {bool bold = false, PdfColor color = PdfColors.black}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
              pw.Text(value,
                  style: pw.TextStyle(
                      fontSize: bold ? 12 : 10,
                      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                      color: color)),
            ]),
      );

  static String _dayName(int d) {
    return [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ][d - 1];
  }
}
