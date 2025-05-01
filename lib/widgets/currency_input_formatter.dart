import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: "id",
    symbol: "Rp. ",
    decimalDigits: 0,
  );

  static int getNumericalValue(String text) {
    String numericString =
        text.replaceAll('Rp.', '').replaceAll('.', '').trim();
    return int.parse(numericString);
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    if (newValue.text.isEmpty) {
      return newValue;
    }

    int value = int.parse(newValue.text.replaceAll(RegExp(r'[^0-9]'), ''));
    String newText = _formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
