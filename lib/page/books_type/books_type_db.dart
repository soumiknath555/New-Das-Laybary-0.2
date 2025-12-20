import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

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
    return await db.query('books_type', orderBy: 'created_at DESC');
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
