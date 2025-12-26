import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class ClassItem {
  String id;
  String name;
  int updatedAt;

  ClassItem({
    required this.id,
    required this.name,
    required this.updatedAt,
  });

  factory ClassItem.fromMap(Map<String, dynamic> m) {
    return ClassItem(
      id: m['id'],
      name: m['name'],
      updatedAt: m['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'updatedAt': updatedAt,
    };
  }
}

class ClassRepository {
  static final ClassRepository instance = ClassRepository._init();
  static Database? _db;

  ClassRepository._init();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB("classes.db");
    return _db!;
  }

  /// ✅ Correct DB path for Android + Windows
  Future<Database> _initDB(String fileName) async {
    Directory dir;

    if (Platform.isWindows) {
      // 👉 Windows custom folder
      dir = Directory(r'C:\Users\Soumik Nath\New Das Laybary');

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      // 👉 Android / Mobile safe path
      dir = await getApplicationDocumentsDirectory();
    }

    final String path = join(dir.path, fileName);
    print('CLASSES DB PATH: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE classes (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          updatedAt INTEGER NOT NULL
        )
      ''');
      },
    );
  }

  // ================= CRUD =================

  Future<List<ClassItem>> getAll() async {
    final db = await database;
    final data = await db.query(
      "classes",
      orderBy: "name COLLATE NOCASE ASC",
    );
    return data.map((e) => ClassItem.fromMap(e)).toList();
  }

  Future<void> createClass(String name) async {
    final db = await database;

    await db.insert(
      "classes",
      {
        'id': const Uuid().v4(),
        'name': name,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateClass(ClassItem item, String newName) async {
    final db = await database;

    await db.update(
      "classes",
      {
        'name': newName,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: "id = ?",
      whereArgs: [item.id],
    );
  }

  Future<void> deleteClass(String id) async {
    final db = await database;
    await db.delete(
      "classes",
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
