import 'package:intl/intl.dart';

/// Global utility function to format prices with commas after every 3 digits
/// This function will be used throughout the app to ensure consistent price formatting
String formatPrice(double price) {
  // Remove any decimal places and convert to integer
  final intPrice = price.toInt();
  
  // Format with commas using NumberFormat
  final formatter = NumberFormat('#,###', 'en_US');
  return formatter.format(intPrice);
}

/// Format price with currency symbol
String formatPriceWithCurrency(double price, {String currency = 'د.ع'}) {
  return '${formatPrice(price)} $currency';
}

/// Format price with decimal places (if needed)
String formatPriceWithDecimals(double price, {int decimalPlaces = 0}) {
  if (decimalPlaces == 0) {
    return formatPrice(price);
  }
  
  final intPrice = price.toInt();
  final decimalPart = price - intPrice;
  
  if (decimalPart == 0) {
    return formatPrice(price);
  }
  
  final formatter = NumberFormat('#,###.${'#' * decimalPlaces}', 'en_US');
  return formatter.format(price);
}
