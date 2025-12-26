import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BillingDatabase {
  BillingDatabase._();
  static final BillingDatabase instance = BillingDatabase._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory dir;

    if (Platform.isWindows) {
      // 👉 তোমার custom Windows folder
      dir = Directory(r'C:\Users\Soumik Nath\New Das Laybary');

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      // 👉 Android safe location
      dir = await getApplicationDocumentsDirectory();
    }

    final String path = join(dir.path, 'billing.db');
    print('BILLING DB PATH: $path');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE invoices (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          phone TEXT,
          address TEXT,
          totalQty INTEGER,
          totalMrp INTEGER,
          totalSaved INTEGER,
          extraDiscount INTEGER,
          finalPayable INTEGER,
          createdAt TEXT
        )
      ''');
      },
    );
  }


  /// ✅ SAVE INVOICE
  Future<void> saveInvoice({
    required Map<String, dynamic> invoiceData,
    required Map<int, int> cart,
    required List<Map<String, dynamic>> books,
    String? name,
    String? phone,
    String? address,
  }) async {
    final db = await database;

    await db.insert('invoices', {
      "name": name,
      "phone": phone,
      "address": address,
      "totalQty": invoiceData['totalQty'],
      "totalMrp": invoiceData['totalMrp'],
      "totalSaved": invoiceData['totalSaved'],
      "extraDiscount": invoiceData['extraDiscount'],
      "finalPayable": invoiceData['finalPayable'],
      "createdAt": DateTime.now().toIso8601String(),
    });
  }




  /// ✅ TODAY SELL COUNT + TOTAL AMOUNT
  Future<Map<String, int>> getTodaySell() async {
    final db = await database;

    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .toIso8601String();

    final result = await db.rawQuery('''
    SELECT 
      COUNT(id) as totalSell,
      IFNULL(SUM(finalPayable), 0) as totalAmount
    FROM invoices
    WHERE createdAt >= ?
  ''', [start]);

    return {
      "totalSell": result.first["totalSell"] as int,
      "totalAmount": result.first["totalAmount"] as int,
    };
  }


  /// ✅ TOTAL SELL COUNT + TOTAL AMOUNT (ALL TIME)
  Future<Map<String, int>> getTotalSell() async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT 
      COUNT(id) as totalSell,
      IFNULL(SUM(finalPayable), 0) as totalAmount
    FROM invoices
  ''');

    return {
      "totalSell": result.first["totalSell"] as int,
      "totalAmount": result.first["totalAmount"] as int,
    };
  }




}

