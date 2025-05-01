import 'package:flutter/material.dart';
import 'package:the_djenggot/utils/theme/text_style.dart';

InputDecoration dropdownCategoryDecoration({
  IconData? prefixIcon,
  EdgeInsetsGeometry? contentPadding,
}) {
  return InputDecoration(
    prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: Colors.grey.shade800,
      ),
    ),
    fillColor: Colors.white,
    contentPadding: contentPadding ??
        const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: Colors.grey.shade400,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Colors.red,
      ),
    ),
    errorStyle: createRedThinTextStyle(12),
  );
}
