import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const primary = Color(0xFF1E293B);
  const background = Color(0xFFF8FAFC);
  const onBackground = Color(0xFF0F172A);
  const surface = Color(0xFFFFFFFF);

  final scheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFF334155),
    secondary: const Color(0xFFD97706),
    onSecondary: Colors.white,
    tertiary: const Color(0xFF0D9488),
    onTertiary: Colors.white,
    surface: surface,
    onSurface: const Color(0xFF1E293B),
    error: const Color(0xFFE11D48),
  );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    useMaterial3: true,
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: onBackground,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: onBackground,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: onBackground,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.all(16),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 1,
      shadowColor: const Color(0x0A0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
