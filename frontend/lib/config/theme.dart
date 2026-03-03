import 'package:flutter/material.dart';

class NatureTheme {
  NatureTheme._();

  // Brand colors
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color secondaryYellow = Color(0xFFFFB300);
  static const Color backgroundCream = Color(0xFFFAFAF5);
  static const Color surfaceWhite = Colors.white;
  static const Color errorRed = Color(0xFFE53935);
  static const Color textDarkBrown = Color(0xFF3E2723);

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryGreen,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFC8E6C9),
      onPrimaryContainer: Color(0xFF1B5E20),
      secondary: secondaryYellow,
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFFFFECB3),
      onSecondaryContainer: Color(0xFF6D4C00),
      tertiary: Color(0xFF00897B),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFB2DFDB),
      onTertiaryContainer: Color(0xFF004D40),
      error: errorRed,
      onError: Colors.white,
      errorContainer: Color(0xFFFFCDD2),
      onErrorContainer: Color(0xFFB71C1C),
      surface: surfaceWhite,
      onSurface: textDarkBrown,
      surfaceContainerHighest: Color(0xFFF5F5F0),
      onSurfaceVariant: Color(0xFF5D4037),
      outline: Color(0xFFBCAAA4),
      outlineVariant: Color(0xFFD7CCC8),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF3E2723),
      onInverseSurface: Color(0xFFFAFAF5),
      inversePrimary: Color(0xFFA5D6A7),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundCream,

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: backgroundCream,
        foregroundColor: textDarkBrown,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: textDarkBrown,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        color: surfaceWhite,
        surfaceTintColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceWhite,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Color(0xFF9E9E9E),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        surfaceTintColor: Colors.transparent,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEE8E0),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
