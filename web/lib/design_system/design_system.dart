import 'package:flutter/material.dart';

class AppColors {
  // Theme Neutrals
  static const Color background = Color(0xFF1E0F13);
  static const Color surface = Color(0xFF1E0F13);
  static const Color surfaceDim = Color(0xFF1E0F13);
  static const Color surfaceBright = Color(0xFF473439);
  
  static const Color surfaceLowest = Color(0xFF180A0E);
  static const Color surfaceLow = Color(0xFF27171B);
  static const Color surfaceContainer = Color(0xFF2C1B1F);
  static const Color surfaceHigh = Color(0xFF37252A);
  static const Color surfaceHighest = Color(0xFF433034);
  
  static const Color onSurface = Color(0xFFF9DBE1);
  static const Color onSurfaceVariant = Color(0xFFE3BDC5);
  
  static const Color outline = Color(0xFFAA8890);
  static const Color outlineVariant = Color(0xFF5B3F46);
  
  // Brand Colors
  static const Color primary = Color(0xFFFFB1C6);
  static const Color onPrimary = Color(0xFF650030);
  static const Color primaryContainer = Color(0xFFE20074);
  static const Color onPrimaryContainer = Color(0xFFFFFBFA);
  
  static const Color secondary = Color(0xFFA8C8FF);
  static const Color onSecondary = Color(0xFF003061);
  static const Color secondaryContainer = Color(0xFF114784);
  static const Color onSecondaryContainer = Color(0xFF8CB6FB);
  
  static const Color tertiary = Color(0xFFE8C352);
  static const Color onTertiary = Color(0xFF3D2F00);
  static const Color tertiaryContainer = Color(0xFFCAA739);
  static const Color onTertiaryContainer = Color(0xFF4E3D00);
  
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // Deprecated shim variables to prevent breaking current widgets
  static const Color base = Color(0xFF180A0E);
  static const Color elevated = Color(0xFF37252A);
  static const Color textPrimary = Color(0xFFF9DBE1);
  static const Color textSecondary = Color(0xFFE3BDC5);
  static const Color accentPrimary = Color(0xFFE20074);
}

class AppMotion {
  static const Curve silkCurve = Cubic(0.22, 1.0, 0.36, 1.0);
  static const Duration defaultDuration = Duration(milliseconds: 600);
}

class AppTypography {
  static const String fontDisplay = 'Google Sans Display';
  static const String fontText = 'Google Sans Text';
  static const String fontMono = 'Google Sans Mono';

  static const TextStyle displayXL = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 128,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -5.12, // -0.04em
    color: AppColors.onSurface,
  );

  static const TextStyle displayLG = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 96,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -2.88, // -0.03em
    color: AppColors.onSurface,
  );

  static const TextStyle displayMD = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 72,
    fontWeight: FontWeight.w500,
    height: 1.1,
    letterSpacing: -1.44, // -0.02em
    color: AppColors.onSurface,
  );

  static const TextStyle headlineLG = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 48,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: -0.48, // -0.01em
    color: AppColors.onSurface,
  );

  static const TextStyle headlineMD = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 32,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.0,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineSM = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.0,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyLG = TextStyle(
    fontFamily: fontText,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.0,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle bodyMD = TextStyle(
    fontFamily: fontText,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.0,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle labelMono = TextStyle(
    fontFamily: fontMono,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.7, // 0.05em
    color: AppColors.onSurfaceVariant,
  );

  // Fallbacks to satisfy legacy code usages
  static const TextStyle display = headlineLG;
  static const TextStyle heading = headlineMD;
  static const TextStyle subheading = headlineSM;
  static const TextStyle body = bodyMD;
  static const TextStyle caption = labelMono;
}

ThemeData getDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      background: AppColors.background,
      surface: AppColors.surfaceContainer,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
    ),
    textTheme: const TextTheme(
      displayLarge: AppTypography.displayXL,
      displayMedium: AppTypography.displayLG,
      displaySmall: AppTypography.displayMD,
      headlineLarge: AppTypography.headlineLG,
      headlineMedium: AppTypography.headlineMD,
      headlineSmall: AppTypography.headlineSM,
      bodyLarge: AppTypography.bodyLG,
      bodyMedium: AppTypography.bodyMD,
      bodySmall: AppTypography.labelMono,
    ),
  );
}
