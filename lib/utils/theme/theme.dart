import 'package:flutter/material.dart';

import 'colors.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    surface: AppColors.backgroundLight,
    onSurface: AppColors.textPrimaryLight,
    primary: AppColors.primaryLight,
    onPrimary: AppColors.backgroundLight,
    secondary: AppColors.textSecondaryLight,
    onSecondary: AppColors.backgroundLight,
    secondaryContainer: AppColors.cardSecondaryLight,
    tertiary: AppColors.success,
    error: AppColors.error,
  ),
  dividerColor: AppColors.textSecondaryLight,
  highlightColor: AppColors.bottomNavBarIconLight,
  cardColor: AppColors.cardPrimaryLight,
  canvasColor: AppColors.backgroundLight,
  hintColor: AppColors.textSecondaryLight,
  primaryColor: AppColors.primaryLight,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  splashColor: AppColors.primaryLight.withAlpha(26),
  appBarTheme: const AppBarTheme(backgroundColor: AppColors.backgroundLight, foregroundColor: AppColors.textPrimaryLight, elevation: 0),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.backgroundLight,
    selectedItemColor: AppColors.primaryLight,
    unselectedItemColor: AppColors.bottomNavBarIconLight,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    surface: AppColors.backgroundDark,
    onSurface: AppColors.textPrimaryDark,
    primary: AppColors.primaryDark,
    onPrimary: AppColors.backgroundDark,
    secondary: AppColors.textSecondaryDark,
    onSecondary: AppColors.backgroundDark,
    secondaryContainer: AppColors.cardSecondaryDark,
    tertiary: AppColors.success,
    error: AppColors.error,
  ),
  dividerColor: AppColors.textSecondaryDark,
  highlightColor: AppColors.bottomNavBarIconDark,
  cardColor: AppColors.cardPrimaryDark,
  canvasColor: AppColors.backgroundDark,
  hintColor: AppColors.textSecondaryDark,
  primaryColor: AppColors.primaryDark,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  splashColor: AppColors.primaryDark.withAlpha(26),
  appBarTheme: const AppBarTheme(backgroundColor: AppColors.backgroundDark, foregroundColor: AppColors.textPrimaryDark, elevation: 0),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.backgroundDark,
    selectedItemColor: AppColors.primaryDark,
    unselectedItemColor: AppColors.bottomNavBarIconDark,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
);
