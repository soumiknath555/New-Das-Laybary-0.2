import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class PublicationDB {
  static final PublicationDB instance = PublicationDB._init();
  static Database? _database;

  PublicationDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("publication.db");
    return _database!;
  }

  /// ✅ Android + Windows safe DB path
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
      onCreate: _onCreateDB,
    );
  }


  Future _onCreateDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE publication (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
  }

  // ================= CRUD =================

  Future<int> addPublication(String name) async {
    final db = await database;
    return await db.insert("publication", {'name': name});
  }

  Future<List<Map<String, dynamic>>> getAllPublications() async {
    final db = await database;
    return await db.query("publication", orderBy: "id ASC");
  }

  Future<int> updatePublication(int id, String newName) async {
    final db = await database;
    return await db.update(
      "publication",
      {'name': newName},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deletePublication(int id) async {
    final db = await database;
    return await db.delete(
      "publication",
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
