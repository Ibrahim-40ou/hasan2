class BrandModel {
  String name;
  String? id;
  final DateTime? createdAt;
  DateTime? editedAt;

  BrandModel({required this.name, this.id, this.createdAt, this.editedAt});

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      name: json['brand_name'] as String,
      id: json['brand_id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(int.parse(json['created_at'] as String)),
      editedAt: json['edited_at'] != null ? DateTime.fromMillisecondsSinceEpoch(int.parse(json['edited_at'] as String)) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'brand_name': name, 'created_at': DateTime.now().millisecondsSinceEpoch.toString(), 'deleted_at': null};
  }
}
