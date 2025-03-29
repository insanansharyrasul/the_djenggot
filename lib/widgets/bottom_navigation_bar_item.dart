import 'package:flutter/material.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

Widget bottomNavItem(GestureTapCallback onTap, IconData icon, int pageIndex, int currentPageIndex,
        String itemName) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: const Alignment(0, 0.01),
            colors: [
              pageIndex == currentPageIndex ? AppTheme.nearlyBlue : AppTheme.background,
              AppTheme.background,
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
                  ? AppTheme.nearlyBlue
                  : pageIndex == 5
                      ? Colors.red
                      : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              itemName,
              style: TextStyle(
                  color: pageIndex == currentPageIndex
                      ? AppTheme.nearlyBlue
                      : pageIndex == 5
                          ? Colors.red
                          : Colors.grey,
                  fontSize: 12,
                  fontFamily: AppTheme.fontName),
            ),
          ],
        ),
      ),
    );
