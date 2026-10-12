import 'package:flutter/material.dart';
import 'app_colors.dart';

class SouqnaTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: SouqnaColors.surface,
      primaryColor: SouqnaColors.primary,
      colorScheme: const ColorScheme.light(
        primary: SouqnaColors.primary,
        secondary: SouqnaColors.accent,
        surface: SouqnaColors.surfaceContainer,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: SouqnaColors.primary),
        titleTextStyle: TextStyle(
          color: SouqnaColors.primary,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
