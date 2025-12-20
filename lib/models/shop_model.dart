class ShopModel {
  final int id;
  final String name;
  final String location;

  ShopModel({required this.id, required this.name, required this.location});

  factory ShopModel.fromMap(Map<String, dynamic> map) {
    return ShopModel(
      id: map['id'],
      name: map['name'],
      location: map['location'],
    );
  }
}
