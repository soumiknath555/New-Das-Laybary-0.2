import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PurchaseDatabase {
  PurchaseDatabase._();
  static final PurchaseDatabase instance = PurchaseDatabase._();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    Directory dir;

    if (Platform.isWindows) {
      // 👉 Windows custom DB folder
      dir = Directory(r'C:\Users\Soumik Nath\New Das Laybary');

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      // 👉 Android / Mobile safe path
      dir = await getApplicationDocumentsDirectory();
    }

    final String path = join(dir.path, 'purchase.db');
    print('PURCHASE DB PATH: $path');

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }


  Future<void> _createDB(Database db, int version) async {
    /// SHOP
    await db.execute('''
      CREATE TABLE shop_name (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        location TEXT
      )
    ''');

    /// PURCHASE INVOICE
    await db.execute('''
      CREATE TABLE purchase_invoice (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_id INTEGER,
        total_qty INTEGER,
        total_amount INTEGER,
        created_at TEXT
      )
    ''');

    /// PURCHASE ITEMS
    await db.execute('''
      CREATE TABLE purchase_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER,
        book_id INTEGER,
        qty INTEGER,
        purchase_price INTEGER
      )
    ''');
  }

  /// SHOPS
  Future<List<Map<String, dynamic>>> getAllShops() async {
    final db = await database;
    return db.query('shop_name');
  }
}
