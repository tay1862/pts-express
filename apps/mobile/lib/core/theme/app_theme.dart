import 'package:flutter/material.dart';

const _seedColor = Color(0xff1f7a4f);

ThemeData buildPtsTheme([Brightness brightness = Brightness.light]) {
  final isLight = brightness == Brightness.light;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: brightness,
  );
  final scaffoldBg = isLight ? const Color(0xfffbf8ed) : colorScheme.surface;
  final cardBg = isLight
      ? const Color(0xfffffdf6)
      : colorScheme.surfaceContainerHigh;
  final appBarFg = isLight ? const Color(0xff123f2c) : colorScheme.onSurface;

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffoldBg,
    useMaterial3: true,
    brightness: brightness,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: scaffoldBg,
      foregroundColor: appBarFg,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: cardBg,
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
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    ),
  );
}

ThemeData buildPtsLightTheme() => buildPtsTheme(Brightness.light);
ThemeData buildPtsDarkTheme() => buildPtsTheme(Brightness.dark);
