import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme get textTheme {
    return TextTheme(
      // Display
      displayLarge: GoogleFonts.publicSans(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 44 / 34,
        color: AppColors.onBackground,
      ),
      // Headline Lg
      headlineLarge: GoogleFonts.publicSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 36 / 28,
        color: AppColors.onBackground,
      ),
      // Headline Md
      headlineMedium: GoogleFonts.publicSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: AppColors.onBackground,
      ),
      // Body Lg
      bodyLarge: GoogleFonts.publicSans(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        height: 30 / 20,
        color: AppColors.onBackground,
      ),
      // Body Md
      bodyMedium: GoogleFonts.publicSans(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: AppColors.onBackground,
      ),
      // Label Lg
      labelLarge: GoogleFonts.publicSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 24 / 18,
        color: AppColors.onBackground,
      ),
    );
  }
}