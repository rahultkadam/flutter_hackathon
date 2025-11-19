import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Colors
  static const Color primaryPurple = Color(0xFF996BFA);
  static const Color darkBackground = Color(0xFF1B1E34);
  static const Color secondaryGray = Color(0xFF575764);
  static const Color white = Color(0xFFFFFFFF);
  
  // Semantic Colors (keep for meaning)
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color profitGreen = Color(0xFF00C851);
}

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryPurple,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryPurple,
      brightness: Brightness.light,
      primary: AppColors.primaryPurple,
      surface: AppColors.white,
      background: AppColors.white,
      onPrimary: AppColors.white,
      onSurface: Colors.black87,
      outline: AppColors.secondaryGray.withOpacity(0.3),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.light().textTheme.copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.black87,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryPurple,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: AppColors.white,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryPurple,
        side: const BorderSide(color: AppColors.primaryPurple),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.secondaryGray.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.secondaryGray.withOpacity(0.3)),
      ),
      hintStyle: GoogleFonts.poppins(
        color: AppColors.secondaryGray,
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      color: AppColors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primaryPurple,
      unselectedItemColor: AppColors.secondaryGray,
      selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.poppins(),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryPurple,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryPurple,
      brightness: Brightness.dark,
      primary: AppColors.primaryPurple,
      surface: const Color(0xFF2A2D47),
      background: AppColors.darkBackground,
      onPrimary: AppColors.white,
      onSurface: AppColors.white,
      onBackground: AppColors.white,
      outline: AppColors.secondaryGray,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme.copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: AppColors.white,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.white,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: AppColors.white,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryPurple,
        side: const BorderSide(color: AppColors.primaryPurple),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.secondaryGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.secondaryGray),
      ),
      hintStyle: GoogleFonts.poppins(
        color: AppColors.secondaryGray,
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      color: Color(0xFF2A2D47),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF2A2D47),
      selectedItemColor: AppColors.primaryPurple,
      unselectedItemColor: AppColors.secondaryGray,
      selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.poppins(),
    ),
  );
}