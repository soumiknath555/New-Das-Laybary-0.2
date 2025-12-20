class PublicationModel {
  final int id;
  final String name;

  PublicationModel({required this.id, required this.name});

  factory PublicationModel.fromMap(Map<String, dynamic> map) {
    return PublicationModel(
      id: map['id'],
      name: map['name'],
    );
  }
}
