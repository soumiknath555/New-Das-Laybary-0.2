import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SchoolBookDB {
  static final SchoolBookDB instance = SchoolBookDB._init();
  static Database? _database;

  SchoolBookDB._init();

  // ---------------- DB INIT ----------------
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('school_books.db');
    return _database!;
  }

  /// ✅ Android + Windows safe path
  Future<Database> _initDB(String fileName) async {
    Directory dir;

    if (Platform.isWindows) {
      // 👉 Windows custom DB folder
      dir = Directory(r'C:\Users\Soumik Nath\New Das Laybary');

      // folder না থাকলে auto create
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      // 👉 Android / Mobile safe directory
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
      CREATE TABLE school_books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        school_id INTEGER,
        school_name TEXT,
        book_id INTEGER,
        title TEXT,
        author TEXT,
        publication TEXT,
        medium TEXT,
        book_class TEXT,
        save_class TEXT
      )
    ''');
  }

  // ---------------- QUERIES ----------------

  /// 🔹 LEFT SIDE : class list
  Future<List<String>> getSaveClasses(int schoolId) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT DISTINCT save_class
      FROM school_books
      WHERE school_id = ?
      ''',
      [schoolId],
    );

    return result
        .map((e) => e['save_class'] as String)
        .toList();
  }

  /// 🔹 RIGHT SIDE : books by class
  Future<List<Map<String, dynamic>>> getBooksByClass(
      int schoolId,
      String saveClass,
      ) async {
    final db = await database;

    return await db.query(
      'school_books',
      where: 'school_id = ? AND save_class = ?',
      whereArgs: [schoolId, saveClass],
    );
  }
}
