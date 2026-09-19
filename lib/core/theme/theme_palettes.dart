import 'package:flutter/material.dart';

enum ThemePaletteId {
  agriEmerald,
  royalIndigo,
  oceanBlue,
  amberGold,
  crimsonRuby,
  slateModern,
}

class PaletteConfig {
  final ThemePaletteId id;
  final String name;
  final String description;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color backgroundLight;
  final Color surfaceLight;
  final Color backgroundDark;
  final Color surfaceDark;

  const PaletteConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.primary,
    required this.secondary,
    required this.accent,
    this.backgroundLight = const Color(0xFFF8FAFC),
    this.surfaceLight = Colors.white,
    this.backgroundDark = const Color(0xFF0F172A),
    this.surfaceDark = const Color(0xFF1E293B),
  });
}

class AppPalettes {
  static const PaletteConfig agriEmerald = PaletteConfig(
    id: ThemePaletteId.agriEmerald,
    name: 'Agri Emerald',
    description: 'Fresh agricultural greens & earthy tones for Krishi Bhandar',
    primary: Color(0xFF10B981),
    secondary: Color(0xFF059669),
    accent: Color(0xFFF59E0B),
  );

  static const PaletteConfig royalIndigo = PaletteConfig(
    id: ThemePaletteId.royalIndigo,
    name: 'Royal Indigo',
    description: 'Modern corporate SaaS deep indigo & purple accents',
    primary: Color(0xFF6366F1),
    secondary: Color(0xFF4F46E5),
    accent: Color(0xFFEC4899),
  );

  static const PaletteConfig oceanBlue = PaletteConfig(
    id: ThemePaletteId.oceanBlue,
    name: 'Ocean Blue',
    description: 'Crisp azure & sky tones for an executive dashboard',
    primary: Color(0xFF0284C7),
    secondary: Color(0xFF0369A1),
    accent: Color(0xFF14B8A6),
  );

  static const PaletteConfig amberGold = PaletteConfig(
    id: ThemePaletteId.amberGold,
    name: 'Amber Harvest',
    description: 'Warm golden & harvest bronze hues',
    primary: Color(0xFFD97706),
    secondary: Color(0xFFB45309),
    accent: Color(0xFF10B981),
  );

  static const PaletteConfig crimsonRuby = PaletteConfig(
    id: ThemePaletteId.crimsonRuby,
    name: 'Crimson Ruby',
    description: 'Bold vibrant ruby with rose & charcoal',
    primary: Color(0xFFE11D48),
    secondary: Color(0xFFBE123C),
    accent: Color(0xFF8B5CF6),
  );

  static const PaletteConfig slateModern = PaletteConfig(
    id: ThemePaletteId.slateModern,
    name: 'Slate Minimal',
    description: 'High-contrast monochrome slate and titanium',
    primary: Color(0xFF334155),
    secondary: Color(0xFF1E293B),
    accent: Color(0xFF06B6D4),
  );

  static const List<PaletteConfig> all = [
    agriEmerald,
    royalIndigo,
    oceanBlue,
    amberGold,
    crimsonRuby,
    slateModern,
  ];

  static PaletteConfig getById(ThemePaletteId id) {
    return all.firstWhere((p) => p.id == id, orElse: () => agriEmerald);
  }
}
