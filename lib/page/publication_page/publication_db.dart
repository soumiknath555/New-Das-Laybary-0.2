import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PublicationDB {
  static final PublicationDB instance = PublicationDB._init();
  static Database? _database;

  PublicationDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("publication.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

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

  Future<int> addPublication(String name) async {
    final db = await instance.database;
    return await db.insert("publication", {'name': name});
  }

  Future<List<Map<String, dynamic>>> getAllPublications() async {
    final db = await instance.database;
    return await db.query("publication", orderBy: "id ASC");
  }

  Future<int> updatePublication(int id, String newName) async {
    final db = await instance.database;
    return await db.update(
      "publication",
      {'name': newName},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deletePublication(int id) async {
    final db = await instance.database;
    return await db.delete(
      "publication",
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
