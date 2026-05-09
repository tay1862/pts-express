import 'package:flutter/material.dart';

ThemeData buildPtsTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xff1f7a4f),
    brightness: Brightness.light,
  );
  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xfffbf8ed),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: Color(0xfffbf8ed),
      foregroundColor: Color(0xff123f2c),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: const Color(0xfffffdf6),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xfffffdf6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    ),
  );
}
