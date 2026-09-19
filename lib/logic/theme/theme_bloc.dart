import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/theme_palettes.dart';
import '../../core/theme/app_theme.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _prefThemeMode = 'bhandar_theme_mode';
  static const String _prefPaletteId = 'bhandar_palette_id';
  static const String _prefFontFamily = 'bhandar_font_family';
  static const String _prefDensity = 'bhandar_density';
  static const String _prefBorderRadius = 'bhandar_border_radius';
  static const String _prefBrandName = 'bhandar_brand_name';
  static const String _prefTagline = 'bhandar_tagline';
  static const String _prefApiUrl = 'bhandar_api_url';
  static const String _prefIsSidebarCollapsed = 'bhandar_sidebar_collapsed';

  ThemeBloc() : super(const ThemeState()) {
    on<LoadThemeSettings>(_onLoadThemeSettings);
    on<ChangeThemeMode>(_onChangeThemeMode);
    on<ToggleDarkMode>(_onToggleDarkMode);
    on<ChangePalette>(_onChangePalette);
    on<ChangeFontFamily>(_onChangeFontFamily);
    on<ChangeDensity>(_onChangeDensity);
    on<ChangeBorderRadius>(_onChangeBorderRadius);
    on<ChangeBranding>(_onChangeBranding);
    on<ChangeApiBaseUrl>(_onChangeApiBaseUrl);
    on<ToggleSidebar>(_onToggleSidebar);
    on<SetSidebarCollapsed>(_onSetSidebarCollapsed);
    on<ResetThemeDefaults>(_onResetThemeDefaults);
    on<ImportThemeJson>(_onImportThemeJson);

    add(const LoadThemeSettings());
  }

  Future<void> _onLoadThemeSettings(LoadThemeSettings event, Emitter<ThemeState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      ThemeMode mode = state.themeMode;
      final modeStr = prefs.getString(_prefThemeMode);
      if (modeStr != null) {
        mode = ThemeMode.values.firstWhere((e) => e.name == modeStr, orElse: () => ThemeMode.system);
      }

      ThemePaletteId pal = state.paletteId;
      final palStr = prefs.getString(_prefPaletteId);
      if (palStr != null) {
        pal = ThemePaletteId.values.firstWhere((e) => e.name == palStr, orElse: () => ThemePaletteId.agriEmerald);
      }

      AppFontFamily font = state.fontFamily;
      final fontStr = prefs.getString(_prefFontFamily);
      if (fontStr != null) {
        font = AppFontFamily.values.firstWhere((e) => e.name == fontStr, orElse: () => AppFontFamily.inter);
      }

      AppDensity den = state.density;
      final denStr = prefs.getString(_prefDensity);
      if (denStr != null) {
        den = AppDensity.values.firstWhere((e) => e.name == denStr, orElse: () => AppDensity.standard);
      }

      double rad = state.borderRadius;
      final radiusVal = prefs.getDouble(_prefBorderRadius);
      if (radiusVal != null) rad = radiusVal;

      String bName = prefs.getString(_prefBrandName) ?? state.brandName;
      String tag = prefs.getString(_prefTagline) ?? state.tagline;
      String url = prefs.getString(_prefApiUrl) ?? state.apiBaseUrl;
      bool side = prefs.getBool(_prefIsSidebarCollapsed) ?? state.isSidebarCollapsed;

      emit(state.copyWith(
        themeMode: mode,
        paletteId: pal,
        fontFamily: font,
        density: den,
        borderRadius: rad,
        brandName: bName,
        tagline: tag,
        apiBaseUrl: url,
        isSidebarCollapsed: side,
      ));
    } catch (_) {}
  }

  Future<void> _onChangeThemeMode(ChangeThemeMode event, Emitter<ThemeState> emit) async {
    emit(state.copyWith(themeMode: event.themeMode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefThemeMode, event.themeMode.name);
  }

  Future<void> _onToggleDarkMode(ToggleDarkMode event, Emitter<ThemeState> emit) async {
    final newMode = event.isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    emit(state.copyWith(themeMode: newMode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefThemeMode, newMode.name);
  }

  Future<void> _onChangePalette(ChangePalette event, Emitter<ThemeState> emit) async {
    emit(state.copyWith(paletteId: event.paletteId));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefPaletteId, event.paletteId.name);
  }

  Future<void> _onChangeFontFamily(ChangeFontFamily event, Emitter<ThemeState> emit) async {
    emit(state.copyWith(fontFamily: event.fontFamily));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefFontFamily, event.fontFamily.name);
  }

  Future<void> _onChangeDensity(ChangeDensity event, Emitter<ThemeState> emit) async {
    emit(state.copyWith(density: event.density));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefDensity, event.density.name);
  }

  Future<void> _onChangeBorderRadius(ChangeBorderRadius event, Emitter<ThemeState> emit) async {
    emit(state.copyWith(borderRadius: event.borderRadius));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefBorderRadius, event.borderRadius);
  }

  Future<void> _onChangeBranding(ChangeBranding event, Emitter<ThemeState> emit) async {
    emit(state.copyWith(brandName: event.brandName, tagline: event.tagline));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefBrandName, event.brandName);
    await prefs.setString(_prefTagline, event.tagline);
  }

  Future<void> _onChangeApiBaseUrl(ChangeApiBaseUrl event, Emitter<ThemeState> emit) async {
    emit(state.copyWith(apiBaseUrl: event.apiUrl));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefApiUrl, event.apiUrl);
  }

  Future<void> _onToggleSidebar(ToggleSidebar event, Emitter<ThemeState> emit) async {
    final next = !state.isSidebarCollapsed;
    emit(state.copyWith(isSidebarCollapsed: next));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefIsSidebarCollapsed, next);
  }

  Future<void> _onSetSidebarCollapsed(SetSidebarCollapsed event, Emitter<ThemeState> emit) async {
    emit(state.copyWith(isSidebarCollapsed: event.isCollapsed));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefIsSidebarCollapsed, event.isCollapsed);
  }

  Future<void> _onResetThemeDefaults(ResetThemeDefaults event, Emitter<ThemeState> emit) async {
    const defaultState = ThemeState();
    emit(defaultState);
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _onImportThemeJson(ImportThemeJson event, Emitter<ThemeState> emit) async {
    try {
      final data = jsonDecode(event.jsonStr);
      if (data is Map<String, dynamic>) {
        ThemeMode mode = state.themeMode;
        if (data['themeMode'] != null) {
          mode = ThemeMode.values.firstWhere((e) => e.name == data['themeMode'], orElse: () => ThemeMode.system);
        }

        ThemePaletteId pal = state.paletteId;
        if (data['paletteId'] != null) {
          pal = ThemePaletteId.values.firstWhere((e) => e.name == data['paletteId'], orElse: () => ThemePaletteId.agriEmerald);
        }

        AppFontFamily font = state.fontFamily;
        if (data['fontFamily'] != null) {
          font = AppFontFamily.values.firstWhere((e) => e.name == data['fontFamily'], orElse: () => AppFontFamily.inter);
        }

        AppDensity den = state.density;
        if (data['density'] != null) {
          den = AppDensity.values.firstWhere((e) => e.name == data['density'], orElse: () => AppDensity.standard);
        }

        double rad = data['borderRadius'] != null ? (data['borderRadius'] as num).toDouble() : state.borderRadius;
        String bName = data['brandName'] ?? state.brandName;
        String tag = data['tagline'] ?? state.tagline;
        String url = data['apiBaseUrl'] ?? state.apiBaseUrl;

        emit(state.copyWith(
          themeMode: mode,
          paletteId: pal,
          fontFamily: font,
          density: den,
          borderRadius: rad,
          brandName: bName,
          tagline: tag,
          apiBaseUrl: url,
        ));
      }
    } catch (_) {}
  }

  String exportConfigJson() {
    final Map<String, dynamic> data = {
      'themeMode': state.themeMode.name,
      'paletteId': state.paletteId.name,
      'fontFamily': state.fontFamily.name,
      'density': state.density.name,
      'borderRadius': state.borderRadius,
      'brandName': state.brandName,
      'tagline': state.tagline,
      'apiBaseUrl': state.apiBaseUrl,
      'exportedAt': DateTime.now().toIso8601String(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
