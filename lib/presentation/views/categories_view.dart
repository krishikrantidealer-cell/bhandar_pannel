import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/categories/category_bloc.dart';
import '../../logic/categories/category_event.dart';
import '../../logic/categories/category_state.dart';
import '../../logic/products/product_bloc.dart';
import '../../logic/products/product_event.dart';
import '../../logic/products/product_state.dart';
import '../../models/product_model.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_state.dart';
import '../../logic/banners/banner_bloc.dart';
import '../../logic/banners/banner_state.dart';
import '../../models/category_model.dart';
import '../../core/utils/image_upload_helper.dart';
import '../widgets/image_preview.dart';
import '../widgets/shimmer_loading.dart';

class CategoriesView extends StatefulWidget {
  final bool isEmbedded;
  const CategoriesView({super.key, this.isEmbedded = false});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  void _showAddEditCategoryModal({CategoryModel? existingCategory}) {
    final nameController = TextEditingController(text: existingCategory?.name ?? '');
    final slugController = TextEditingController(text: existingCategory?.slug ?? '');
    final titleController = TextEditingController(text: existingCategory?.title ?? '');
    final descController = TextEditingController(text: existingCategory?.description ?? '');
    final bannerController = TextEditingController(text: existingCategory?.bannerImage ?? '');
    final stripController = TextEditingController(text: existingCategory?.stripBanner ?? '');
    final pdfController = TextEditingController(text: existingCategory?.cataloguePdf ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final isDark = Theme.of(modalCtx).brightness == Brightness.dark;
          final primaryColor = Theme.of(modalCtx).colorScheme.primary;
          final bannerUrl = bannerController.text.trim();
          final stripUrl = stripController.text.trim();

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
                    existingCategory == null ? Icons.category_rounded : Icons.edit_note_rounded,
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
                        existingCategory == null ? 'Add New Category' : 'Edit Category',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Update category images, strip banner, and catalogue',
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
              width: 580,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Live Banner Previews Row
                    Row(
                      children: [
                        // Category Main Banner Preview
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Main Image Preview',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Container(
                                height: 110,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: bannerUrl.isNotEmpty
                                    ? ImagePreview(
                                        url: bannerUrl,
                                        width: double.infinity,
                                        height: 110,
                                        fit: BoxFit.cover,
                                        enableEnlarge: true,
                                      )
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.image_outlined,
                                                size: 28,
                                                color: isDark
                                                    ? const Color(0xFF475569)
                                                    : const Color(0xFF94A3B8)),
                                            const SizedBox(height: 4),
                                            Text(
                                              'No Main Image',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark
                                                    ? const Color(0xFF64748B)
                                                    : const Color(0xFF94A3B8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Strip Banner Preview
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Strip Banner Preview',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Container(
                                height: 110,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: stripUrl.isNotEmpty
                                    ? ImagePreview(
                                        url: stripUrl,
                                        width: double.infinity,
                                        height: 110,
                                        fit: BoxFit.cover,
                                        enableEnlarge: true,
                                      )
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.view_stream_outlined,
                                                size: 28,
                                                color: isDark
                                                    ? const Color(0xFF475569)
                                                    : const Color(0xFF94A3B8)),
                                            const SizedBox(height: 4),
                                            Text(
                                              'No Strip Banner',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark
                                                    ? const Color(0xFF64748B)
                                                    : const Color(0xFF94A3B8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: nameController,
                            style: const TextStyle(fontSize: 13.5),
                            decoration: InputDecoration(
                              labelText: 'Category Name *',
                              hintText: 'e.g. Fungicides',
                              isDense: true,
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onChanged: (val) {
                              if (existingCategory == null) {
                                slugController.text = val
                                    .toLowerCase()
                                    .replaceAll(' ', '-')
                                    .replaceAll(RegExp(r'[^a-z0-9\-]'), '');
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: slugController,
                            style: const TextStyle(fontSize: 13.5),
                            decoration: InputDecoration(
                              labelText: 'Slug / Key *',
                              hintText: 'fungicides',
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

                    TextField(
                      controller: bannerController,
                      style: const TextStyle(fontSize: 13.5),
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Main Category Image URL (Google Bucket)',
                        hintText: 'https://storage.googleapis.com/... or paste image URL',
                        prefixIcon: const Icon(Icons.image_outlined, size: 18),
                        suffixIcon: IconButton(
                          tooltip: 'Upload image to Krishi Bhandar Google Bucket',
                          icon: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF3B82F6), size: 20),
                          onPressed: () async {
                            final url = await ImageUploadHelper.pickAndUploadImage(
                              context: modalCtx,
                              folder: 'categories',
                            );
                            if (url != null) {
                              setModalState(() {
                                bannerController.text = url;
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

                    TextField(
                      controller: stripController,
                      style: const TextStyle(fontSize: 13.5),
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Strip Banner URL (Google Bucket)',
                        hintText: 'https://storage.googleapis.com/... or paste strip image URL',
                        prefixIcon: const Icon(Icons.view_stream_outlined, size: 18),
                        suffixIcon: IconButton(
                          tooltip: 'Upload strip banner to Krishi Bhandar Google Bucket',
                          icon: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF3B82F6), size: 20),
                          onPressed: () async {
                            final url = await ImageUploadHelper.pickAndUploadImage(
                              context: modalCtx,
                              folder: 'strip_banners',
                            );
                            if (url != null) {
                              setModalState(() {
                                stripController.text = url;
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

                    TextField(
                      controller: titleController,
                      style: const TextStyle(fontSize: 13.5),
                      decoration: InputDecoration(
                        labelText: 'Banner / Header Title (Optional)',
                        hintText: 'Crop Disease Protection Solutions',
                        isDense: true,
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: pdfController,
                      style: const TextStyle(fontSize: 13.5),
                      decoration: InputDecoration(
                        labelText: 'Catalogue PDF URL (Optional)',
                        hintText: 'https://storage.googleapis.com/...',
                        prefixIcon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                        isDense: true,
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: descController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13.5),
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        isDense: true,
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                onPressed: () {
                  final name = nameController.text.trim();
                  final slug = slugController.text.trim();
                  if (name.isEmpty) return;

                  if (existingCategory == null) {
                    final newCat = CategoryModel(
                      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      slug: slug.isNotEmpty ? slug : name.toLowerCase(),
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      bannerImage: bannerController.text.trim(),
                      stripBanner: stripController.text.trim(),
                      cataloguePdf: pdfController.text.trim(),
                    );
                    context.read<CategoryBloc>().add(AddCategoryEvent(newCat));
                  } else {
                    final updated = existingCategory.copyWith(
                      name: name,
                      slug: slug,
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      bannerImage: bannerController.text.trim(),
                      stripBanner: stripController.text.trim(),
                      cataloguePdf: pdfController.text.trim(),
                    );
                    context.read<CategoryBloc>().add(UpdateCategoryEvent(updated));
                  }
                  Navigator.of(ctx).pop();
                },
                label: Text(existingCategory == null ? 'Create Category' : 'Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }


  void _showManageCategoryProductsDialog({
    required BuildContext parentContext,
    required CategoryModel category,
  }) {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return BlocBuilder<ProductBloc, ProductState>(
          builder: (ctx, productState) {
            final allProducts = productState.allProducts;
            return _CategoryProductSelectionDialog(
              category: category,
              allProducts: allProducts,
              onSave: (selectedIds) {
                for (final p in allProducts) {
                  final isSelected = selectedIds.contains(p.id);
                  final isCurrentlyInCat = p.category == category.id ||
                      p.category.trim().toLowerCase() == category.name.trim().toLowerCase() ||
                      p.category.trim().toLowerCase() == category.slug.trim().toLowerCase() ||
                      p.categoryIds.contains(category.id);

                  if (isSelected && !isCurrentlyInCat) {
                    final updated = p.copyWith(
                      category: category.id,
                      categoryId: category.id,
                      categoryIds: p.categoryIds.contains(category.id) ? p.categoryIds : [...p.categoryIds, category.id],
                    );
                    parentContext.read<ProductBloc>().add(UpdateProductEvent(updated));
                  } else if (!isSelected && isCurrentlyInCat) {
                    final newCategoryIds = p.categoryIds.where((id) => id != category.id).toList();
                    final updated = p.copyWith(
                      category: '',
                      categoryId: null,
                      categoryIds: newCategoryIds,
                    );
                    parentContext.read<ProductBloc>().add(UpdateProductEvent(updated));
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  void _confirmDeleteCategory(CategoryModel cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text('Are you sure you want to delete "${cat.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              context.read<CategoryBloc>().add(DeleteCategoryEvent(cat.id));
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
            return BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, categoryState) {
                return BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, productState) {
                    final categories = categoryState.categories;

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(widget.isEmbedded ? 16 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 0. Harmony Purpose Banner
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF059669).withValues(alpha: isDark ? 0.12 : 0.06),
                              borderRadius: BorderRadius.circular(themeState.borderRadius),
                              border: Border.all(
                                color: const Color(0xFF059669).withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF059669).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.category_rounded, size: 18, color: Color(0xFF059669)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Store Taxonomies & Categories',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF059669)),
                                      ),
                                      Text(
                                        'Powers circular category strip and drawer filters in mobile app. Upload a Strip Banner to feature a home screen shelf.',
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
                                  onPressed: () => context.read<CategoryBloc>().add(const LoadCategories()),
                                  icon: const Icon(Icons.refresh_rounded, size: 16),
                                  label: const Text('Refresh'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _showAddEditCategoryModal(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF059669),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.add_rounded, size: 16),
                                  label: const Text('Add Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'All Categories (${categories.length})',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Click any category card to edit images & catalogue',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                      // Categories Grid
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final double width = constraints.maxWidth;
                          int crossAxisCount = 4;
                          if (width < 600) {
                            crossAxisCount = 1;
                          } else if (width < 900) {
                            crossAxisCount = 2;
                          } else if (width < 1250) {
                            crossAxisCount = 3;
                          }

                          final itemWidth = (width - ((crossAxisCount - 1) * 14)) / crossAxisCount;

                          if (categoryState.isLoading) {
                            return Wrap(
                              spacing: 14,
                              runSpacing: 14,
                              children: List.generate(
                                8,
                                (index) => SizedBox(
                                  width: itemWidth,
                                  child: CategoryCardSkeleton(borderRadius: themeState.borderRadius),
                                ),
                              ),
                            );
                          }

                          return Wrap(
                            spacing: 14,
                            runSpacing: 14,
                            children: categories.map((cat) {
                              // Dynamic real-time product count calculation
                              final matchedProductsCount = productState.allProducts.where((p) {
                                final pCat = p.category.trim().toLowerCase();
                                final cName = cat.name.trim().toLowerCase();
                                final cSlug = cat.slug.trim().toLowerCase();
                                final hasId = p.categoryIds.contains(cat.id) || p.categoryId == cat.id;
                                return pCat == cName || pCat == cSlug || hasId;
                              }).length;

                              final displayCount = matchedProductsCount > 0
                                  ? matchedProductsCount
                                  : (cat.productsCount > 0 ? cat.productsCount : 0);

                              return SizedBox(
                                width: itemWidth,
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Category Banner Image
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(themeState.borderRadius),
                                            ),
                                            child: ImagePreview(
                                              url: cat.bannerImage,
                                              width: double.infinity,
                                              height: 105,
                                              borderRadius: 0,
                                              enableEnlarge: true,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF059669).withValues(alpha: 0.9),
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: IconButton(
                                                    icon: const Icon(Icons.playlist_add_check_circle_rounded, size: 14, color: Colors.white),
                                                    padding: const EdgeInsets.all(6),
                                                    constraints: const BoxConstraints(),
                                                    onPressed: () => _showManageCategoryProductsDialog(
                                                      parentContext: context,
                                                      category: cat,
                                                    ),
                                                    tooltip: 'Manage Category Products',
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withValues(alpha: 0.6),
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: IconButton(
                                                    icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                                                    padding: const EdgeInsets.all(6),
                                                    constraints: const BoxConstraints(),
                                                    onPressed: () =>
                                                        _showAddEditCategoryModal(existingCategory: cat),
                                                    tooltip: 'Edit Category',
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withValues(alpha: 0.6),
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: IconButton(
                                                    icon: const Icon(Icons.delete_outline,
                                                        size: 14, color: Colors.redAccent),
                                                    padding: const EdgeInsets.all(6),
                                                    constraints: const BoxConstraints(),
                                                    onPressed: () => _confirmDeleteCategory(cat),
                                                    tooltip: 'Delete Category',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    cat.name,
                                                    style: theme.textTheme.titleSmall?.copyWith(
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: themeState.currentPalette.primary
                                                        .withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    '/${cat.slug}',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                      color: themeState.currentPalette.primary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            // Dynamic Product Count Badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.inventory_2_outlined, size: 11, color: Color(0xFF10B981)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '$displayCount Products',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w700,
                                                      color: Color(0xFF10B981),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (cat.description != null && cat.description!.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                cat.description!,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark
                                                      ? const Color(0xFFCBD5E1)
                                                      : const Color(0xFF64748B),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                            if (cat.stripBanner != null && cat.stripBanner!.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Container(
                                                height: 36,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                                  ),
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: ImagePreview(
                                                  url: cat.stripBanner,
                                                  width: double.infinity,
                                                  height: 36,
                                                  fit: BoxFit.cover,
                                                  enableEnlarge: true,
                                                ),
                                              ),
                                            ],
                                            if (cat.cataloguePdf != null && cat.cataloguePdf!.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: themeState.currentPalette.primary.withValues(alpha: 0.08),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: themeState.currentPalette.primary.withValues(alpha: 0.25),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.picture_as_pdf_rounded,
                                                        size: 12, color: themeState.currentPalette.primary),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Catalogue PDF',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                        color: themeState.currentPalette.primary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
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
      },
    );
  },
);
  }
}

class _CategoryProductSelectionDialog extends StatefulWidget {
  final CategoryModel category;
  final List<ProductModel> allProducts;
  final void Function(Set<String> selectedProductIds) onSave;

  const _CategoryProductSelectionDialog({
    required this.category,
    required this.allProducts,
    required this.onSave,
  });

  @override
  State<_CategoryProductSelectionDialog> createState() => _CategoryProductSelectionDialogState();
}

class _CategoryProductSelectionDialogState extends State<_CategoryProductSelectionDialog> {
  late Set<String> _selectedProductIds;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedProductIds = {};
    for (final p in widget.allProducts) {
      final isAssigned = p.category == widget.category.id ||
          p.category.trim().toLowerCase() == widget.category.name.trim().toLowerCase() ||
          p.category.trim().toLowerCase() == widget.category.slug.trim().toLowerCase() ||
          p.categoryIds.contains(widget.category.id);
      if (isAssigned) {
        _selectedProductIds.add(p.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF059669);

    final filteredProducts = widget.allProducts.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.title.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();

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
              Icons.playlist_add_check_circle_rounded,
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
                  'Manage Products: ${widget.category.name}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${_selectedProductIds.length} of ${widget.allProducts.length} products assigned',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 650,
        height: 480,
        child: Column(
          children: [
            // Search & Quick Select Row
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search products by name, brand, or tag...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 18),
                        isDense: true,
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedProductIds.length == widget.allProducts.length) {
                        _selectedProductIds.clear();
                      } else {
                        _selectedProductIds = widget.allProducts.map((p) => p.id).toSet();
                      }
                    });
                  },
                  child: Text(
                    _selectedProductIds.length == widget.allProducts.length ? 'Deselect All' : 'Select All',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Product List
            Expanded(
              child: filteredProducts.isEmpty
                  ? Center(
                      child: Text(
                        'No matching products found.',
                        style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: ListView.separated(
                        itemCount: filteredProducts.length,
                        separatorBuilder: (ctx, idx) => Divider(
                          height: 1,
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        ),
                        itemBuilder: (ctx, idx) {
                          final prod = filteredProducts[idx];
                          final isChecked = _selectedProductIds.contains(prod.id);

                          return CheckboxListTile(
                            value: isChecked,
                            activeColor: primaryColor,
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedProductIds.add(prod.id);
                                } else {
                                  _selectedProductIds.remove(prod.id);
                                }
                              });
                            },
                            secondary: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: prod.images.isNotEmpty
                                  ? ImagePreview(url: prod.images.first, fit: BoxFit.cover)
                                  : Icon(Icons.image_not_supported_outlined, size: 16, color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
                            ),
                            title: Text(
                              prod.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isChecked ? FontWeight.w700 : FontWeight.w500,
                                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${prod.brand} • ₹${prod.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.check_rounded, size: 18),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            widget.onSave(_selectedProductIds);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Updated products for category "${widget.category.name}"'),
                backgroundColor: primaryColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          label: const Text('Save Assigned Products'),
        ),
      ],
    );
  }
}


