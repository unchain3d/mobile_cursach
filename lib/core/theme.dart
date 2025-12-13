import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1E1E1E);
  static const primary = Color(0xFFB9F232);
  static const text = Colors.white;
  static const textSecondary = Colors.grey;

  static const inputFill = Colors.transparent;
  static const inputBorder = Color(0xFF333333);
  static const buttonText = Colors.black;
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Poppins',

  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    surface: AppColors.surface,
  ),

  textTheme: const TextTheme(
    bodyMedium: TextStyle(
      color: AppColors.text,
      fontSize: 16,
    ),
    bodyLarge: TextStyle(
      color: AppColors.text,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: TextStyle(
      color: AppColors.textSecondary,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.buttonText,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 0,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        fontFamily: 'Poppins',
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.inputFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    hintStyle: TextStyle(
      color: AppColors.text.withValues(alpha: 0.5),
      fontSize: 14,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(
        color: AppColors.inputBorder,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 1.5,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.background,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: Colors.grey,
    showSelectedLabels: false,
    showUnselectedLabels: false,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.text,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      fontFamily: 'Poppins',
    ),
  ),
);
