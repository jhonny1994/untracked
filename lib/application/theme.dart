import 'package:flutter/material.dart';

/// App theme configuration with Material You support
abstract class AppTheme {
  /// Primary brand color - Teal accent from PRD
  static const Color _primaryColor = Color(0xFF208299);

  /// Custom text theme with Noto Sans for RTL/LTR support
  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: 'Noto Sans',
        fontWeight: FontWeight.w400,
        letterSpacing: -0.5,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontFamily: 'Noto Sans',
        fontWeight: FontWeight.w400,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontFamily: 'Noto Sans',
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: 'Noto Sans',
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: 'Noto Sans',
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontFamily: 'Noto Sans',
        fontWeight: FontWeight.w600,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: 'Noto Sans',
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontFamily: 'Noto Sans',
        fontWeight: FontWeight.w500,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontFamily: 'Noto Sans',
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: 'Noto Sans',
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: 'Noto Sans',
        fontWeight: FontWeight.w400,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontFamily: 'Noto Sans',
        fontWeight: FontWeight.w400,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: 'Noto Sans',
        fontWeight: FontWeight.w500,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontFamily: 'Noto Sans',
        fontWeight: FontWeight.w500,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontFamily: 'Noto Sans',
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Light theme
  static ThemeData light([ColorScheme? dynamicColorScheme]) {
    final colorScheme =
        dynamicColorScheme ??
        ColorScheme.fromSeed(
          seedColor: _primaryColor,
        );

    return _buildTheme(colorScheme, Brightness.light);
  }

  /// Dark theme
  static ThemeData dark([ColorScheme? dynamicColorScheme]) {
    final colorScheme =
        dynamicColorScheme ??
        ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.dark,
        );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  /// Build theme from color scheme
  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final baseTextTheme = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(baseTextTheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant,
          ),
        ),
      ),

      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),

      // Filled buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.error,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
