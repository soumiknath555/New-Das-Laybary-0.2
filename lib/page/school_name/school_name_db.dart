import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SchoolNameDB {
  static final SchoolNameDB instance = SchoolNameDB._init();
  static Database? _database;

  SchoolNameDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("school_name.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE school_name (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            short_form TEXT
          )
        ''');
      },
    );
  }

  Future<int> addData(String name, String shortForm) async {
    final db = await instance.database;
    return await db.insert("school_name", {
      'name': name,
      'short_form': shortForm,
    });
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await instance.database;
    return await db.query("school_name", orderBy: "id DESC");
  }

  Future<int> update(int id, String name, String shortForm) async {
    final db = await instance.database;
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
    final db = await instance.database;
    return await db.delete("school_name", where: "id = ?", whereArgs: [id]);
  }
}
