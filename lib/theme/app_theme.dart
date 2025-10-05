import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      background: AppColors.background,
      surface: AppColors.surface,
      error: AppColors.error,
      brightness: Brightness.light,
    ),

    scaffoldBackgroundColor: AppColors.background,

    fontFamily: GoogleFonts.poppins().fontFamily,
    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1,
      headlineMedium: AppTextStyles.h2,
      bodyMedium: AppTextStyles.body,
      labelLarge: AppTextStyles.button,
      bodySmall: AppTextStyles.caption,
    ).apply(bodyColor: AppColors.text, displayColor: AppColors.text),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.h2,
      iconTheme: const IconThemeData(color: AppColors.text),
      actionsIconTheme: const IconThemeData(color: AppColors.text),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: AppTextStyles.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: AppColors.border, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: AppColors.border, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
      ),
    ),
  );
}
