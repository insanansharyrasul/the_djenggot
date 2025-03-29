import 'package:flutter/material.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

Widget floatingButton({
  required IconData icon,
  required VoidCallback onPressed,
}) {
  return FloatingActionButton(
    onPressed: onPressed,
    backgroundColor: AppTheme.nearlyBlue,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon),
  );
}
