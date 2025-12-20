// lib/db/books_db.dart
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BooksDB {
  static final BooksDB instance = BooksDB._init();
  static Database? _database;

  BooksDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('books.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        author TEXT,
        description TEXT,
        publication_name TEXT,
        book_type_name TEXT,
        class_name TEXT,
        shop_list TEXT,
        mrp REAL,
        sell REAL,
        purchase REAL,
        quantity INTEGER,
        image BLOB,
        created_at INTEGER
      )
    ''');
  }

  Future<int> addBook(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('books', data);
  }

  Future<List<Map<String, dynamic>>> getAllBooks() async {
    final db = await instance.database;
    return await db.query('books', orderBy: 'created_at DESC');
  }

  Future<int> updateBook(int id, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update('books', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteBook(int id) async {
    final db = await instance.database;
    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }
}
