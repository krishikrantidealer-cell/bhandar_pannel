import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/theme_palettes.dart';
import '../../core/theme/app_theme.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final ThemePaletteId paletteId;
  final AppFontFamily fontFamily;
  final AppDensity density;
  final double borderRadius;
  final String brandName;
  final String tagline;
  final String apiBaseUrl;
  final bool isSidebarCollapsed;

  const ThemeState({
    this.themeMode = ThemeMode.system,
    this.paletteId = ThemePaletteId.agriEmerald,
    this.fontFamily = AppFontFamily.inter,
    this.density = AppDensity.standard,
    this.borderRadius = 12.0,
    this.brandName = AppConfig.defaultBrandName,
    this.tagline = AppConfig.defaultTagline,
    this.apiBaseUrl = AppConfig.defaultApiBaseUrl,
    this.isSidebarCollapsed = false,
  });

  PaletteConfig get currentPalette => AppPalettes.getById(paletteId);

  ThemeState copyWith({
    ThemeMode? themeMode,
    ThemePaletteId? paletteId,
    AppFontFamily? fontFamily,
    AppDensity? density,
    double? borderRadius,
    String? brandName,
    String? tagline,
    String? apiBaseUrl,
    bool? isSidebarCollapsed,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      paletteId: paletteId ?? this.paletteId,
      fontFamily: fontFamily ?? this.fontFamily,
      density: density ?? this.density,
      borderRadius: borderRadius ?? this.borderRadius,
      brandName: brandName ?? this.brandName,
      tagline: tagline ?? this.tagline,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      isSidebarCollapsed: isSidebarCollapsed ?? this.isSidebarCollapsed,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        paletteId,
        fontFamily,
        density,
        borderRadius,
        brandName,
        tagline,
        apiBaseUrl,
        isSidebarCollapsed,
      ];
}
