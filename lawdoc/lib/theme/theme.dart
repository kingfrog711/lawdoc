import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: const ColorScheme.light(
        primary: AppColors.burgundy,
        secondary: AppColors.mauve,
        surface: AppColors.white,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navy),
        titleTextStyle: const TextStyle(
          fontFamily: 'SFUIDisplay',
          color: AppColors.navy,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.burgundy, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'SFUIDisplay',
          color: AppColors.textMuted,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'SFUIDisplay',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.divider.withAlpha(180)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.white,
        selectedColor: AppColors.mauve,
        labelStyle: const TextStyle(
          fontFamily: 'SFUIDisplay',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.inputBorder),
        ),
      ),
    );
  }

  static TextTheme get _textTheme {
    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'AppleGaramond',
        fontSize: 48, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.1,
      ),
      displayMedium: TextStyle(
        fontFamily: 'AppleGaramond',
        fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.15,
      ),
      displaySmall: TextStyle(
        fontFamily: 'AppleGaramond',
        fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'AppleGaramond',
        fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'SFUIDisplay',
        fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'SFUIDisplay',
        fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontFamily: 'SFUIDisplay',
        fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: 'SFUIDisplay',
        fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary,
      ),
      titleSmall: TextStyle(
        fontFamily: 'SFUIDisplay',
        fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'SFUIDisplay',
        fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'SFUIDisplay',
        fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: 'SFUIDisplay',
        fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.5,
      ),
      labelLarge: TextStyle(
        fontFamily: 'SFUIDisplay',
        fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.2,
      ),
      labelSmall: TextStyle(
        fontFamily: 'SFUIDisplay',
        fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.8,
      ),
    );
  }
}
