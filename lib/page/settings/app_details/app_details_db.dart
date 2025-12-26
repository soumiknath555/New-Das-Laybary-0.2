// ================= app_details_db.dart =================
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDetailsDB {
  static final AppDetailsDB instance = AppDetailsDB._init();
  static Database? _db;

  AppDetailsDB._init();

  // ---------------- DB INIT ----------------
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    Directory dir;

    if (Platform.isWindows) {
      dir = Directory(r'C:\Users\Soumik Nath\New Das Laybary');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final String path = join(dir.path, 'app_details.db');
    print('APP DETAILS DB PATH: $path');

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // ---------------- TABLE ----------------
  Future<void> _createDB(Database db, int version) async {
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
  }

  // ---------------- QUERIES ----------------

  /// 🔹 GET SINGLE ROW
  Future<Map<String, dynamic>?> getDetails() async {
    final db = await database;
    final res = await db.query('app_details', where: 'id = 1');
    return res.isNotEmpty ? res.first : null;
  }

  /// 🔹 INSERT OR UPDATE (ONLY ONE ROW)
  Future<void> saveDetails(Map<String, dynamic> data) async {
    final db = await database;
    final exists = await getDetails();

    if (exists == null) {
      await db.insert('app_details', {...data, 'id': 1});
    } else {
      await db.update(
        'app_details',
        data,
        where: 'id = 1',
      );
    }
  }
}
