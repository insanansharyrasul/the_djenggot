import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static const Color primary = Color(0xFF00B6F0);
  static const Color secondary = Color(0xFFFF6F00);

  static const Color nearlyWhite = Color(0xFFFAFAFA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF2F3F8);
  static const Color nearlyDarkBlue = Color(0xFF2633C5);

  static const Color nearlyBlue = Color(0xFF00B6F0);
  static const Color nearlyBlack = Color(0xFF213333);
  static const Color grey = Color(0xFF3A5160);
  static const Color darkGrey = Color(0xFF313A44);

  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color spacer = Color(0xFFF2F2F2);
  static const String fontName = 'Lexend';

  static const Color danger = Color(0xFFEB5757);
  static const Color success = Color(0xFF27AE60);
  static const Color lightSuccess = Color(0xFF6FCF97);

  static const TextStyle display1 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static const TextStyle stockDetail = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.normal,
    fontSize: 12,
    letterSpacing: 0.18,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: darkText,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: lightText,
  );

  static const TextStyle appBarTitle = TextStyle(
    fontFamily: AppTheme.fontName,
    fontWeight: FontWeight.w500,
    fontSize: 18,
    letterSpacing: 0.5,
    color: Colors.black,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: AppTheme.fontName,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    letterSpacing: 0.5,
    color: AppTheme.nearlyWhite,
  );

  static const TextStyle textField = TextStyle(
    fontFamily: AppTheme.fontName,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    letterSpacing: 0.5,
    color: AppTheme.nearlyBlue,
  );

  static ButtonStyle buttonStyle = ButtonStyle(
    backgroundColor: const WidgetStatePropertyAll<Color>(AppTheme.white),
    shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  );

  static ButtonStyle buttonStyleSecond = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  static const TextStyle buttonTextBold = TextStyle(
    fontFamily: AppTheme.fontName,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    letterSpacing: 0.5,
    color: AppTheme.nearlyWhite,
  );
}
