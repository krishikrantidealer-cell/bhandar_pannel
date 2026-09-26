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
import '../../core/utils/image_upload_helper.dart';

class BannersView extends StatefulWidget {
  final bool isEmbedded;
  const BannersView({super.key, this.isEmbedded = false});

  @override
  State<BannersView> createState() => _BannersViewState();
}

class _BannersViewState extends State<BannersView> {
  int _selectedFilterIndex = 0; // 0: All, 1: Home Carousel, 2: Category, 3: Active Only
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditBannerModal(BuildContext context, {BannerModel? existingBanner, String defaultType = 'home'}) {
    final titleController = TextEditingController(text: existingBanner?.title ?? '');
    final subtitleController = TextEditingController(text: existingBanner?.subtitle ?? '');
    final imageUrlController = TextEditingController(text: existingBanner?.imageUrl ?? '');
    final linkValueController = TextEditingController(
        text: existingBanner?.linkValue ?? existingBanner?.categorySlug ?? existingBanner?.targetLink ?? '');
    final priorityController = TextEditingController(
        text: existingBanner?.priority != null && existingBanner!.priority > 0
            ? existingBanner.priority.toString()
            : (existingBanner == null ? '1' : '0'));

    String selectedType = existingBanner != null
        ? (existingBanner.type == BannerType.category ? 'category' : 'home')
        : defaultType;
    String selectedLinkType = existingBanner?.linkType ?? 'product';
    bool isActive = existingBanner?.isActive ?? true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final primaryColor = Theme.of(ctx).colorScheme.primary;
          final currentImageUrl = imageUrlController.text.trim();

          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    existingBanner == null ? Icons.add_photo_alternate_rounded : Icons.edit_note_rounded,
                    color: primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        existingBanner == null ? 'Add New Promotional Banner' : 'Edit Banner Details',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        selectedType == 'home'
                            ? 'Will appear in Mobile App Home Top Carousel'
                            : 'Will appear as a Category / Promo Banner',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 540,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Live Banner Preview Box
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: currentImageUrl.isNotEmpty
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ImagePreview(
                                  url: currentImageUrl,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.65),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.visibility_rounded, size: 12, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text(
                                          'Live Preview',
                                          style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined,
                                      size: 36, color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Paste an image URL below to preview banner',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Banner Title
                    TextField(
                      controller: titleController,
                      style: const TextStyle(fontSize: 13.5),
                      decoration: InputDecoration(
                        labelText: 'Banner Title *',
                        hintText: 'e.g. Fertap Gold / Special Monsoon Offer',
                        isDense: true,
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle / Tagline
                    TextField(
                      controller: subtitleController,
                      style: const TextStyle(fontSize: 13.5),
                      decoration: InputDecoration(
                        labelText: 'Subtitle / Tagline (Optional)',
                        hintText: 'e.g. 100% genuine farm protection products',
                        isDense: true,
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Image URL
                    TextField(
                      controller: imageUrlController,
                      style: const TextStyle(fontSize: 13.5),
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Banner Image URL *',
                        hintText: 'https://storage.googleapis.com/...',
                        prefixIcon: const Icon(Icons.link_rounded, size: 18),
                        suffixIcon: IconButton(
                          tooltip: 'Upload Image to Google Bucket',
                          icon: const Icon(Icons.cloud_upload_outlined, color: Colors.blue),
                          onPressed: () async {
                            final uploadedUrl = await ImageUploadHelper.pickAndUploadImage(
                              context: ctx,
                              folder: 'banners',
                            );
                            if (uploadedUrl != null && ctx.mounted) {
                              setModalState(() {
                                imageUrlController.text = uploadedUrl;
                              });
                            }
                          },
                        ),
                        isDense: true,
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Placement & Link Type
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: selectedType,
                            decoration: InputDecoration(
                              labelText: 'Placement',
                              isDense: true,
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                            items: const [
                              DropdownMenuItem(value: 'home', child: Text('Home Top Carousel', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'category', child: Text('Category Banner', overflow: TextOverflow.ellipsis)),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => selectedType = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: selectedLinkType,
                            decoration: InputDecoration(
                              labelText: 'Target Action',
                              isDense: true,
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                            items: const [
                              DropdownMenuItem(value: 'product', child: Text('Open Product', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'category', child: Text('Open Category', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'collection', child: Text('Open Collection', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'url', child: Text('External Link', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'none', child: Text('No Action', overflow: TextOverflow.ellipsis)),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => selectedLinkType = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Link Target & Priority Order
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: linkValueController,
                            style: const TextStyle(fontSize: 13.5),
                            decoration: InputDecoration(
                              labelText: selectedLinkType == 'product'
                                  ? 'Product ID (e.g. 8063121522841)'
                                  : (selectedLinkType == 'category' ? 'Category Name/Slug' : 'Target Value / Link'),
                              hintText: selectedLinkType == 'product' ? '8063121522841' : 'Insecticides',
                              isDense: true,
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: priorityController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 13.5),
                            decoration: InputDecoration(
                              labelText: 'Slide Order',
                              hintText: '1, 2, 3...',
                              helperText: '1 = First slide',
                              isDense: true,
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Active Switch
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Banner Active Status',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                isActive ? 'Visible to all customers in app' : 'Hidden from customers',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isActive,
                            onChanged: (val) => setModalState(() => isActive = val),
                          ),
                        ],
                      ),
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
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                onPressed: () {
                  final title = titleController.text.trim();
                  final imageUrl = imageUrlController.text.trim();
                  if (title.isEmpty || imageUrl.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please provide both Title and Image URL.')),
                    );
                    return;
                  }

                  final bannerData = {
                    'title': title,
                    'subtitle': subtitleController.text.trim(),
                    'imageUrl': imageUrl,
                    'type': selectedType,
                    'linkType': selectedLinkType,
                    'linkValue': linkValueController.text.trim(),
                    'categorySlug': selectedLinkType == 'category' ? linkValueController.text.trim() : null,
                    'order': int.tryParse(priorityController.text) ?? 1,
                    'isActive': isActive,
                  };

                  if (existingBanner == null) {
                    context.read<BannerBloc>().add(AddBannerEvent(bannerData));
                  } else {
                    context.read<BannerBloc>().add(UpdateBannerEvent(existingBanner.id, bannerData));
                  }
                  Navigator.of(dialogCtx).pop();
                },
                label: Text(existingBanner == null ? 'Create Banner' : 'Save Changes'),
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
        content: Text('Are you sure you want to delete "${banner.title}"? This banner will no longer appear on the app.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              context.read<BannerBloc>().add(DeleteBannerEvent(banner.id));
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete Banner'),
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
        final primaryColor = themeState.currentPalette.primary;

        return BlocBuilder<BannerBloc, BannerState>(
          builder: (context, bannerState) {
            final allBanners = bannerState.banners;
            final homeBanners = allBanners.where((b) => b.type == BannerType.home || b.type == BannerType.hero).toList();
            final activeBanners = allBanners.where((b) => b.isActive).toList();

            // Filter banners based on selection and search
            List<BannerModel> displayedBanners;
            switch (_selectedFilterIndex) {
              case 1:
                displayedBanners = homeBanners;
                break;
              case 2:
                displayedBanners = activeBanners;
                break;
              default:
                displayedBanners = allBanners;
            }

            final searchQuery = _searchController.text.trim().toLowerCase();
            if (searchQuery.isNotEmpty) {
              displayedBanners = displayedBanners.where((b) {
                return b.title.toLowerCase().contains(searchQuery) ||
                    (b.subtitle?.toLowerCase().contains(searchQuery) ?? false) ||
                    (b.linkValue?.toLowerCase().contains(searchQuery) ?? false);
              }).toList();
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(widget.isEmbedded ? 14 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 0. Harmony Purpose Banner
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: isDark ? 0.12 : 0.06),
                      borderRadius: BorderRadius.circular(themeState.borderRadius),
                      border: Border.all(
                        color: const Color(0xFFD97706).withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD97706).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.view_carousel_rounded, size: 18, color: Color(0xFFD97706)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Top Hero Carousel & Promotional Banners',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFD97706)),
                              ),
                              Text(
                                'Powers the top sliding hero banners on mobile app home screen (Recommended: 1080x514 px, 2.1:1 ratio).',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => context.read<BannerBloc>().add(const LoadBanners()),
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Refresh'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showAddEditBannerModal(context, defaultType: 'home'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.add_photo_alternate_rounded, size: 16),
                          label: const Text('Add Home Banner', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Metrics Row ──────────────────────────────────────────
                  Row(
                    children: [
                      _buildMetricCard(
                        title: 'Total Banners',
                        count: '${allBanners.length}',
                        icon: Icons.view_carousel_outlined,
                        color: primaryColor,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        title: 'Home Carousel (App)',
                        count: '${homeBanners.where((b) => b.isActive).length} Active',
                        subtitle: '${homeBanners.length} total slides',
                        icon: Icons.phone_android_rounded,
                        color: const Color(0xFF10B981),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        title: 'Active Banners',
                        count: '${activeBanners.length}',
                        subtitle: 'Currently live in store',
                        icon: Icons.check_circle_outline_rounded,
                        color: const Color(0xFF3B82F6),
                        isDark: isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── Filter Chips & Search Bar ────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? themeState.currentPalette.surfaceDark : themeState.currentPalette.surfaceLight,
                      borderRadius: BorderRadius.circular(themeState.borderRadius),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Filter Pills
                        _buildFilterPill('All Banners (${allBanners.length})', 0, primaryColor, isDark),
                        const SizedBox(width: 8),
                        _buildFilterPill('Home Carousel (${homeBanners.length})', 1, primaryColor, isDark),
                        const SizedBox(width: 8),
                        _buildFilterPill('Active Only (${activeBanners.length})', 2, primaryColor, isDark),

                        const Spacer(),

                        // Search Box
                        SizedBox(
                          width: 240,
                          height: 36,
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 12.5),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search banner...',
                              isDense: true,
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              prefixIcon: const Icon(Icons.search_rounded, size: 16),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Banners Grid / List ──────────────────────────────────────────
                  if (bannerState.isLoading)
                    Shimmer(
                      child: Column(
                        children: List.generate(
                          3,
                          (index) => Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const SkeletonBox(width: 160, height: 90, borderRadius: 8),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        SkeletonBox(width: 200, height: 16, borderRadius: 4),
                                        SizedBox(height: 8),
                                        SkeletonBox(width: 280, height: 12, borderRadius: 3),
                                        SizedBox(height: 12),
                                        SkeletonBadge(width: 90, height: 22),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (displayedBanners.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(48),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_library_outlined, size: 48, color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
                          const SizedBox(height: 12),
                          Text(
                            'No banners found in this category.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _showAddEditBannerModal(context, defaultType: 'home'),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Create Home Banner'),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayedBanners.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final banner = displayedBanners[index];
                        final isHome = banner.type == BannerType.home || banner.type == BannerType.hero;

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(themeState.borderRadius),
                            side: BorderSide(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail with ImagePreview click-to-enlarge
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 170,
                                    height: 95,
                                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                    child: ImagePreview(
                                      url: banner.imageUrl,
                                      width: 170,
                                      height: 95,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 18),

                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          // Interactive Placement Switcher
                                          PopupMenuButton<BannerType>(
                                            tooltip: 'Click to switch placement',
                                            initialValue: banner.type,
                                            offset: const Offset(0, 24),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                            onSelected: (BannerType newType) {
                                              if (newType != banner.type) {
                                                context.read<BannerBloc>().add(
                                                  UpdateBannerEvent(banner.id, {'type': newType == BannerType.home ? 'home' : 'category'}),
                                                );
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Banner moved to ${newType == BannerType.home ? "Home Carousel" : "Category Banners"}'),
                                                    backgroundColor: const Color(0xFF10B981),
                                                    behavior: SnackBarBehavior.floating,
                                                    duration: const Duration(seconds: 2),
                                                  ),
                                                );
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: BannerType.home,
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.phone_android_rounded, size: 16, color: Color(0xFF10B981)),
                                                    SizedBox(width: 8),
                                                    Text('Home Carousel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: BannerType.category,
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.category_outlined, size: 16, color: Color(0xFF3B82F6)),
                                                    SizedBox(width: 8),
                                                    Text('Category Banner', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: isHome
                                                    ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                                    : const Color(0xFF3B82F6).withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    isHome ? Icons.phone_android_rounded : Icons.category_outlined,
                                                    size: 12,
                                                    color: isHome ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    isHome ? 'HOME CAROUSEL' : 'CATEGORY BANNER',
                                                    style: TextStyle(
                                                      fontSize: 10.5,
                                                      fontWeight: FontWeight.w700,
                                                      color: isHome ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Icon(
                                                    Icons.arrow_drop_down,
                                                    size: 14,
                                                    color: isHome ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),

                                          // Slide Order badge
                                          if (banner.priority > 0)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: Text(
                                                'Slide #${banner.priority}',
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                                ),
                                              ),
                                            ),
                                          const SizedBox(width: 8),

                                          // Active Badge
                                          banner.isActive
                                              ? StatusBadge.success('Live')
                                              : StatusBadge.neutral('Inactive'),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Title
                                      Text(
                                        banner.title,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                      ),

                                      // Subtitle
                                      if (banner.subtitle != null && banner.subtitle!.isNotEmpty) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          banner.subtitle!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),

                                      // Target Link
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.touch_app_rounded,
                                            size: 13,
                                            color: primaryColor,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            'Action: ${banner.linkType ?? 'Link'} → ${banner.linkValue ?? banner.categorySlug ?? banner.targetLink ?? 'None'}',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Actions
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
                                      activeTrackColor: primaryColor.withValues(alpha: 0.5),
                                      activeThumbColor: primaryColor,
                                      onChanged: (val) {
                                        context.read<BannerBloc>().add(ToggleBannerStatusEvent(banner.id));
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

  Widget _buildMetricCard({
    required String title,
    required String count,
    String? subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Icon(icon, color: color, size: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, int index, Color primaryColor, bool isDark) {
    final isSelected = _selectedFilterIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedFilterIndex = index),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: isDark ? 0.2 : 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? primaryColor : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? primaryColor
                : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }
}

