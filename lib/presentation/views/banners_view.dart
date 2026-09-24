import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/banners/banner_bloc.dart';
import '../../logic/banners/banner_event.dart';
import '../../logic/banners/banner_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_state.dart';
import '../../models/banner_model.dart';
import '../widgets/image_preview.dart';
import '../widgets/status_badge.dart';
import '../widgets/shimmer_loading.dart';

class BannersView extends StatelessWidget {
  final bool isEmbedded;
  const BannersView({super.key, this.isEmbedded = false});

  void _showAddEditBannerModal(BuildContext context, {BannerModel? existingBanner}) {
    final titleController = TextEditingController(text: existingBanner?.title ?? '');
    final subtitleController = TextEditingController(text: existingBanner?.subtitle ?? '');
    final imageUrlController = TextEditingController(text: existingBanner?.imageUrl ?? '');
    final linkValueController = TextEditingController(text: existingBanner?.linkValue ?? existingBanner?.categorySlug ?? '');
    final priorityController = TextEditingController(text: existingBanner?.priority.toString() ?? '0');
    
    String selectedType = existingBanner?.type == BannerType.category ? 'category' : 'home';
    String selectedLinkType = existingBanner?.linkType ?? 'category';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return AlertDialog(
            title: Text(existingBanner == null ? 'Add Promotional Banner' : 'Edit Banner'),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Banner Title *',
                        hintText: 'e.g. Monsoon Mega Discount',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: subtitleController,
                      decoration: const InputDecoration(
                        labelText: 'Subtitle / Description',
                        hintText: 'Up to 30% OFF on Insecticides & Fungicides',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Banner Image URL *',
                        hintText: 'https://storage.googleapis.com/...',
                        prefixIcon: Icon(Icons.link_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: selectedType,
                            decoration: const InputDecoration(labelText: 'Banner Placement'),
                            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                            items: const [
                              DropdownMenuItem(value: 'home', child: Text('Home Carousel', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'category', child: Text('Category Banner', overflow: TextOverflow.ellipsis)),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => selectedType = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: selectedLinkType,
                            decoration: const InputDecoration(labelText: 'Link Type'),
                            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                            items: const [
                              DropdownMenuItem(value: 'category', child: Text('Category', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'collection', child: Text('Collection', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'product', child: Text('Product', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'url', child: Text('External URL', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'none', child: Text('None', overflow: TextOverflow.ellipsis)),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => selectedLinkType = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: linkValueController,
                            decoration: const InputDecoration(
                              labelText: 'Link Value (Slug / ID / URL)',
                              hintText: 'fungicides',
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: priorityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Order / Priority',
                              hintText: '0',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  final imageUrl = imageUrlController.text.trim();
                  if (title.isEmpty || imageUrl.isEmpty) return;

                  final bannerData = {
                    'title': title,
                    'subtitle': subtitleController.text.trim(),
                    'imageUrl': imageUrl,
                    'type': selectedType,
                    'linkType': selectedLinkType,
                    'linkValue': linkValueController.text.trim(),
                    'categorySlug': selectedLinkType == 'category' ? linkValueController.text.trim() : null,
                    'order': int.tryParse(priorityController.text) ?? 0,
                    'isActive': existingBanner?.isActive ?? true,
                  };

                  if (existingBanner == null) {
                    context.read<BannerBloc>().add(AddBannerEvent(bannerData));
                  } else {
                    context.read<BannerBloc>().add(UpdateBannerEvent(existingBanner.id, bannerData));
                  }
                  Navigator.of(dialogCtx).pop();
                },
                child: Text(existingBanner == null ? 'Create Banner' : 'Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteBanner(BuildContext context, BannerModel banner) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Banner?'),
        content: Text('Are you sure you want to delete "${banner.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              context.read<BannerBloc>().add(DeleteBannerEvent(banner.id));
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

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
                        onPressed: () => _showAddEditBannerModal(context),
                        icon: const Icon(Icons.add_photo_alternate_rounded, size: 20),
                        label: const Text('Add Banner'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Banners List
                  if (bannerState.isLoading)
                    Shimmer(
                      child: Column(
                        children: List.generate(
                          4,
                          (index) => Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SkeletonBox(width: 140, height: 75, borderRadius: 8),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        SkeletonBox(width: 180, height: 16, borderRadius: 4),
                                        SizedBox(height: 8),
                                        SkeletonBox(width: 260, height: 12, borderRadius: 3),
                                        SizedBox(height: 12),
                                        SkeletonBadge(width: 80, height: 20),
                                      ],
                                    ),
                                  ),
                                  const SkeletonBox(width: 50, height: 24, borderRadius: 4),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (banners.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: Text(
                        'No banners found. Click "Add Banner" to create your first promotion.',
                        style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      ),
                    )
                  else
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
                                          if (banner.subtitle != null && banner.subtitle!.isNotEmpty) ...[
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
                                            'Target Link: ${banner.categorySlug ?? banner.targetLink ?? banner.linkValue ?? 'All Categories'}',
                                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF3B82F6)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18),
                                          tooltip: 'Edit Banner',
                                          onPressed: () => _showAddEditBannerModal(context, existingBanner: banner),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                                          tooltip: 'Delete Banner',
                                          onPressed: () => _confirmDeleteBanner(context, banner),
                                        ),
                                        const SizedBox(width: 8),
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
