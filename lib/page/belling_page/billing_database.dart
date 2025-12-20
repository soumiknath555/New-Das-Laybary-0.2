import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BillingDatabase {
  static final BillingDatabase instance = BillingDatabase._init();
  static Database? _database;

  BillingDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('library.db'); // 🔴 SAME DB FILE
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreateDB, // ⚠️ first run only
    );
  }

  // ⚠️ TABLE CREATE (same as yours)
  Future<void> _onCreateDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        title TEXT,
        author TEXT,
        description TEXT,

        publication_id INTEGER,
        publication_name TEXT,

        book_type_id INTEGER,
        book_type_name TEXT,
        
        book_language TEXT,

        class_id INTEGER,
        class_name TEXT,

        mrp INTEGER,
        sell_discount INTEGER,
        purchase_discount INTEGER,
        price_type TEXT,

        purchase_price INTEGER,
        sell_price INTEGER,
        profit INTEGER,

        quantity INTEGER,
        shop_list TEXT,

        front_image BLOB,
        created_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS book_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER,
        image BLOB
      )
    ''');
  }

  // ✅ GET ALL BOOKS (NO FILTER)
  Future<List<Map<String, dynamic>>> getAllBooks() async {
    final db = await database;
    return await db.query(
      'books',
      orderBy: 'id DESC',
    );
  }

  // ✅ SEARCH (optional)
  Future<List<Map<String, dynamic>>> searchBooks(String keyword) async {
    final db = await database;

    if (keyword.isEmpty) {
      return getAllBooks();
    }

    return await db.query(
      'books',
      where: '''
        title LIKE ? OR
        author LIKE ? OR
        publication_name LIKE ? OR
        class_name LIKE ? OR
        book_type_name LIKE ? OR
        book_language LIKE ?
      ''',
      whereArgs: List.filled(6, '%$keyword%'),
      orderBy: 'id DESC',
    );
  }
}
