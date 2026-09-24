import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/banners/banner_bloc.dart';
import '../../logic/banners/banner_event.dart';
import '../../logic/banners/banner_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_state.dart';
import '../widgets/image_preview.dart';
import '../widgets/status_badge.dart';

class BannersView extends StatelessWidget {
  final bool isEmbedded;
  const BannersView({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<BannerBloc, BannerState>(
          builder: (context, bannerState) {
            final banners = bannerState.banners;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isEmbedded ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Promotional & Strip Banners',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Live promotional banners served across Bhandar web & mobile apps',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Banner creator dialog launched')),
                          );
                        },
                        icon: const Icon(Icons.add_photo_alternate_rounded, size: 20),
                        label: const Text('Add Banner'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Banners List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: banners.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final banner = banners[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(themeState.borderRadius * 0.8),
                                child: ImagePreview(
                                  url: banner.imageUrl,
                                  width: 180,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: themeState.currentPalette.primary
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            banner.type.name.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: themeState.currentPalette.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        banner.isActive
                                            ? StatusBadge.success('Active')
                                            : StatusBadge.neutral('Inactive'),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      banner.title,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                    ),
                                    if (banner.subtitle != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        banner.subtitle!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Text(
                                      'Target Link: ${banner.categorySlug ?? banner.targetLink ?? 'All Categories'}',
                                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF3B82F6)),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: banner.isActive,
                                activeTrackColor:
                                    themeState.currentPalette.primary.withValues(alpha: 0.5),
                                activeThumbColor: themeState.currentPalette.primary,
                                onChanged: (val) {
                                  context
                                      .read<BannerBloc>()
                                      .add(ToggleBannerStatusEvent(banner.id));
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
