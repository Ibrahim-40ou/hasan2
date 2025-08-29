import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:hasan2/models/transaction_model.dart';
import 'package:hasan2/utils/helpers/firebase_consumer.dart';
import 'package:hasan2/utils/helpers/price_formatter.dart';
import 'package:intl/intl.dart';

import '../utils/error.dart';

enum TimePeriod { daily, weekly, monthly, yearly }

class StatisticsController extends GetxController {
  final FirebaseConsumer _firebaseConsumer = FirebaseConsumer();

  // State variables
  List<TransactionModel> transactions = [];
  TimePeriod selectedTimePeriod = TimePeriod.daily;

  // Custom date selection
  DateTime? customStartDate;
  DateTime? customEndDate;
  bool isCustomDateSelected = false;

  // Loading and error states
  bool isLoading = false;
  bool isError = false;
  bool isTransactionsLoading = false;
  bool isTransactionsError = false;

  // Chart data with labels
  List<FlSpot> salesVolumeData = [];
  List<FlSpot> profitData = [];
  List<String> chartLabels = []; // Added for X-axis labels
  Map<String, List<TransactionModel>> groupedTransactions = {}; // Store grouped data

  // Summary statistics
  double totalSales = 0.0;
  double totalProfit = 0.0;
  int totalTransactions = 0;
  double averageOrderValue = 0.0;

  Future<void> fetchTransactions() async {
    try {
      isTransactionsLoading = true;
      isTransactionsError = false;
      update();

      final result = await _firebaseConsumer.getCollection(
        path: "transactions",
        queryBuilder: (query) => query.where("deleted_at", isNull: true).orderBy("timestamp", descending: true),
        limit: 100, // Increased limit to get more data for better charts
      );

      if (result.isSuccess && result.data != null) {
        transactions = result.data!
            .map((data) {
          try {
            return TransactionModel.fromJson(data);
          } catch (e) {
            log('Error parsing transaction: $e');
            return null;
          }
        })
            .where((transaction) => transaction != null)
            .cast<TransactionModel>()
            .toList();

        // Debug: Log transaction date ranges
        if (transactions.isNotEmpty) {
          final sortedTransactions = List<TransactionModel>.from(transactions)..sort((a, b) => a.timestamp.compareTo(b.timestamp));
          log('Available transactions: ${transactions.length} from ${sortedTransactions.first.timestamp} to ${sortedTransactions.last.timestamp}');
        }

        _calculateSummaryStats();
        _generateChartData();
        isTransactionsError = false;
      } else {
        log("Error fetching transactions: ${result.error}");
        isTransactionsError = true;
        transactions.clear();
        _resetStats();
      }
    } catch (e) {
      log('Exception while fetching transactions: $e');
      isTransactionsError = true;
      transactions.clear();
      _resetStats();
    } finally {
      isTransactionsLoading = false;
      update();
    }
  }

  void _resetStats() {
    totalSales = 0.0;
    totalProfit = 0.0;
    totalTransactions = 0;
    averageOrderValue = 0.0;
    salesVolumeData.clear();
    profitData.clear();
    chartLabels.clear();
    groupedTransactions.clear();
  }

  void _calculateSummaryStats() {
    if (transactions.isEmpty) {
      _resetStats();
      return;
    }

    // Filter transactions based on selected time period or custom date
    final filteredTransactions = _getFilteredTransactions();

    if (filteredTransactions.isEmpty) {
      _resetStats();
      return;
    }

    totalSales = filteredTransactions.fold(0.0, (sum, t) => sum + t.saleAmount);
    totalProfit = filteredTransactions.fold(0.0, (sum, t) => sum + t.totalProfit);
    totalTransactions = filteredTransactions.length;
    averageOrderValue = totalTransactions > 0 ? totalSales / totalTransactions : 0.0;

    log('Summary stats for ${selectedTimePeriod.name}: Sales: $totalSales, Profit: $totalProfit, Transactions: $totalTransactions');
  }

  // Set custom date range
  void setCustomDateRange(DateTime startDate, DateTime endDate) {
    customStartDate = startDate;
    customEndDate = endDate;
    isCustomDateSelected = true;
    _calculateSummaryStats();
    _generateChartData();
    update();
  }

  // Clear custom date selection
  void clearCustomDateSelection() {
    customStartDate = null;
    customEndDate = null;
    isCustomDateSelected = false;
    _calculateSummaryStats();
    _generateChartData();
    update();
  }

  Future<bool> addTransaction(TransactionModel transaction) async {
    try {
      final result = await _firebaseConsumer.addDocument(collectionPath: "transactions", data: transaction.toJson());

      if (result.isSuccess) {
        transactions.insert(0, transaction);
        _calculateSummaryStats();
        _generateChartData();
        update();
        return true;
      } else {
        log("Error adding transaction: ${result.error}");
        showError("حدث خطأ أثناء حفظ المعاملة");
        return false;
      }
    } catch (e) {
      log("Exception while adding transaction: $e");
      showError("حدث خطأ غير متوقع أثناء حفظ المعاملة");
      return false;
    }
  }

  void setTimePeriod(TimePeriod period) {
    selectedTimePeriod = period;
    // Clear custom date selection when changing time period
    if (isCustomDateSelected) {
      clearCustomDateSelection();
    }
    _calculateSummaryStats();
    _generateChartData();
    update();
  }

  void _generateChartData() {
    try {
      salesVolumeData.clear();
      profitData.clear();
      chartLabels.clear();
      groupedTransactions.clear();

      final filteredTransactions = _getFilteredTransactions();
      if (filteredTransactions.isEmpty) return;

      groupedTransactions = _groupTransactionsByPeriod(filteredTransactions);
      if (groupedTransactions.isEmpty) return;

      final sortedKeys = groupedTransactions.keys.toList()..sort();

      // Limit to reasonable number of data points for better visualization
      final maxDataPoints = _getMaxDataPointsForPeriod();
      final keysToProcess = sortedKeys.length > maxDataPoints ? sortedKeys.sublist(sortedKeys.length - maxDataPoints) : sortedKeys;

      for (int i = 0; i < keysToProcess.length; i++) {
        final key = keysToProcess[i];
        final periodTransactions = groupedTransactions[key];
        if (periodTransactions == null || periodTransactions.isEmpty) continue;

        final totalSales = periodTransactions.fold(0.0, (sum, t) => sum + t.saleAmount);
        final totalProfit = periodTransactions.fold(0.0, (sum, t) => sum + t.totalProfit);

        if (totalSales.isFinite && totalProfit.isFinite && totalSales >= 0 && totalProfit >= 0) {
          salesVolumeData.add(FlSpot(i.toDouble(), totalSales));
          profitData.add(FlSpot(i.toDouble(), totalProfit));
          chartLabels.add(_formatChartLabel(key));
        }
      }

      log('Generated ${salesVolumeData.length} chart data points for ${selectedTimePeriod.name}');
    } catch (e) {
      log('Error generating chart data: $e');
      salesVolumeData.clear();
      profitData.clear();
      chartLabels.clear();
      groupedTransactions.clear();
    }
  }

  int _getMaxDataPointsForPeriod() {
    switch (selectedTimePeriod) {
      case TimePeriod.daily:
        return 30; // Last 30 days
      case TimePeriod.weekly:
        return 12; // Last 12 weeks
      case TimePeriod.monthly:
        return 12; // Last 12 months
      case TimePeriod.yearly:
        return 5; // Last 5 years
    }
  }

  String _formatChartLabel(String key) {
    try {
      switch (selectedTimePeriod) {
        case TimePeriod.daily:
          final date = DateTime.parse(key);
          return DateFormat('M/d').format(date);

        case TimePeriod.weekly:
          if (key.contains('-W')) {
            final parts = key.split('-W');
            return 'أ${parts[1]}';
          }
          return key;

        case TimePeriod.monthly:
          final date = DateTime.parse('$key-01');
          return DateFormat('MMM').format(date);

        case TimePeriod.yearly:
          return key;
      }
    } catch (e) {
      log('Error formatting chart label for key: $key, error: $e');
      return key;
    }
  }

  List<TransactionModel> _getFilteredTransactions() {
    if (isCustomDateSelected && customStartDate != null && customEndDate != null) {
      // Use custom date range
      final customFiltered = transactions.where((t) =>
      t.timestamp.isAfter(customStartDate!.subtract(const Duration(days: 1))) &&
          t.timestamp.isBefore(customEndDate!.add(const Duration(days: 1)))
      ).toList();
      log('Custom date filter: ${customFiltered.length} transactions from ${customFiltered.isNotEmpty ? customFiltered.first.timestamp : 'none'} to ${customFiltered.isNotEmpty ? customFiltered.last.timestamp : 'none'}');
      return customFiltered;
    }

    // Use predefined time periods with proper filtering
    final now = DateTime.now();
    final startDate = switch (selectedTimePeriod) {
      TimePeriod.daily => now.subtract(const Duration(days: 30)),
      TimePeriod.weekly => now.subtract(const Duration(days: 84)), // 12 weeks
      TimePeriod.monthly => DateTime(now.year - 1, now.month, now.day),
      TimePeriod.yearly => DateTime(now.year - 5, now.month, now.day),
    };

    log('Filtering for ${selectedTimePeriod.name}: from $startDate to $now');

    // Filter transactions based on the selected time period with more specific logic
    final filtered = transactions.where((t) {
      switch (selectedTimePeriod) {
        case TimePeriod.daily:
        // Last 30 days - more specific range
          final thirtyDaysAgo = now.subtract(const Duration(days: 30));
          return t.timestamp.isAfter(thirtyDaysAgo) && t.timestamp.isBefore(now.add(const Duration(days: 1)));
        case TimePeriod.weekly:
        // Last 12 weeks - more specific range
          final twelveWeeksAgo = now.subtract(const Duration(days: 84));
          return t.timestamp.isAfter(twelveWeeksAgo) && t.timestamp.isBefore(now.add(const Duration(days: 1)));
        case TimePeriod.monthly:
        // Last 12 months - more specific range
          final twelveMonthsAgo = DateTime(now.year - 1, now.month, now.day);
          return t.timestamp.isAfter(twelveMonthsAgo) && t.timestamp.isBefore(now.add(const Duration(days: 1)));
        case TimePeriod.yearly:
        // Last 5 years - more specific range
          final fiveYearsAgo = DateTime(now.year - 5, now.month, now.day);
          return t.timestamp.isAfter(fiveYearsAgo) && t.timestamp.isBefore(now.add(const Duration(days: 1)));
      }
    }).toList();

    log('${selectedTimePeriod.name} filter: ${filtered.length} transactions from ${filtered.isNotEmpty ? filtered.first.timestamp : 'none'} to ${filtered.isNotEmpty ? filtered.last.timestamp : 'none'}');
    return filtered;
  }

  Map<String, List<TransactionModel>> _groupTransactionsByPeriod(List<TransactionModel> transactions) {
    final Map<String, List<TransactionModel>> grouped = {};

    for (final transaction in transactions) {
      final key = switch (selectedTimePeriod) {
        TimePeriod.daily =>
        '${transaction.timestamp.year}-${transaction.timestamp.month.toString().padLeft(2, '0')}-${transaction.timestamp.day.toString().padLeft(2, '0')}',

        TimePeriod.weekly => () {
          final weekStart = _getStartOfWeek(transaction.timestamp);
          return '${weekStart.year}-W${_getWeekOfYear(weekStart)}';
        }(),

        TimePeriod.monthly => '${transaction.timestamp.year}-${transaction.timestamp.month.toString().padLeft(2, '0')}',

        TimePeriod.yearly => transaction.timestamp.year.toString(),
      };

      grouped.putIfAbsent(key, () => []).add(transaction);
    }

    return grouped;
  }

  DateTime _getStartOfWeek(DateTime date) {
    // Get Monday as start of week
    return date.subtract(Duration(days: date.weekday - 1));
  }

  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final firstMondayOfYear = firstDayOfYear.add(Duration(days: (8 - firstDayOfYear.weekday) % 7));

    if (date.isBefore(firstMondayOfYear)) {
      return 1;
    }

    final weeksDifference = date.difference(firstMondayOfYear).inDays ~/ 7;
    return weeksDifference + 1;
  }

  String getTimePeriodName(TimePeriod period) {
    return switch (period) {
      TimePeriod.daily => 'يومي',
      TimePeriod.weekly => 'أسبوعي',
      TimePeriod.monthly => 'شهري',
      TimePeriod.yearly => 'سنوي',
    };
  }

  String getChartAxisInfo() {
    if (isCustomDateSelected && customStartDate != null && customEndDate != null) {
      final startFormatted = DateFormat('yyyy/MM/dd').format(customStartDate!);
      final endFormatted = DateFormat('yyyy/MM/dd').format(customEndDate!);
      return 'نتائج الإحصائية من $startFormatted إلى $endFormatted';
    }

    switch (selectedTimePeriod) {
      case TimePeriod.daily:
        return 'نتائج الإحصائية لآخر ٣٠ يومًا';
      case TimePeriod.weekly:
        return 'نتائج الإحصائية لآخر ١٢ أسبوعًا';
      case TimePeriod.monthly:
        return 'نتائج الإحصائية لآخر ١٢ شهرًا';
      case TimePeriod.yearly:
        return 'نتائج الإحصائية لآخر ٥ سنوات';
    }
  }

  // Updated price formatting methods using the global formatter
  String getFormattedSales() => formatPriceWithCurrency(totalSales);
  String getFormattedProfit() => formatPriceWithCurrency(totalProfit);
  String getFormattedTransactions() => totalTransactions.toString();
  String getFormattedAverageOrderValue() => formatPriceWithCurrency(averageOrderValue);
}
