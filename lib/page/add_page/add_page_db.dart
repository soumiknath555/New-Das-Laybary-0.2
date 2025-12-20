import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BooksAddDB {
  static final BooksAddDB instance = BooksAddDB._init();
  static Database? _database;

  BooksAddDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('books.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreateDB,
      onUpgrade: _onUpgradeDB, // ✅ ADD THIS
    );
  }

  Future<void> _onUpgradeDB(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {
    if (oldVersion < 2) {
      await db.execute('''
    CREATE TABLE IF NOT EXISTS book_images (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id INTEGER,
      image BLOB
    )
    ''');
    }
  }


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

  Map<String, dynamic> buildDBMap({
    required String title,
    String? author,
    String? description,

    int? publicationId,
    String? publicationName,

    int? bookTypeId,
    String? bookTypeName,
    String? bookLanguage,


    int? classId,
    String? className,

    required int mrp,
    required int sellDiscount,
    required int purchaseDiscount,
    required String priceType,

    required int purchasePrice,
    required int sellPrice,
    required int profit,

    int quantity = 0,
    String? shopList,
    Uint8List? frontImage,
  }) {
    return {
      "title": title,
      "author": author,
      "description": description,

      "publication_id": publicationId,
      "publication_name": publicationName,

      "book_type_id": bookTypeId,
      "book_type_name": bookTypeName,
      "book_language": bookLanguage,

      "class_id": classId,
      "class_name": className,

      "mrp": mrp,
      "sell_discount": sellDiscount,
      "purchase_discount": purchaseDiscount,
      "price_type": priceType,

      "purchase_price": purchasePrice,
      "sell_price": sellPrice,
      "profit": profit,

      "quantity": quantity,
      "shop_list": shopList,

      "front_image": frontImage,
      "created_at": DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// ---------- INSERT ----------
  Future<int> addBook(Map<String, dynamic> map) async {
    final db = await database;
    return await db.insert('books', map);
  }

  Future<void> insertBookImage({
    required int bookId,
    required Uint8List imageBytes,
  }) async {
    final db = await database;
    await db.insert('book_images', {
      'book_id': bookId,
      'image': imageBytes,
    });
  }

  Future<int> updateBook(int id, Map<String, dynamic> values) async {
    final db = await database;
    return await db.update(
      'books',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }




  Future<void> deleteBookImage(int bookId, Uint8List imageBytes) async {
    final db = await database;
    await db.delete(
      'book_images',
      where: 'book_id = ? AND image = ?',
      whereArgs: [bookId, imageBytes],
    );
  }

  Future<List<Map<String, dynamic>>> getImagesWithIdByBookId(int bookId) async {
    final db = await database;
    return await db.query(
      'book_images',
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
  }



  Future<void> deleteBookImageById(int imageId) async {
    final db = await database;
    await db.delete(
      'book_images',
      where: 'id = ?',
      whereArgs: [imageId],
    );
  }



  Future<Uint8List?> getFirstImageByBookId(int bookId) async {
    final db = await database;

    final res = await db.query(
      'book_images',
      where: 'book_id = ?',
      whereArgs: [bookId],
      limit: 1,
    );

    if (res.isEmpty) return null;
    return res.first['image'] as Uint8List;
  }


  Future<List<Uint8List>> getImagesByBookId(int bookId) async {
    final db = await database;

    final res = await db.query(
      'book_images',
      where: 'book_id = ?',
      whereArgs: [bookId],
    );

    return res.map((e) => e['image'] as Uint8List).toList();
  }


  /// ---------- READ ALL BOOKS ----------
  Future<List<Map<String, dynamic>>> getAllBooks() async {
    final db = await database;
    return await db.query(
      'books',
      orderBy: 'created_at DESC',
    );
  }

  Future<int> deleteBook(int id) async {
    final db = await database;
    return await db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}



