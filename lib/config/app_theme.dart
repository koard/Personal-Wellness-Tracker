import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global theme configuration for the Personal Wellness Tracker app
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Color palette for light theme
  static const AppColors lightColors = AppColors(
    // Primary colors
    primaryBackground: Color(0xFF52357B), // Purple from your specification
    primaryBackgroundLight: Color(0xFF6B46A3),
    primaryBackgroundDark: Color(0xFF3F2768),
    primaryForeground: Colors.white,

    // Secondary colors
    secondaryBackground: Color(0xFF10B981), // Emerald
    secondaryBackgroundLight: Color(0xFF34D399),
    secondaryBackgroundDark: Color(0xFF059669),
    secondaryForeground: Colors.white,

    // Accent colors
    accentBackground: Color(0xFFF59E0B), // Amber
    accentBackgroundLight: Color(0xFFFBBF24),
    accentBackgroundDark: Color(0xFFD97706),
    accentForeground: Colors.white,

    // Muted colors
    mutedBackground: Color(0xFF6B7280), // Gray
    mutedBackgroundLight: Color(0xFF9CA3AF),
    mutedBackgroundDark: Color(0xFF4B5563),
    mutedForeground: Colors.white,

    // Surface colors
    surfaceBackground: Colors.white,
    surfaceBackgroundVariant: Color(0xFFF9FAFB),
    surfaceForeground: Color(0xFF52357B), // Dark purple text on light surface
    surfaceForegroundVariant: Color(0xFF52357B),

    // App background colors
    appBackground: Colors.white, // Light background
    appForeground: Color(0xFF52357B), // Dark purple text on light background

    // Error colors
    errorBackground: Color(0xFFEF4444),
    errorForeground: Colors.white,

    // Success colors
    successBackground: Color(0xFF10B981),
    successForeground: Colors.white,

    // Warning colors
    warningBackground: Color(0xFFF59E0B),
    warningForeground: Colors.white,

    // Info colors
    infoBackground: Color(0xFF3B82F6),
    infoForeground: Colors.white,
  );

  /// Color palette for dark theme (default)
  static const AppColors darkColors = AppColors(
    // Primary colors
    primaryBackground: Color(0xFF8B7AB8), // Lighter purple for dark theme
    primaryBackgroundLight: Color(0xFFA393D1),
    primaryBackgroundDark: Color(0xFF6B5B7B),
    primaryForeground: Color(0xFF52357B),

    // Secondary colors
    secondaryBackground: Color(0xFF34D399), // Lighter emerald for dark theme
    secondaryBackgroundLight: Color(0xFF6EE7B7),
    secondaryBackgroundDark: Color(0xFF10B981),
    secondaryForeground: Color(0xFF52357B),

    // Accent colors
    accentBackground: Color(0xFFFBBF24), // Lighter amber for dark theme
    accentBackgroundLight: Color(0xFFFCD34D),
    accentBackgroundDark: Color(0xFFF59E0B),
    accentForeground: Color(0xFF52357B),

    // Muted colors
    mutedBackground: Color(0xFF9CA3AF), // Lighter gray for dark theme
    mutedBackgroundLight: Color(0xFFD1D5DB),
    mutedBackgroundDark: Color(0xFF6B7280),
    mutedForeground: Color(0xFF52357B),

    // Surface colors
    surfaceBackground: Color(0xFF52357B), // Dark purple surface
    surfaceBackgroundVariant: Color(0xFF3F2768),
    surfaceForeground: Colors.white, // White text on dark surface
    surfaceForegroundVariant: Colors.white,

    // Background colors
    appBackground: Color(0xFF52357B), // Dark purple background
    appForeground: Colors.white, // White text on dark background

    // Error colors
    errorBackground: Color(0xFFF87171),
    errorForeground: Color(0xFF52357B),

    // Success colors
    successBackground: Color(0xFF34D399),
    successForeground: Color(0xFF52357B),

    // Warning colors
    warningBackground: Color(0xFFFBBF24),
    warningForeground: Color(0xFF52357B),

    // Info colors
    infoBackground: Color(0xFF60A5FA),
    infoForeground: Color(0xFF52357B),
  );

  /// Get the current color scheme based on brightness
  static AppColors colors(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkColors 
        : lightColors;
  }

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.indigo,
      primaryColor: lightColors.primaryBackground,
      scaffoldBackgroundColor: lightColors.appBackground,
      colorScheme: ColorScheme.light(
        primary: lightColors.primaryBackground,
        secondary: lightColors.secondaryBackground,
        surface: lightColors.surfaceBackground,
        background: lightColors.appBackground,
        error: lightColors.errorBackground,
        onPrimary: lightColors.primaryForeground,
        onSecondary: lightColors.secondaryForeground,
        onSurface: lightColors.surfaceForeground,
        onBackground: lightColors.appForeground,
        onError: lightColors.errorForeground,
      ),
      textTheme: GoogleFonts.notoSansThaiTextTheme(
        ThemeData.light().textTheme.apply(
          bodyColor: lightColors.appForeground,
          displayColor: lightColors.appForeground,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightColors.surfaceBackground,
        foregroundColor: lightColors.surfaceForeground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSansThaiTextTheme().headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: lightColors.surfaceForeground,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightColors.primaryBackground,
          foregroundColor: lightColors.primaryForeground,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        color: lightColors.surfaceBackground,
        shadowColor: lightColors.mutedBackground.withValues(alpha: 0.1),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      useMaterial3: true,
    );
  }

  /// Dark theme configuration (default)
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.indigo,
      primaryColor: darkColors.primaryBackground,
      scaffoldBackgroundColor: darkColors.appBackground,
      colorScheme: ColorScheme.dark(
        primary: darkColors.primaryBackground,
        secondary: darkColors.secondaryBackground,
        surface: darkColors.surfaceBackground,
        background: darkColors.appBackground,
        error: darkColors.errorBackground,
        onPrimary: darkColors.primaryForeground,
        onSecondary: darkColors.secondaryForeground,
        onSurface: darkColors.surfaceForeground,
        onBackground: darkColors.appForeground,
        onError: darkColors.errorForeground,
      ),
      textTheme: GoogleFonts.notoSansThaiTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: darkColors.appForeground,
          displayColor: darkColors.appForeground,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkColors.surfaceBackground,
        foregroundColor: darkColors.surfaceForeground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSansThaiTextTheme().headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: darkColors.surfaceForeground,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkColors.primaryBackground,
          foregroundColor: darkColors.primaryForeground,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkColors.surfaceBackground,
        shadowColor: darkColors.mutedBackground.withValues(alpha: 0.1),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      useMaterial3: true,
    );
  }

  /// Common text styles
  static TextStyle headingLarge(BuildContext context) {
    return GoogleFonts.notoSansThaiTextTheme().headlineLarge!.copyWith(
      color: AppTheme.colors(context).appForeground,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle headingMedium(BuildContext context) {
    return GoogleFonts.notoSansThaiTextTheme().headlineMedium!.copyWith(
      color: AppTheme.colors(context).appForeground,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle bodyLarge(BuildContext context) {
    return GoogleFonts.notoSansThaiTextTheme().bodyLarge!.copyWith(
      color: AppTheme.colors(context).appForeground,
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return GoogleFonts.notoSansThaiTextTheme().bodyMedium!.copyWith(
      color: AppTheme.colors(context).appForeground,
    );
  }

  static TextStyle labelLarge(BuildContext context) {
    return GoogleFonts.notoSansThaiTextTheme().labelLarge!.copyWith(
      color: AppTheme.colors(context).appForeground,
      fontWeight: FontWeight.w500,
    );
  }
}

/// Color palette class to hold all color definitions
class AppColors {
  const AppColors({
    required this.primaryBackground,
    required this.primaryBackgroundLight,
    required this.primaryBackgroundDark,
    required this.primaryForeground,
    required this.secondaryBackground,
    required this.secondaryBackgroundLight,
    required this.secondaryBackgroundDark,
    required this.secondaryForeground,
    required this.accentBackground,
    required this.accentBackgroundLight,
    required this.accentBackgroundDark,
    required this.accentForeground,
    required this.mutedBackground,
    required this.mutedBackgroundLight,
    required this.mutedBackgroundDark,
    required this.mutedForeground,
    required this.surfaceBackground,
    required this.surfaceBackgroundVariant,
    required this.surfaceForeground,
    required this.surfaceForegroundVariant,
    required this.appBackground,
    required this.appForeground,
    required this.errorBackground,
    required this.errorForeground,
    required this.successBackground,
    required this.successForeground,
    required this.warningBackground,
    required this.warningForeground,
    required this.infoBackground,
    required this.infoForeground,
  });

  // Primary colors
  final Color primaryBackground;
  final Color primaryBackgroundLight;
  final Color primaryBackgroundDark;
  final Color primaryForeground;

  // Secondary colors
  final Color secondaryBackground;
  final Color secondaryBackgroundLight;
  final Color secondaryBackgroundDark;
  final Color secondaryForeground;

  // Accent colors
  final Color accentBackground;
  final Color accentBackgroundLight;
  final Color accentBackgroundDark;
  final Color accentForeground;

  // Muted colors
  final Color mutedBackground;
  final Color mutedBackgroundLight;
  final Color mutedBackgroundDark;
  final Color mutedForeground;

  // Surface colors
  final Color surfaceBackground;
  final Color surfaceBackgroundVariant;
  final Color surfaceForeground;
  final Color surfaceForegroundVariant;

  // App background colors
  final Color appBackground;
  final Color appForeground;

  // Error colors
  final Color errorBackground;
  final Color errorForeground;

  // Success colors
  final Color successBackground;
  final Color successForeground;

  // Warning colors
  final Color warningBackground;
  final Color warningForeground;

  // Info colors
  final Color infoBackground;
  final Color infoForeground;
}
