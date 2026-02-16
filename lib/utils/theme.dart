import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Light & Dark Palette
  static const Color primaryGreen = Color(0xFF4A7C59);
  static const Color secondaryGreen = Color(0xFF8AB092);
  static const Color lightGreen = Color(0xFFC8E6C9);

  static const Color lightBackground = Color(0xFFFAF3E0);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF2D3E30);
  static const Color lightTextSecondary = Color(0xFF6B7D70);

  static const Color darkBackground = Color(0xFF1A1F1C);
  static const Color darkSurface = Color(0xFF242C26);
  static const Color darkText = Color(0xFFE0E6E1);
  static const Color darkTextSecondary = Color(0xFFA5B5AB);

  static const Color accentGold = Color(0xFFD4AF37);
  static const Color errorRed = Color(0xFFE57373);
}

class AppTheme {
  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primaryGreen,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryGreen,
      secondary: AppColors.lightGreen,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
    ),
    fontFamily: GoogleFonts.outfit().fontFamily,
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.outfit(
        fontSize: 22, // Reduced further
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 18, // Reduced further
        fontWeight: FontWeight.w600,
        color: AppColors.lightText,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 13, // Reduced further
        color: AppColors.lightText,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 11, // Reduced further
        color: AppColors.lightTextSecondary,
      ),
    ),
    iconTheme: const IconThemeData(
      color: AppColors.primaryGreen,
      size: 18, // Reduced further
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.lightText, size: 18),
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 16, // Reduced further
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.lightGreen.withValues(alpha: 0.3)),
      ),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      iconColor: AppColors.primaryGreen,
      collapsedIconColor: AppColors.primaryGreen,
      textColor: AppColors.lightText,
      collapsedTextColor: AppColors.lightText,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: AppColors.primaryGreen,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryGreen,
      secondary: AppColors.secondaryGreen,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
    ),
    fontFamily: GoogleFonts.outfit().fontFamily,
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      ),
      bodyLarge: GoogleFonts.outfit(fontSize: 13, color: AppColors.darkText),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 11,
        color: AppColors.darkTextSecondary,
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.secondaryGreen, size: 18),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.darkText, size: 18),
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: AppColors.secondaryGreen.withValues(alpha: 0.1),
        ),
      ),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      iconColor: AppColors.secondaryGreen,
      collapsedIconColor: AppColors.secondaryGreen,
      textColor: AppColors.darkText,
      collapsedTextColor: AppColors.darkText,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: AppColors.darkTextSecondary,
    ),
  );
}
