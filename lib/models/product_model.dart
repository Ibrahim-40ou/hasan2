import 'dart:developer';

class ProductModel {
  String? id;
  String name;
  String brandId;
  bool isWeight;
  double quantity;
  double price;
  double cost;
  double massSalePrice;
  String image;
  double sold;
  String? description;
  String? note;
  DateTime createdAt;
  DateTime? updatedAt;

  ProductModel({
    this.id,
    required this.name,
    required this.brandId,
    required this.isWeight,
    required this.quantity,
    required this.price,
    required this.cost,
    required this.massSalePrice,
    required this.image,
    this.sold = 0.0,
    this.description,
    this.note,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProductModel(
        id: json['product_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        brandId: json['brand_id'] as String? ?? '',
        isWeight: json['is_weight'] as bool? ?? false,
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
        massSalePrice: (json['mass_sale_price'] as num?)?.toDouble() ?? 0.0,
        image: json['image'] as String? ?? '',
        sold: json['sold'] != null ? (json['sold'] as num?)?.toDouble() ?? 0.0 : 0.0,
        description: json['description'] as String?,
        note: json['note'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          json['created_at'] is String
              ? int.parse(json['created_at'] as String)
              : (json['created_at'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
        ),
        updatedAt: json['updated_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                json['updated_at'] is String ? int.parse(json['updated_at'] as String) : json['updated_at'] as int,
              )
            : null,
      );
    } catch (e) {
      log('Error parsing ProductModel from JSON: $e');
      log('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'brand_id': brandId,
      'is_weight': isWeight,
      'quantity': quantity,
      'price': price,
      'cost': cost,
      'mass_sale_price': massSalePrice,
      'image': image,
      'sold': sold,
      'description': description,
      'note': note,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'deleted_at': null,
    };
  }
}
