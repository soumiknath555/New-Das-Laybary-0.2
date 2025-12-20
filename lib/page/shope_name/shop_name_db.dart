import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ShopNameDB {
  static final ShopNameDB instance = ShopNameDB._init();
  static Database? _database;

  ShopNameDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("shop_name.db");
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
          CREATE TABLE shop_name (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            location TEXT
          )
        ''');
      },
    );
  }

  Future<int> addData(String name, String location) async {
    final db = await instance.database;
    return await db.insert("shop_name", {
      'name': name,
      'location': location,
    });
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await instance.database;
    return await db.query("shop_name", orderBy: "id DESC");
  }

  Future<int> update(int id, String name, String location) async {
    final db = await instance.database;

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
    final db = await instance.database;
    return await db.delete("shop_name", where: "id=?", whereArgs: [id]);
  }
}
