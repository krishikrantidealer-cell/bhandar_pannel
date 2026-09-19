import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_palettes.dart';

enum AppFontFamily {
  inter,
  outfit,
  poppins,
  roboto,
}

enum AppDensity {
  compact,
  standard,
  comfortable,
}

class AppTheme {
  static TextTheme _buildTextTheme(
    AppFontFamily fontFamily,
    TextTheme base,
    Color textColor,
  ) {
    TextTheme fontTextTheme;
    switch (fontFamily) {
      case AppFontFamily.outfit:
        fontTextTheme = GoogleFonts.outfitTextTheme(base);
        break;
      case AppFontFamily.poppins:
        fontTextTheme = GoogleFonts.poppinsTextTheme(base);
        break;
      case AppFontFamily.roboto:
        fontTextTheme = GoogleFonts.robotoTextTheme(base);
        break;
      case AppFontFamily.inter:
        fontTextTheme = GoogleFonts.interTextTheme(base);
        break;
    }
    return fontTextTheme.apply(
      bodyColor: textColor,
      displayColor: textColor,
      decorationColor: textColor,
    );
  }

  static VisualDensity _getVisualDensity(AppDensity density) {
    switch (density) {
      case AppDensity.compact:
        return const VisualDensity(horizontal: -2, vertical: -2);
      case AppDensity.comfortable:
        return const VisualDensity(horizontal: 1.5, vertical: 1.5);
      case AppDensity.standard:
        return VisualDensity.standard;
    }
  }

  static ThemeData createTheme({
    required PaletteConfig palette,
    required bool isDark,
    required AppFontFamily fontFamily,
    required double borderRadius,
    required AppDensity density,
  }) {
    final ColorScheme colorScheme = isDark
        ? ColorScheme.dark(
            primary: palette.primary,
            onPrimary: Colors.white,
            primaryContainer: palette.primary.withValues(alpha: 0.2),
            onPrimaryContainer: palette.primary,
            secondary: palette.secondary,
            onSecondary: Colors.white,
            secondaryContainer: palette.secondary.withValues(alpha: 0.2),
            surface: palette.surfaceDark,
            onSurface: const Color(0xFFF1F5F9),
            error: const Color(0xFFEF4444),
            onError: Colors.white,
            outline: const Color(0xFF334155),
          )
        : ColorScheme.light(
            primary: palette.primary,
            onPrimary: Colors.white,
            primaryContainer: palette.primary.withValues(alpha: 0.12),
            onPrimaryContainer: palette.secondary,
            secondary: palette.secondary,
            onSecondary: Colors.white,
            secondaryContainer: palette.secondary.withValues(alpha: 0.12),
            surface: palette.surfaceLight,
            onSurface: const Color(0xFF0F172A),
            error: const Color(0xFFDC2626),
            onError: Colors.white,
            outline: const Color(0xFFE2E8F0),
          );

    final TextTheme baseTextTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final TextTheme textTheme = _buildTextTheme(
      fontFamily,
      baseTextTheme,
      colorScheme.onSurface,
    );

    final roundedBorder = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? palette.backgroundDark : palette.backgroundLight,
      textTheme: textTheme,
      visualDensity: _getVisualDensity(density),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: roundedBorder.copyWith(
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: isDark ? 0.6 : 0.8),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: roundedBorder,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          shape: roundedBorder,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
