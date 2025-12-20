import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SchoolBookDB {
  static final SchoolBookDB instance = SchoolBookDB._init();
  static Database? _database;

  SchoolBookDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('school_books.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
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

    return result.map((e) => e['save_class'] as String).toList();
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
