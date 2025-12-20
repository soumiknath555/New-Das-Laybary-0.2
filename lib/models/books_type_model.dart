class BooksTypeModel {
  final int id;
  final int pubId;
  final String pubName;
  final String typeName;
  final double purchase;
  final double sell;

  BooksTypeModel({
    required this.id,
    required this.pubId,
    required this.pubName,
    required this.typeName,
    required this.purchase,
    required this.sell,
  });

  factory BooksTypeModel.fromMap(Map<String, dynamic> map) {
    return BooksTypeModel(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),

      pubId: map['pub_id'] is int
          ? map['pub_id']
          : int.parse(map['pub_id'].toString()),

      pubName: map['pub_name'] ?? "",

      typeName: map['type_name'] ?? "",

      // force convert to double (SQLite stores as num)
      purchase: (map['purchase'] as num).toDouble(),
      sell: (map['sell'] as num).toDouble(),
    );
  }
}
