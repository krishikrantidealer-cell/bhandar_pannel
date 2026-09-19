import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../core/theme/theme_palettes.dart';
import '../../core/theme/app_theme.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class LoadThemeSettings extends ThemeEvent {
  const LoadThemeSettings();
}

class ChangeThemeMode extends ThemeEvent {
  final ThemeMode themeMode;
  const ChangeThemeMode(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class ToggleDarkMode extends ThemeEvent {
  final bool isCurrentlyDark;
  const ToggleDarkMode(this.isCurrentlyDark);

  @override
  List<Object?> get props => [isCurrentlyDark];
}

class ChangePalette extends ThemeEvent {
  final ThemePaletteId paletteId;
  const ChangePalette(this.paletteId);

  @override
  List<Object?> get props => [paletteId];
}

class ChangeFontFamily extends ThemeEvent {
  final AppFontFamily fontFamily;
  const ChangeFontFamily(this.fontFamily);

  @override
  List<Object?> get props => [fontFamily];
}

class ChangeDensity extends ThemeEvent {
  final AppDensity density;
  const ChangeDensity(this.density);

  @override
  List<Object?> get props => [density];
}

class ChangeBorderRadius extends ThemeEvent {
  final double borderRadius;
  const ChangeBorderRadius(this.borderRadius);

  @override
  List<Object?> get props => [borderRadius];
}

class ChangeBranding extends ThemeEvent {
  final String brandName;
  final String tagline;
  const ChangeBranding({required this.brandName, required this.tagline});

  @override
  List<Object?> get props => [brandName, tagline];
}

class ChangeApiBaseUrl extends ThemeEvent {
  final String apiUrl;
  const ChangeApiBaseUrl(this.apiUrl);

  @override
  List<Object?> get props => [apiUrl];
}

class ToggleSidebar extends ThemeEvent {
  const ToggleSidebar();
}

class SetSidebarCollapsed extends ThemeEvent {
  final bool isCollapsed;
  const SetSidebarCollapsed(this.isCollapsed);

  @override
  List<Object?> get props => [isCollapsed];
}

class ResetThemeDefaults extends ThemeEvent {
  const ResetThemeDefaults();
}

class ImportThemeJson extends ThemeEvent {
  final String jsonStr;
  const ImportThemeJson(this.jsonStr);

  @override
  List<Object?> get props => [jsonStr];
}
