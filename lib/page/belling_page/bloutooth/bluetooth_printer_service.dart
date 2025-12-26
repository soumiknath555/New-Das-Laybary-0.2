import 'dart:async';
import 'package:esc_pos_printer_plus/esc_pos_printer_plus.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_esc_pos_bluetooth/flutter_esc_pos_bluetooth.dart';

class BluetoothPrinterService {
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> printers = [];
  PrinterBluetooth? selectedPrinter;

  /// ============================
  /// START BLUETOOTH SCAN
  /// ============================
  Stream<List<PrinterBluetooth>> scanPrinters() {
    printerManager.startScan(const Duration(seconds: 5));
    return printerManager.scanResults;
  }

  /// ============================
  /// SELECT PRINTER
  /// ============================
  void selectPrinter(PrinterBluetooth printer) {
    selectedPrinter = printer;
  }

  /// ============================
  /// PRINT INVOICE TO THERMAL
  /// ============================
  Future<String> printInvoice({
    required Map<String, dynamic> invoiceData, // invoice items + totals
  }) async {
    if (selectedPrinter == null) {
      return "PRINTER_NOT_SELECTED";
    }

    printerManager.selectPrinter(selectedPrinter!);

    /// Load ESC/POS profile & paper size
    const PaperSize paper = PaperSize.mm58;
    final profile = await CapabilityProfile.load();
    final generator = Generator(paper, profile);
    List<int> bytes = [];

    /// -----------------------------
    /// HEADER
    /// -----------------------------
    bytes += generator.text(
      "NEW DAS LIBRARY",
      styles: const PosStyles(
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        align: PosAlign.center,
      ),
    );

    bytes += generator.text(
      "Hasnabad, behind Naisho Abas,",
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.text(
      "Above Das Watch Shop, North 24 Pgs",
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(1);
    bytes += generator.hr();

    /// -----------------------------
    /// ITEMS
    /// -----------------------------
    final items = invoiceData["items"] as List<dynamic>;

    for (var item in items) {
      bytes += generator.row([
        PosColumn(
          text: item["title"],
          width: 6,
        ),
        PosColumn(
          text: "x${item["qty"]}",
          width: 2,
        ),
        PosColumn(
          text: "₹${item["total"]}",
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    /// -----------------------------
    /// TOTALS
    /// -----------------------------
    bytes += generator.row([
      PosColumn(
        text: "Total Books:",
        width: 6,
      ),
      PosColumn(
        text: "${invoiceData["totalQty"]}",
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: "Total MRP:",
        width: 6,
      ),
      PosColumn(
        text: "₹${invoiceData["totalMrp"]}",
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: "Saved:",
        width: 6,
      ),
      PosColumn(
        text: "₹${invoiceData["totalSaved"]}",
        width: 6,
        styles: const PosStyles(
          align: PosAlign.right,
          bold: true,
        ),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: "Extra Discount:",
        width: 6,
      ),
      PosColumn(
        text: "-₹${invoiceData["extraDiscount"]}",
        width: 6,
        styles: const PosStyles(
          align: PosAlign.right,
          bold: true,
        ),
      ),
    ]);

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
        text: "Final Payable:",
        width: 6,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: "₹${invoiceData["finalPayable"]}",
        width: 6,
        styles: const PosStyles(
          bold: true,
          align: PosAlign.right,
          height: PosTextSize.size2,
        ),
      ),
    ]);

    bytes += generator.feed(1);
    bytes += generator.hr();

    bytes += generator.text(
      "Thank You!",
      styles: const PosStyles(
        bold: true,
        align: PosAlign.center,
      ),
    );

    bytes += generator.text(
      "Visit Again ❤️",
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.cut();

    /// SEND TO PRINTER
    final result = await printerManager.printTicket(bytes);

    return result.msg;
  }
}
