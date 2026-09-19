import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/theme_palettes.dart';
import '../../core/theme/app_theme.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_event.dart';
import '../../logic/theme/theme_state.dart';
import '../../logic/dashboard/dashboard_bloc.dart';
import '../../logic/dashboard/dashboard_event.dart';
import '../../logic/products/product_bloc.dart';
import '../../logic/products/product_event.dart';
import '../../logic/categories/category_bloc.dart';
import '../../logic/categories/category_event.dart';
import '../../logic/orders/order_bloc.dart';
import '../../logic/orders/order_event.dart';
import '../../logic/banners/banner_bloc.dart';
import '../../logic/banners/banner_event.dart';
import '../../logic/coupons/coupon_bloc.dart';
import '../../logic/coupons/coupon_event.dart';

class CustomizationView extends StatefulWidget {
  const CustomizationView({super.key});

  @override
  State<CustomizationView> createState() => _CustomizationViewState();
}

class _CustomizationViewState extends State<CustomizationView> {
  late TextEditingController _brandNameController;
  late TextEditingController _taglineController;
  late TextEditingController _apiUrlController;
  late TextEditingController _jsonConfigController;

  @override
  void initState() {
    super.initState();
    final themeState = context.read<ThemeBloc>().state;
    _brandNameController = TextEditingController(text: themeState.brandName);
    _taglineController = TextEditingController(text: themeState.tagline);
    _apiUrlController = TextEditingController(text: themeState.apiBaseUrl);
    _jsonConfigController =
        TextEditingController(text: context.read<ThemeBloc>().exportConfigJson());
  }

  @override
  void dispose() {
    _brandNameController.dispose();
    _taglineController.dispose();
    _apiUrlController.dispose();
    _jsonConfigController.dispose();
    super.dispose();
  }

  void _syncJsonExport() {
    _jsonConfigController.text = context.read<ThemeBloc>().exportConfigJson();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme & White-Label Customization Studio',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Live adjust color schemes, typography, layout density, branding, and backend API endpoints',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<ThemeBloc>().add(const ResetThemeDefaults());
                      _brandNameController.text = AppConfig.defaultBrandName;
                      _taglineController.text = AppConfig.defaultTagline;
                      _apiUrlController.text = AppConfig.defaultApiBaseUrl;
                      _syncJsonExport();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reset to default configurations')),
                      );
                    },
                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                    label: const Text('Reset Defaults'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Section 1: Color Palettes & Dark Mode
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.palette_outlined, size: 20, color: Color(0xFF10B981)),
                          const SizedBox(width: 8),
                          Text(
                            'Color Palette & Theme Mode',
                            style:
                                theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Theme Mode (Light / Dark / System)
                      Row(
                        children: [
                          const Text('Theme Appearance:',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 16),
                          SegmentedButton<ThemeMode>(
                            segments: const [
                              ButtonSegment(
                                  value: ThemeMode.light,
                                  icon: Icon(Icons.light_mode_outlined),
                                  label: Text('Light')),
                              ButtonSegment(
                                  value: ThemeMode.dark,
                                  icon: Icon(Icons.dark_mode_outlined),
                                  label: Text('Dark')),
                              ButtonSegment(
                                  value: ThemeMode.system,
                                  icon: Icon(Icons.settings_suggest_outlined),
                                  label: Text('System')),
                            ],
                            selected: {themeState.themeMode},
                            onSelectionChanged: (newSelection) {
                              context
                                  .read<ThemeBloc>()
                                  .add(ChangeThemeMode(newSelection.first));
                              _syncJsonExport();
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Palette Options Grid
                      const Text('Curated Color Schemes:',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: AppPalettes.all.map((palette) {
                          final isSelected = themeState.paletteId == palette.id;

                          return InkWell(
                            onTap: () {
                              context.read<ThemeBloc>().add(ChangePalette(palette.id));
                              _syncJsonExport();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 220,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? palette.primary
                                      : (isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE2E8F0)),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: palette.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: palette.secondary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: palette.accent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (isSelected)
                                        Icon(Icons.check_circle,
                                            size: 18, color: palette.primary),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    palette.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    palette.description,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Section 2: Typography & Corner Radius
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.text_fields_rounded,
                              size: 20, color: Color(0xFF3B82F6)),
                          const SizedBox(width: 8),
                          Text(
                            'Typography & Layout Ergonomics',
                            style:
                                theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Font Family
                      Row(
                        children: [
                          const SizedBox(
                              width: 140,
                              child: Text('Font Family:',
                                  style: TextStyle(fontWeight: FontWeight.w600))),
                          ...AppFontFamily.values.map((f) {
                            final isSelected = themeState.fontFamily == f;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(f.name.toUpperCase()),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    context.read<ThemeBloc>().add(ChangeFontFamily(f));
                                    _syncJsonExport();
                                  }
                                },
                              ),
                            );
                          }),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // UI Density
                      Row(
                        children: [
                          const SizedBox(
                              width: 140,
                              child: Text('UI Density:',
                                  style: TextStyle(fontWeight: FontWeight.w600))),
                          ...AppDensity.values.map((d) {
                            final isSelected = themeState.density == d;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(d.name.toUpperCase()),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    context.read<ThemeBloc>().add(ChangeDensity(d));
                                    _syncJsonExport();
                                  }
                                },
                              ),
                            );
                          }),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Border Radius Slider
                      Row(
                        children: [
                          SizedBox(
                            width: 140,
                            child: Text(
                              'Corner Radius: ${themeState.borderRadius.toInt()}px',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: themeState.borderRadius,
                              min: 4,
                              max: 24,
                              divisions: 10,
                              label: '${themeState.borderRadius.toInt()}px',
                              onChanged: (val) {
                                context.read<ThemeBloc>().add(ChangeBorderRadius(val));
                                _syncJsonExport();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Section 3: White-Label Branding & Backend Endpoint
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.business_rounded, size: 20, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 8),
                          Text(
                            'White-Label Branding & API Connectivity',
                            style:
                                theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _brandNameController,
                              decoration: const InputDecoration(
                                labelText: 'Brand / Application Name',
                                hintText: 'Krishi Bhandar',
                              ),
                              onChanged: (val) {
                                context.read<ThemeBloc>().add(
                                      ChangeBranding(
                                        brandName: val.trim().isNotEmpty
                                            ? val.trim()
                                            : AppConfig.defaultBrandName,
                                        tagline: _taglineController.text.trim(),
                                      ),
                                    );
                                _syncJsonExport();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _taglineController,
                              decoration: const InputDecoration(
                                labelText: 'Tagline',
                                hintText: 'E-Commerce Admin & Operations Panel',
                              ),
                              onChanged: (val) {
                                context.read<ThemeBloc>().add(
                                      ChangeBranding(
                                        brandName: _brandNameController.text.trim(),
                                        tagline: val.trim(),
                                      ),
                                    );
                                _syncJsonExport();
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Backend API URL
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _apiUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Bhandar Backend API Base URL',
                                hintText:
                                    'https://backend-bhandar-205278744741.asia-south1.run.app',
                                prefixIcon: Icon(Icons.cloud_queue_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              final newUrl = _apiUrlController.text.trim();
                              if (newUrl.isNotEmpty) {
                                context.read<ThemeBloc>().add(ChangeApiBaseUrl(newUrl));
                                context.read<DashboardBloc>().add(const LoadDashboardData());
                                context.read<ProductBloc>().add(const LoadProducts());
                                context.read<CategoryBloc>().add(const LoadCategories());
                                context.read<OrderBloc>().add(const LoadOrders());
                                context.read<BannerBloc>().add(const LoadBanners());
                                context.read<CouponBloc>().add(const LoadCoupons());
                                _syncJsonExport();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Connected to: $newUrl')),
                                );
                              }
                            },
                            icon: const Icon(Icons.link_rounded, size: 18),
                            label: const Text('Update & Test API'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ActionChip(
                            label: const Text('Use Cloud Run Production'),
                            onPressed: () {
                              _apiUrlController.text = AppConfig.defaultApiBaseUrl;
                              context
                                  .read<ThemeBloc>()
                                  .add(const ChangeApiBaseUrl(AppConfig.defaultApiBaseUrl));
                              _syncJsonExport();
                            },
                          ),
                          ActionChip(
                            label: const Text('Use Localhost (Port 8000)'),
                            onPressed: () {
                              _apiUrlController.text = AppConfig.localApiBaseUrl;
                              context
                                  .read<ThemeBloc>()
                                  .add(const ChangeApiBaseUrl(AppConfig.localApiBaseUrl));
                              _syncJsonExport();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Section 4: Export & Import Configuration JSON
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.code_rounded, size: 20, color: Color(0xFF8B5CF6)),
                          const SizedBox(width: 8),
                          Text(
                            'Configuration Backup & Presets (JSON)',
                            style:
                                theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _jsonConfigController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText: 'Configuration JSON snippet...',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _jsonConfigController.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Configuration JSON copied to clipboard!')),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded, size: 16),
                            label: const Text('Copy Preset'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              context
                                  .read<ThemeBloc>()
                                  .add(ImportThemeJson(_jsonConfigController.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Configuration imported successfully!')),
                              );
                            },
                            icon: const Icon(Icons.download_rounded, size: 16),
                            label: const Text('Import Preset'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
