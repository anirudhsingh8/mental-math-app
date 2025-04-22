import 'package:flutter/material.dart';

class AppTheme {
  // Color constants
  static const Color primaryColor = Color(0xFF4A55A2);
  static const Color secondaryColor = Color(0xFF7895CB);
  static const Color accentColor = Color(0xFFA0BFE0);
  static const Color backgroundColor = Color(0xFFEEF5FF);
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color textPrimaryColor = Color(0xFF2D3142);
  static const Color textSecondaryColor = Color(0xFF626677);

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: backgroundColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge:
          TextStyle(color: textPrimaryColor, fontWeight: FontWeight.bold),
      displayMedium:
          TextStyle(color: textPrimaryColor, fontWeight: FontWeight.bold),
      displaySmall:
          TextStyle(color: textPrimaryColor, fontWeight: FontWeight.bold),
      headlineMedium:
          TextStyle(color: textPrimaryColor, fontWeight: FontWeight.w600),
      headlineSmall:
          TextStyle(color: textPrimaryColor, fontWeight: FontWeight.w600),
      titleLarge:
          TextStyle(color: textPrimaryColor, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textPrimaryColor),
      bodyMedium: TextStyle(color: textPrimaryColor),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: Colors.grey[850]!,
    ),
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850],
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      ),
    ),
    textTheme: TextTheme(
      displayLarge:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      displayMedium:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      displaySmall:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      headlineMedium:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      headlineSmall:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      titleLarge:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: Colors.grey[200]),
      bodyMedium: TextStyle(color: Colors.grey[300]),
    ),
    cardTheme: CardTheme(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
    ),
  );
}
