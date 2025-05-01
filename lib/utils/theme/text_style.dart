import 'package:flutter/material.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

TextStyle createPrimaryTextStyle(double fontSize) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: FontWeight.normal,
    fontFamily: 'Lexend',
    color: AppTheme.darkGrey,
  );
}

TextStyle createBlackTextStyle(double fontSize) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: FontWeight.normal,
    fontFamily: 'Lexend',
    color: Colors.black,
  );
}

TextStyle createBlackThinTextStyle(double fontSize) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: FontWeight.w300,
    fontFamily: 'Lexend',
    color: Colors.black,
  );
}

TextStyle createGreyThinTextStyle(double fontSize) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: FontWeight.w300,
    fontFamily: 'Lexend',
    color: Colors.grey,
  );
}

TextStyle createRedThinTextStyle(double fontSize) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: FontWeight.w300,
    fontFamily: 'Lexend',
    color: Colors.red,
  );
}
