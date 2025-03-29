import 'package:flutter/material.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

Widget bottomNavItem(
  GestureTapCallback onTap,
  IconData icon,
  int pageIndex,
  int currentPageIndex,
  String itemName
) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: const Alignment(0, 0.1),
            colors: [
              pageIndex == currentPageIndex
                  ? DjenggotAppTheme.nearlyBlue
                  : DjenggotAppTheme.background,
              DjenggotAppTheme.background,
            ],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            SizedBox(height: 8),
            Icon(
              icon,
              color: pageIndex == currentPageIndex
                  ? DjenggotAppTheme.nearlyBlue
                  : pageIndex == 5
                      ? Colors.red
                      : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              itemName,
              style: TextStyle(
                color: pageIndex == currentPageIndex
                    ? DjenggotAppTheme.nearlyBlue
                    : pageIndex == 5
                        ? Colors.red
                        : Colors.grey,
                fontSize: 12,
                fontFamily: DjenggotAppTheme.fontName
              ),
            ),
          ],
        ),
      ),
    );
