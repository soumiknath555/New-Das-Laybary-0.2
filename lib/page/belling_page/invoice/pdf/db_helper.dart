import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), "app.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {

        /// APP DETAILS
        await db.execute('''
          CREATE TABLE app_details (
            id INTEGER PRIMARY KEY,
            shop_name TEXT,
            address TEXT,
            phone TEXT,
            whatsapp TEXT,
            notice TEXT,
            msg1 TEXT,
            msg2 TEXT,
            msg3 TEXT
          )
        ''');

        /// INVOICE COUNTER
        await db.execute('''
          CREATE TABLE invoice_counter (
            id INTEGER PRIMARY KEY,
            last_no INTEGER
          )
        ''');

        /// INVOICE MASTER
        await db.execute('''
          CREATE TABLE invoice (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            invoice_no INTEGER,
            customer_name TEXT,
            customer_phone TEXT,
            customer_address TEXT,
            school TEXT,
            class TEXT,
            total_amount INTEGER,
            created_at TEXT
          )
        ''');

        await db.insert("invoice_counter", {
          "id": 1,
          "last_no": 0,
        });

        await db.insert("app_details", {
          "id": 1,
          "shop_name": "",
          "address": "",
          "phone": "",
          "whatsapp": "",
          "notice": "",
          "msg1": "",
          "msg2": "",
          "msg3": "",
        });
      },
    );
  }

  /// ===== INVOICE NUMBER =====
  static Future<int> getNextInvoiceNo() async {
    final dbClient = await db;

    final res = await dbClient.query(
      "invoice_counter",
      where: "id = ?",
      whereArgs: [1],
    );

    int last = res.first["last_no"] as int;
    int next = last + 1;

    await dbClient.update(
      "invoice_counter",
      {"last_no": next},
      where: "id = ?",
      whereArgs: [1],
    );

    return next;
  }

  /// ===== SAVE INVOICE =====
  static Future<void> saveInvoice(Map<String, dynamic> data) async {
    final dbClient = await db;
    await dbClient.insert("invoice", data);
  }
}
