class ClassModel {
  final int id;
  final String name;

  ClassModel({required this.id, required this.name});

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      id: map['id'],
      name: map['name'],
    );
  }
}
