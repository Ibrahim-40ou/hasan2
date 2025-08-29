import 'dart:developer';

class TransactionModel {
  String? id;
  String productId;
  String productName;
  String brandId;
  double saleAmount;
  double profitMargin;
  double soldQuantity;
  double unitPrice;
  double unitCost;
  DateTime timestamp;
  DateTime createdAt;
  DateTime? updatedAt;

  TransactionModel({
    this.id,
    required this.productId,
    required this.productName,
    required this.brandId,
    required this.saleAmount,
    required this.profitMargin,
    required this.soldQuantity,
    required this.unitPrice,
    required this.unitCost,
    required this.timestamp,
    required this.createdAt,
    this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    try {
      return TransactionModel(
        id: json['transaction_id'] as String? ?? '',
        productId: json['product_id'] as String? ?? '',
        productName: json['product_name'] as String? ?? '',
        brandId: json['brand_id'] as String? ?? '',
        saleAmount: (json['sale_amount'] as num?)?.toDouble() ?? 0.0,
        profitMargin: (json['profit_margin'] as num?)?.toDouble() ?? 0.0,
        soldQuantity: (json['sold_quantity'] as num?)?.toDouble() ?? 0.0,
        unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
        unitCost: (json['unit_cost'] as num?)?.toDouble() ?? 0.0,
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          json['timestamp'] is String
              ? int.parse(json['timestamp'] as String)
              : (json['timestamp'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
        ),
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
      log('Error parsing TransactionModel from JSON: $e');
      log('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'brand_id': brandId,
      'sale_amount': saleAmount,
      'profit_margin': profitMargin,
      'sold_quantity': soldQuantity,
      'unit_price': unitPrice,
      'unit_cost': unitCost,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'deleted_at': null,
    };
  }

  // Helper method to calculate profit percentage
  double get profitPercentage {
    if (unitCost == 0) return 0.0;
    return ((unitPrice - unitCost) / unitCost) * 100;
  }

  // Helper method to get total profit
  double get totalProfit {
    return profitMargin * soldQuantity;
  }
}
