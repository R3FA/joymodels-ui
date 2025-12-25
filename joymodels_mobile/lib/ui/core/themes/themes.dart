import 'package:flutter/material.dart';

abstract class ThemeManager {
  static Color seedColor = const Color(0xFF5603AD);

  static ThemeData generateLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontWeight: FontWeight.normal),
      ),
    );
  }

  static ThemeData generateDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontWeight: FontWeight.normal),
      ),
    );
  }
}
