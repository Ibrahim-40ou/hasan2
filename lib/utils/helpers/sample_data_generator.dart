// import 'dart:math';
//
// import 'package:get/get.dart';
// import 'package:hasan2/controllers/statistics_controller.dart';
// import 'package:hasan2/models/transaction_model.dart';
//
// /// Sample data generator for testing the statistics feature
// /// This class generates realistic transaction data for demonstration purposes
// class SampleDataGenerator {
//   static final Random _random = Random();
//
//   // Sample product data
//   static final List<Map<String, dynamic>> _sampleProducts = [
//     {'id': 'prod_1', 'name': 'لابتوب Dell XPS', 'brandId': 'brand_1', 'price': 150000.0, 'cost': 120000.0},
//     {'id': 'prod_2', 'name': 'هاتف iPhone 15', 'brandId': 'brand_2', 'price': 180000.0, 'cost': 140000.0},
//     {'id': 'prod_3', 'name': 'سماعات AirPods', 'brandId': 'brand_2', 'price': 45000.0, 'cost': 35000.0},
//     {'id': 'prod_4', 'name': 'كاميرا Canon EOS', 'brandId': 'brand_3', 'price': 95000.0, 'cost': 75000.0},
//     {'id': 'prod_5', 'name': 'شاشة Samsung 27"', 'brandId': 'brand_4', 'price': 65000.0, 'cost': 50000.0},
//     {'id': 'prod_6', 'name': 'لوحة مفاتيح ميكانيكية', 'brandId': 'brand_5', 'price': 12000.0, 'cost': 8000.0},
//     {'id': 'prod_7', 'name': 'ماوس لاسلكي', 'brandId': 'brand_5', 'price': 8000.0, 'cost': 5000.0},
//     {'id': 'prod_8', 'name': 'قرص صلب خارجي 1TB', 'brandId': 'brand_6', 'price': 25000.0, 'cost': 18000.0},
//     {'id': 'prod_9', 'name': 'طابعة HP LaserJet', 'brandId': 'brand_7', 'price': 55000.0, 'cost': 42000.0},
//     {'id': 'prod_10', 'name': 'راوتر WiFi 6', 'brandId': 'brand_8', 'price': 18000.0, 'cost': 13000.0},
//   ];
//
//   /// Generate sample transactions for the last specified number of days
//   /// [daysBack] - Number of days to generate data for (default: 90 days)
//   /// [transactionsPerDay] - Average number of transactions per day (default: 5-15)
//   static Future<void> generateSampleData({int daysBack = 90, int minTransactionsPerDay = 3, int maxTransactionsPerDay = 12}) async {
//     try {
//       final statisticsController = Get.find<StatisticsController>();
//       final now = DateTime.now();
//
//       print('🔄 Generating sample data for the last $daysBack days...');
//
//       for (int dayOffset = 0; dayOffset < daysBack; dayOffset++) {
//         final currentDate = now.subtract(Duration(days: dayOffset));
//         final transactionsForDay = minTransactionsPerDay + _random.nextInt(maxTransactionsPerDay - minTransactionsPerDay + 1);
//
//         for (int i = 0; i < transactionsForDay; i++) {
//           final product = _sampleProducts[_random.nextInt(_sampleProducts.length)];
//           final soldQuantity = _generateRealisticQuantity();
//           final saleAmount = product['price'] * soldQuantity;
//           final profitMargin = product['price'] - product['cost'];
//
//           // Add some randomness to the time within the day
//           final randomHour = _random.nextInt(12) + 8; // Business hours: 8 AM to 8 PM
//           final randomMinute = _random.nextInt(60);
//           final transactionTime = DateTime(currentDate.year, currentDate.month, currentDate.day, randomHour, randomMinute);
//
//           final transaction = TransactionModel(
//             productId: product['id'],
//             productName: product['name'],
//             brandId: product['brandId'],
//             saleAmount: saleAmount,
//             profitMargin: profitMargin,
//             soldQuantity: soldQuantity,
//             unitPrice: product['price'],
//             unitCost: product['cost'],
//             timestamp: transactionTime,
//             createdAt: transactionTime,
//           );
//
//           // Add transaction to statistics (with error handling)
//           await statisticsController.addTransaction(transaction).catchError((error) {
//             print('❌ Error adding sample transaction: $error');
//           });
//         }
//
//         // Show progress every 10 days
//         if ((dayOffset + 1) % 10 == 0) {
//           print('✅ Generated data for ${dayOffset + 1}/$daysBack days');
//         }
//       }
//
//       print('🎉 Sample data generation completed successfully!');
//       print('📊 Generated approximately ${daysBack * ((minTransactionsPerDay + maxTransactionsPerDay) / 2).round()} transactions');
//     } catch (e) {
//       print('❌ Error generating sample data: $e');
//       rethrow;
//     }
//   }
//
//   /// Generate realistic quantity based on product type and price
//   static double _generateRealisticQuantity() {
//     // Most sales are 1-3 items, with occasional bulk sales
//     final randomValue = _random.nextDouble();
//
//     if (randomValue < 0.7) {
//       // 70% chance: 1 item
//       return 1.0;
//     } else if (randomValue < 0.9) {
//       // 20% chance: 2-3 items
//       return (_random.nextInt(2) + 2).toDouble();
//     } else {
//       // 10% chance: bulk sale (4-10 items)
//       return (_random.nextInt(7) + 4).toDouble();
//     }
//   }
//
//   /// Generate sample data for specific time periods for testing
//   static Future<void> generateTestDataForPeriods() async {
//     try {
//       final now = DateTime.now();
//
//       print('🔄 Generating test data for different time periods...');
//
//       // Generate data for today (high activity)
//       await _generateDataForDate(now, 8, 15);
//
//       // Generate data for yesterday
//       await _generateDataForDate(now.subtract(const Duration(days: 1)), 5, 12);
//
//       // Generate data for last week (varied activity)
//       for (int i = 2; i <= 7; i++) {
//         await _generateDataForDate(now.subtract(Duration(days: i)), 3, 10);
//       }
//
//       // Generate data for last month (consistent activity)
//       for (int i = 8; i <= 30; i++) {
//         await _generateDataForDate(now.subtract(Duration(days: i)), 2, 8);
//       }
//
//       print('🎉 Test data generation completed!');
//     } catch (e) {
//       print('❌ Error generating test data: $e');
//       rethrow;
//     }
//   }
//
//   static Future<void> _generateDataForDate(DateTime date, int minTransactions, int maxTransactions) async {
//     final statisticsController = Get.find<StatisticsController>();
//     final transactionCount = minTransactions + _random.nextInt(maxTransactions - minTransactions + 1);
//
//     for (int i = 0; i < transactionCount; i++) {
//       final product = _sampleProducts[_random.nextInt(_sampleProducts.length)];
//       final soldQuantity = _generateRealisticQuantity();
//       final saleAmount = product['price'] * soldQuantity;
//       final profitMargin = product['price'] - product['cost'];
//
//       final randomHour = _random.nextInt(12) + 8;
//       final randomMinute = _random.nextInt(60);
//       final transactionTime = DateTime(date.year, date.month, date.day, randomHour, randomMinute);
//
//       final transaction = TransactionModel(
//         productId: product['id'],
//         productName: product['name'],
//         brandId: product['brandId'],
//         saleAmount: saleAmount,
//         profitMargin: profitMargin,
//         soldQuantity: soldQuantity,
//         unitPrice: product['price'],
//         unitCost: product['cost'],
//         timestamp: transactionTime,
//         createdAt: transactionTime,
//       );
//
//       await statisticsController.addTransaction(transaction).catchError((error) {
//         print('❌ Error adding transaction for ${date.toLocal()}: $error');
//       });
//     }
//   }
//
//   /// Clear all sample data (useful for testing)
//   static Future<void> clearSampleData() async {
//     try {
//       final statisticsController = Get.find<StatisticsController>();
//
//       print('🔄 Clearing sample data...');
//
//       // Reset the controller's data
//       statisticsController.transactions.clear();
//       statisticsController.salesVolumeData.clear();
//       statisticsController.profitData.clear();
//       statisticsController.totalSales = 0.0;
//       statisticsController.totalProfit = 0.0;
//       statisticsController.totalTransactions = 0;
//       statisticsController.averageOrderValue = 0.0;
//       statisticsController.update();
//
//       print('✅ Sample data cleared successfully!');
//     } catch (e) {
//       print('❌ Error clearing sample data: $e');
//       rethrow;
//     }
//   }
// }
