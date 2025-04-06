import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: "id",
    symbol: "Rp. ",
    decimalDigits: 0,
  );

  static double getNumericalValue(String text) {
    String numericString = text.replaceAll('Rp.', '').replaceAll('.', '').trim();
    return double.tryParse(numericString) ?? 0.0;
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    if (newValue.text.isEmpty) {
      return newValue;
    }

    double value = double.parse(newValue.text.replaceAll(RegExp(r'[^0-9]'), ''));
    String newText = _formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
