import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SchoolNameDB {
  static final SchoolNameDB instance = SchoolNameDB._init();
  static Database? _database;

  SchoolNameDB._init();

  // ---------------- DB INIT ----------------
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("school_name.db");
    return _database!;
  }

  /// ✅ Android + Windows safe location
  Future<Database> _initDB(String fileName) async {
    Directory dir;

    if (Platform.isWindows) {
      // 👉 Windows: fixed DB folder
      dir = Directory(r'C:\Users\Soumik Nath\New Das Laybary');

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      // 👉 Android / Mobile: system safe path
      dir = await getApplicationDocumentsDirectory();
    }

    final String path = join(dir.path, fileName);
    print('DB PATH => $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreateDB,
    );
  }


  // ---------------- TABLE ----------------
  Future<void> _onCreateDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE school_name (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        short_form TEXT
      )
    ''');
  }

  // ---------------- CRUD ----------------

  Future<int> addData(String name, String shortForm) async {
    final db = await database;
    return await db.insert("school_name", {
      'name': name,
      'short_form': shortForm,
    });
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await database;
    return await db.query(
      "school_name",
      orderBy: "id DESC",
    );
  }

  Future<int> update(int id, String name, String shortForm) async {
    final db = await database;
    return await db.update(
      "school_name",
      {
        'name': name,
        'short_form': shortForm,
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      "school_name",
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
