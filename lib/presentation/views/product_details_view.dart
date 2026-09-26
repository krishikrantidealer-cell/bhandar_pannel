import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../logic/categories/category_bloc.dart';
import '../../logic/categories/category_state.dart';
import '../../logic/products/product_bloc.dart';
import '../../logic/products/product_event.dart';
import '../../logic/products/product_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_state.dart';
import '../../models/product_model.dart';
import '../widgets/image_preview.dart';
import '../widgets/status_badge.dart';

class ProductDetailsView extends StatefulWidget {
  final String productId;
  final ProductModel? initialProduct;

  const ProductDetailsView({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    final productState = context.read<ProductBloc>().state;
    if (productState.products.isEmpty && !productState.isLoading) {
      context.read<ProductBloc>().add(const LoadProducts());
    }
  }

  void _confirmDelete(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete "${product.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              context.read<ProductBloc>().add(DeleteProductEvent(product.id));
              Navigator.of(ctx).pop();
              context.go('/products');
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
    final isMobile = ResponsiveLayout.isMobile(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, productState) {
            return BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, categoryState) {
                final product = productState.products
                        .where((p) => p.id == widget.productId)
                        .firstOrNull ??
                    widget.initialProduct;

                if (product == null) {
                  if (productState.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themeState.currentPalette.primary),
                      ),
                    );
                  }
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 54, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        Text(
                          'Product Not Found',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No product matches ID "${widget.productId}".',
                          style: const TextStyle(color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/products'),
                          icon: const Icon(Icons.arrow_back_rounded, size: 16),
                          label: const Text('Return to Products Catalog'),
                        ),
                      ],
                    ),
                  );
                }

                final categoryName = product.resolveCategoryName(categoryState.categories);
                final allCategoryNames = product.resolveAllCategoryNames(categoryState.categories);
                final allImages = product.images.isNotEmpty
                    ? product.images
                    : ['https://placehold.co/600x600/png?text=Krishi+Bhandar'];

                final currentImageUrl = _selectedImageIndex < allImages.length
                    ? allImages[_selectedImageIndex]
                    : allImages.first;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Navigation Breadcrumb & Actions Bar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOutCubic,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? themeState.currentPalette.surfaceDark : themeState.currentPalette.surfaceLight,
                          borderRadius: BorderRadius.circular(themeState.borderRadius),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Breadcrumb & Back Button
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => context.go('/products'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  icon: const Icon(Icons.arrow_back_rounded, size: 15),
                                  label: const Text('Products', style: TextStyle(fontSize: 12)),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    product.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            // Action Buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Tooltip(
                                  message: 'Copy MongoDB Object ID',
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: product.id));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Copied Product ID: ${product.id}'),
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                    icon: const Icon(Icons.copy_rounded, size: 14),
                                    label: const Text('Copy ID', style: TextStyle(fontSize: 11.5)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => context.push('/products/${product.id}/edit', extra: product),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: themeState.currentPalette.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  icon: const Icon(Icons.edit_rounded, size: 15, color: Colors.white),
                                  label: const Text(
                                    'Edit Product',
                                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _confirmDelete(context, product),
                                  tooltip: 'Delete Product',
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                                  style: IconButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      side: BorderSide(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Two-Column Main Content
                      if (!isMobile)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column: Media Gallery & Metadata
                            Expanded(
                              flex: 5,
                              child: _buildLeftColumn(
                                product,
                                allImages,
                                currentImageUrl,
                                categoryName,
                                allCategoryNames,
                                themeState,
                                isDark,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Right Column: Pricing, Inventory, & Variants Table
                            Expanded(
                              flex: 6,
                              child: _buildRightColumn(product, themeState, isDark),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLeftColumn(
                              product,
                              allImages,
                              currentImageUrl,
                              categoryName,
                              allCategoryNames,
                              themeState,
                              isDark,
                            ),
                            const SizedBox(height: 16),
                            _buildRightColumn(product, themeState, isDark),
                          ],
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
  }

  Widget _buildLeftColumn(
    ProductModel product,
    List<String> allImages,
    String currentImageUrl,
    String categoryName,
    List<String> allCategoryNames,
    ThemeState themeState,
    bool isDark,
  ) {
    return Column(
      children: [
        // Gallery Preview Card
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? themeState.currentPalette.surfaceDark : themeState.currentPalette.surfaceLight,
            borderRadius: BorderRadius.circular(themeState.borderRadius),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRODUCT MEDIA GALLERY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              // Main High-Res Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 300,
                  width: double.infinity,
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  child: ImagePreview(
                    url: currentImageUrl,
                    fit: BoxFit.contain,
                    enableEnlarge: true,
                    title: product.title,
                    subtitle: categoryName.isNotEmpty ? categoryName : null,
                    images: allImages,
                  ),
                ),
              ),
              if (allImages.length > 1) ...[
                const SizedBox(height: 12),
                Text(
                  'Images (${allImages.length} available)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: allImages.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final isSelected = idx == _selectedImageIndex;
                      return InkWell(
                        onTap: () => setState(() => _selectedImageIndex = idx),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? themeState.currentPalette.primary
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: ImagePreview(url: allImages[idx], fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Product Details & Taxonomy Card
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? themeState.currentPalette.surfaceDark : themeState.currentPalette.surfaceLight,
            borderRadius: BorderRadius.circular(themeState.borderRadius),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SPECIFICATIONS & TAXONOMY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              _buildMetaRow('Primary Category', categoryName, isDark, isPrimary: true, color: themeState.currentPalette.primary),
              if (allCategoryNames.length > 1) ...[
                const SizedBox(height: 6),
                Text('All Assigned Categories:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569))),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: allCategoryNames.map((cat) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: themeState.currentPalette.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: themeState.currentPalette.primary.withValues(alpha: 0.3), width: 0.8),
                    ),
                    child: Text(cat, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: themeState.currentPalette.primary)),
                  )).toList(),
                ),
                const SizedBox(height: 8),
              ],
              _buildMetaRow('Brand / Vendor', product.brand, isDark),
              _buildMetaRow('Status', product.status.toUpperCase(), isDark, isBadge: true, badge: product.status == 'active' ? StatusBadge.success('Active') : product.status == 'draft' ? StatusBadge.warning('Draft') : StatusBadge.neutral('Archived')),
              if (product.buy1get1)
                _buildMetaRow('Promotion', 'Buy 1 Get 1 Free (1+1 Active)', isDark, isPrimary: true, color: const Color(0xFFEF4444)),

              // Assigned Collections
              if (product.assignedCollections.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.collections_bookmark_rounded, size: 14, color: themeState.currentPalette.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Assigned Collections & Crops (${product.assignedCollections.length}):',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: product.assignedCollections.map((col) {
                    final isDealOrSpecial = col.toLowerCase().contains('buy') || col.toLowerCase().contains('crop') || col.toLowerCase().contains('offer');
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDealOrSpecial
                            ? const Color(0xFF8B5CF6).withValues(alpha: 0.12)
                            : const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDealOrSpecial
                              ? const Color(0xFF8B5CF6).withValues(alpha: 0.35)
                              : const Color(0xFF10B981).withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDealOrSpecial ? Icons.auto_awesome_rounded : Icons.eco_rounded,
                            size: 12,
                            color: isDealOrSpecial ? const Color(0xFF8B5CF6) : const Color(0xFF10B981),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            col,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDealOrSpecial ? const Color(0xFF8B5CF6) : const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],

              if (product.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text('Search Tags:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569))),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: product.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 0.8),
                    ),
                    child: Text('#$tag', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155))),
                  )).toList(),
                ),
              ],
              if (product.description != null && product.description!.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A))),
                const SizedBox(height: 6),
                Text(
                  product.description!,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn(
    ProductModel product,
    ThemeState themeState,
    bool isDark,
  ) {
    final discountPercent = product.mrp > product.price
        ? (((product.mrp - product.price) / product.mrp) * 100).round()
        : 0;

    return Column(
      children: [
        // Pricing Summary Card
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? themeState.currentPalette.surfaceDark : themeState.currentPalette.surfaceLight,
            borderRadius: BorderRadius.circular(themeState.borderRadius),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRICING & REVENUE OVERVIEW',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: themeState.currentPalette.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: themeState.currentPalette.primary.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selling Price', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: themeState.currentPalette.primary)),
                          const SizedBox(height: 4),
                          Text(
                            AppFormatters.formatCurrency(product.price),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: themeState.currentPalette.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Maximum Retail Price (MRP)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                          const SizedBox(height: 4),
                          Text(
                            AppFormatters.formatCurrency(product.mrp),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.lineThrough,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (discountPercent > 0) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Discount / Margin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
                            const SizedBox(height: 4),
                            Text(
                              '$discountPercent% OFF',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Variants Matrix Table Card
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? themeState.currentPalette.surfaceDark : themeState.currentPalette.surfaceLight,
            borderRadius: BorderRadius.circular(themeState.borderRadius),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'VARIANT MATRIX (${product.variants.length} options)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1), width: 0.8),
                    ),
                    child: Text(
                      '${product.variants.length} Variants',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        child: Row(
                          children: const [
                            Expanded(flex: 3, child: Text('VARIANT OPTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)))),
                            Expanded(flex: 2, child: Text('SKU CODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)))),
                            Expanded(flex: 2, child: Text('PRICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)))),
                            Expanded(flex: 2, child: Text('MRP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)))),
                          ],
                        ),
                      ),
                      // Variant Rows
                      ...product.variants.asMap().entries.map((entry) {
                        final v = entry.value;
                        final isEven = entry.key % 2 == 0;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isEven
                                ? Colors.transparent
                                : (isDark ? const Color(0xFF0F172A).withValues(alpha: 0.3) : const Color(0xFFF8FAFC)),
                            border: Border(
                              bottom: BorderSide(
                                color: isDark ? const Color(0xFF334155).withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
                                width: 0.8,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  v.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  (v.sku != null && v.sku!.isNotEmpty) ? v.sku! : 'N/A',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  AppFormatters.formatCurrency(v.price),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: themeState.currentPalette.primary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  AppFormatters.formatCurrency(v.mrp),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.lineThrough,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(String label, String value, bool isDark, {bool isPrimary = false, Color? color, bool isBadge = false, Widget? badge}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          if (isBadge && badge != null)
            badge
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w700,
                color: color ?? (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)),
              ),
            ),
        ],
      ),
    );
  }
}
