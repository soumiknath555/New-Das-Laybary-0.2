import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE classes (
            id TEXT PRIMARY KEY,
            name TEXT,
            updatedAt INTEGER
          )
        ''');
      },
    );
  }

  // Get All
  Future<List<ClassItem>> getAll() async {
    final db = await instance.database;
    final data = await db.query("classes", orderBy: "name ASC");

    return data.map((e) => ClassItem.fromMap(e)).toList();
  }

  // Create
  Future<void> createClass(String name) async {
    final db = await instance.database;
    final id = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert("classes", {
      'id': id,
      'name': name,
      'updatedAt': now,
    });
  }

  // Update
  Future<void> updateClass(ClassItem item, String newName) async {
    final db = await instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      "classes",
      {
        'name': newName,
        'updatedAt': now,
      },
      where: "id = ?",
      whereArgs: [item.id],
    );
  }

  // Delete
  Future<void> deleteClass(String id) async {
    final db = await instance.database;
    await db.delete("classes", where: "id = ?", whereArgs: [id]);
  }
}
