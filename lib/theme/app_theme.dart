import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFE9684B);

  static const Color accent = Color(0xFFF4A261);

  static const Color lightBackground = Color(0xFFFFFAF7);

  static const Color darkBackground = Color(0xFF12100F);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFFFDDD5),
      onPrimaryContainer: Color(0xFF3A1109),
      secondary: accent,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFFE8D4),
      onSecondaryContainer: Color(0xFF43210C),
      surface: Color(0xFFFFFEFC),
      onSurface: Color(0xFF211A17),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Color(0xFFFFFBF8),
      surfaceContainer: Color(0xFFF9F1EC),
      surfaceContainerHigh: Color(0xFFF2E8E2),
      surfaceContainerHighest: Color(0xFFE9DDD6),
      onSurfaceVariant: Color(0xFF766B65),
      outline: Color(0xFFD3C7BF),
      outlineVariant: Color(0xFFE6DDD7),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF211A17),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Color(0xFFFFFEFC),
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFFFFEFC),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      hintStyle: TextStyle(
        color: Color(0xFF837771),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: Color(0xFFE6DDD7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: primary, width: 1.4),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: Color(0xFFF2E9E3),
      selectedColor: primary,
      labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      side: BorderSide.none,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE6DDD7),
      thickness: 1,
      space: 1,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF8A65),
      onPrimary: Color(0xFF35120A),
      primaryContainer: Color(0xFF6F2D20),
      onPrimaryContainer: Color(0xFFFFDCD3),
      secondary: Color(0xFFFFB86B),
      onSecondary: Color(0xFF3E210A),
      secondaryContainer: Color(0xFF5F3C16),
      onSecondaryContainer: Color(0xFFFFDDB8),
      surface: Color(0xFF191514),
      onSurface: Color(0xFFF5ECE8),
      surfaceContainerLowest: Color(0xFF0F0C0B),
      surfaceContainerLow: Color(0xFF151110),
      surfaceContainer: Color(0xFF1D1715),
      surfaceContainerHigh: Color(0xFF261E1B),
      surfaceContainerHighest: Color(0xFF302521),
      onSurfaceVariant: Color(0xFFC9BCB5),
      outline: Color(0xFF6B5E57),
      outlineVariant: Color(0xFF473B35),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFF5ECE8),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Color(0xFF191514),
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF1D1715),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      hintStyle: TextStyle(
        color: Color(0xFF998B84),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: Color(0xFF473B35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: Color(0xFFFF8A65), width: 1.4),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFF8A65),
        foregroundColor: Color(0xFF35120A),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Color(0xFFFF8A65),
        foregroundColor: Color(0xFF35120A),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: Color(0xFF261E1B),
      selectedColor: Color(0xFFFF8A65),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFFF5ECE8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      side: BorderSide.none,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF473B35),
      thickness: 1,
      space: 1,
    ),
  );
}
