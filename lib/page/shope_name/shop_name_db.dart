import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class ShopNameDB {
  static final ShopNameDB instance = ShopNameDB._init();
  static Database? _database;

  ShopNameDB._init();

  // ---------------- DB INIT ----------------
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("shop_name.db");
    return _database!;
  }

  /// ✅ Windows + Android SAFE PATH
  Future<Database> _initDB(String fileName) async {
    Directory dir;

    if (Platform.isWindows) {
      // 👉 তোমার চাওয়া folder
      dir = Directory(r'C:\Users\Soumik Nath\New Das Laybary');

      // folder না থাকলে create করবে
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      // 👉 Android / Mobile safe path
      dir = await getApplicationDocumentsDirectory();
    }

    final String path = join(dir.path, fileName);
    print('DB PATH: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }


  // ---------------- TABLE ----------------
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE shop_name (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        location TEXT
      )
    ''');
  }

  // ---------------- CRUD ----------------

  Future<int> addData(String name, String location) async {
    final db = await database;
    return await db.insert(
      "shop_name",
      {
        'name': name,
        'location': location,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await database;
    return await db.query("shop_name", orderBy: "id DESC");
  }

  Future<int> update(int id, String name, String location) async {
    final db = await database;
    return await db.update(
      "shop_name",
      {
        'name': name,
        'location': location,
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      "shop_name",
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
