import 'package:intl/intl.dart';

class CurrencyFormatterUtil {
  // Compact formatter for large values
  static final NumberFormat _compactFormatter = NumberFormat.compactCurrency(
    locale: 'id',
    symbol: 'Rp',
    decimalDigits: 1,
  );

  // Smart formatter that handles large values by using compact format
  static String formatCurrency(int amount) {
    if (amount >= 1000000000) {
      // Billions
      return 'Rp${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      // Millions
      return 'Rp${(amount / 1000000).toStringAsFixed(1)}JT';
    } else if (amount >= 1000) {
      // Thousands
      return 'Rp${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return _compactFormatter.format(amount);
    }
  }

  // Format method that allows specifying whether to use compact format for large values
  static String format(int amount, {bool useCompactForLargeValues = true}) {
    if (useCompactForLargeValues) {
      return formatCurrency(amount);
    } else {
      return _compactFormatter.format(amount);
    }
  }

  // Get the numerical value from a formatted string
  static int getNumericalValue(String text) {
    String numericString = text
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();

    // Handle abbreviated forms
    if (numericString.endsWith('B')) {
      numericString = numericString.substring(0, numericString.length - 1);
      return (double.parse(numericString) * 1000000000).round();
    } else if (numericString.endsWith('M')) {
      numericString = numericString.substring(0, numericString.length - 1);
      return (double.parse(numericString) * 1000000).round();
    } else if (numericString.endsWith('K')) {
      numericString = numericString.substring(0, numericString.length - 1);
      return (double.parse(numericString) * 1000).round();
    }

    return int.parse(numericString);
  }
}
