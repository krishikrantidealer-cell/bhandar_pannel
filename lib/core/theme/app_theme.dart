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
    bool isDark,
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

    final primaryTextColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155);
    final mutedTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return fontTextTheme.copyWith(
      displayLarge: fontTextTheme.displayLarge?.copyWith(color: primaryTextColor, fontWeight: FontWeight.w800, letterSpacing: -0.5),
      displayMedium: fontTextTheme.displayMedium?.copyWith(color: primaryTextColor, fontWeight: FontWeight.w800, letterSpacing: -0.5),
      displaySmall: fontTextTheme.displaySmall?.copyWith(color: primaryTextColor, fontWeight: FontWeight.w700, letterSpacing: -0.3),
      headlineLarge: fontTextTheme.headlineLarge?.copyWith(color: primaryTextColor, fontWeight: FontWeight.w700, letterSpacing: -0.3),
      headlineMedium: fontTextTheme.headlineMedium?.copyWith(color: primaryTextColor, fontWeight: FontWeight.w700, letterSpacing: -0.2),
      headlineSmall: fontTextTheme.headlineSmall?.copyWith(color: primaryTextColor, fontWeight: FontWeight.w600, letterSpacing: -0.2),
      titleLarge: fontTextTheme.titleLarge?.copyWith(color: primaryTextColor, fontWeight: FontWeight.w700, letterSpacing: -0.2),
      titleMedium: fontTextTheme.titleMedium?.copyWith(color: primaryTextColor, fontWeight: FontWeight.w600, letterSpacing: -0.1),
      titleSmall: fontTextTheme.titleSmall?.copyWith(color: secondaryTextColor, fontWeight: FontWeight.w600),
      bodyLarge: fontTextTheme.bodyLarge?.copyWith(color: primaryTextColor, fontWeight: FontWeight.w500, fontSize: 14),
      bodyMedium: fontTextTheme.bodyMedium?.copyWith(color: secondaryTextColor, fontWeight: FontWeight.w500, fontSize: 13),
      bodySmall: fontTextTheme.bodySmall?.copyWith(color: mutedTextColor, fontWeight: FontWeight.w500, fontSize: 11.5),
      labelLarge: fontTextTheme.labelLarge?.copyWith(color: primaryTextColor, fontWeight: FontWeight.w700, letterSpacing: 0.2),
      labelMedium: fontTextTheme.labelMedium?.copyWith(color: secondaryTextColor, fontWeight: FontWeight.w600),
      labelSmall: fontTextTheme.labelSmall?.copyWith(color: mutedTextColor, fontWeight: FontWeight.w600, letterSpacing: 0.3),
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
            primaryContainer: palette.primary.withValues(alpha: 0.22),
            onPrimaryContainer: palette.primary,
            secondary: palette.secondary,
            onSecondary: Colors.white,
            secondaryContainer: palette.secondary.withValues(alpha: 0.22),
            surface: palette.surfaceDark,
            onSurface: const Color(0xFFF8FAFC),
            onSurfaceVariant: const Color(0xFFCBD5E1),
            error: const Color(0xFFEF4444),
            onError: Colors.white,
            outline: const Color(0xFF334155),
            outlineVariant: const Color(0xFF475569),
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
            onSurfaceVariant: const Color(0xFF475569),
            error: const Color(0xFFDC2626),
            onError: Colors.white,
            outline: const Color(0xFFE2E8F0),
            outlineVariant: const Color(0xFFCBD5E1),
          );

    final TextTheme baseTextTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final TextTheme textTheme = _buildTextTheme(
      fontFamily,
      baseTextTheme,
      isDark,
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
            color: colorScheme.outline.withValues(alpha: isDark ? 0.7 : 0.8),
            width: 1,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? const Color(0xFF161E2E) : Colors.white,
        shape: roundedBorder.copyWith(
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: isDark ? 0.8 : 0.5),
            width: 1,
          ),
        ),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
        ),
        contentTextStyle: TextStyle(
          fontSize: 13.5,
          color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: isDark ? const Color(0xFF161E2E) : Colors.white,
        shape: roundedBorder.copyWith(
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: isDark ? 0.8 : 0.5),
            width: 1,
          ),
        ),
        textStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
        ),
        hintStyle: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: isDark ? 0.8 : 0.8)),
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
          foregroundColor: isDark ? const Color(0xFFF8FAFC) : colorScheme.onSurface,
          shape: roundedBorder,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: isDark ? 0.6 : 0.5),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
