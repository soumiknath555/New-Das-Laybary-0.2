import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class BooksTypeDB {
  static final BooksTypeDB instance = BooksTypeDB._init();
  static Database? _database;

  BooksTypeDB._init();

  // ---------------- DB INIT ----------------
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('books_type.db');
    return _database!;
  }

  /// ✅ Android + Windows SAFE DB path
  Future<Database> _initDB(String fileName) async {
    Directory dir;

    if (Platform.isWindows) {
      // 👉 Windows-এ তোমার নির্দিষ্ট folder
      dir = Directory(r'C:\Users\Soumik Nath\New Das Laybary');

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      // 👉 Android / Mobile-এ safe system path
      dir = await getApplicationDocumentsDirectory();
    }

    final String path = join(dir.path, fileName);
    print('DB PATH: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreateDB,
    );
  }


  // ---------------- TABLE ----------------
  Future<void> _onCreateDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books_type (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        pub_id INTEGER,
        pub_name TEXT,

        type_name TEXT,

        purchase REAL,
        sell REAL,

        created_at INTEGER
      )
    ''');
  }

  // ---------------- CRUD ----------------

  Future<int> addData(
      int pubId,
      String pubName,
      String typeName,
      double purchase,
      double sell,
      ) async {
    final db = await database;
    return await db.insert('books_type', {
      'pub_id': pubId,
      'pub_name': pubName,
      'type_name': typeName,
      'purchase': purchase,
      'sell': sell,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await database;
    return await db.query(
      'books_type',
      orderBy: 'created_at DESC',
    );
  }

  Future<int> update(
      int id,
      int pubId,
      String pubName,
      String typeName,
      double purchase,
      double sell,
      ) async {
    final db = await database;
    return await db.update(
      'books_type',
      {
        'pub_id': pubId,
        'pub_name': pubName,
        'type_name': typeName,
        'purchase': purchase,
        'sell': sell,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      'books_type',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
