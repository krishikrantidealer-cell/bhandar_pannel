import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../logic/products/product_bloc.dart';
import '../../logic/products/product_event.dart';
import '../../logic/products/product_state.dart';
import '../../logic/categories/category_bloc.dart';
import '../../logic/categories/category_state.dart';
import '../../logic/collections/collection_bloc.dart';
import '../../logic/collections/collection_state.dart';
import '../../logic/banners/banner_bloc.dart';
import '../../logic/banners/banner_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_state.dart';
import '../../models/product_model.dart';
import '../widgets/custom_table.dart';
import '../widgets/status_badge.dart';
import '../widgets/image_preview.dart';
import 'categories_view.dart';
import 'collections_view.dart';
import 'banners_view.dart';

class ProductsView extends StatefulWidget {
  final int initialTabIndex;
  const ProductsView({super.key, this.initialTabIndex = 0});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 3),
    );
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showProductDetailsModal(ProductModel product) {
    context.push('/products/${product.id}', extra: product);
  }

  void _showAddEditProductModal({ProductModel? existingProduct}) {
    if (existingProduct == null) {
      context.push('/products/new');
    } else {
      context.push('/products/${existingProduct.id}/edit', extra: existingProduct);
    }
  }

  void _confirmDeleteProduct(ProductModel product) {
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
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTab(
    BuildContext context,
    ThemeState themeState,
    bool isDark,
    ProductState productState,
    CategoryState categoryState,
  ) {
    final products = productState.getFilteredProducts(categoryState.categories);
    final totalItems = products.length;
    final totalPages = (totalItems / _pageSize).ceil().clamp(1, 999999);
    final safeCurrentPage = _currentPage.clamp(1, totalPages);
    final startIndex = (safeCurrentPage - 1) * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, totalItems);
    final pagedProducts = totalItems > 0 ? products.sublist(startIndex, endIndex) : <ProductModel>[];

    // Compute deduplicated categories based on category selection
    final List<String> distinctCategoryNames = [];
    for (final c in categoryState.categories) {
      final n = c.name.trim();
      if (n.isNotEmpty && !distinctCategoryNames.contains(n)) {
        distinctCategoryNames.add(n);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 0. Harmony Purpose Banner
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.12 : 0.06),
              borderRadius: BorderRadius.circular(themeState.borderRadius),
              border: Border.all(
                color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.inventory_2_rounded, size: 18, color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Master Products Catalog',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                      ),
                      Text(
                        'Manage individual items, variant prices, stock & search tags. Assign to Categories & Collections to display in mobile app.',
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
                  onPressed: () => context.read<ProductBloc>().add(const LoadProducts()),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Refresh'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditProductModal(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Product', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),

          // 1. Action & Filter Bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            decoration: BoxDecoration(
              color: isDark ? themeState.currentPalette.surfaceDark : themeState.currentPalette.surfaceLight,
              borderRadius: BorderRadius.circular(themeState.borderRadius),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  // Search
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: 38,
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                        ),
                        onChanged: (val) {
                          setState(() => _currentPage = 1);
                          context.read<ProductBloc>().add(SearchProducts(val));
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by title, SKU or brand...',
                          hintStyle: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                          isDense: true,
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          prefixIcon: const Icon(Icons.search_rounded, size: 18),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _currentPage = 1);
                                    context.read<ProductBloc>().add(const SearchProducts(''));
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Category Filter Dropdown
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 38,
                      child: DropdownButtonFormField<String?>(
                        isExpanded: true,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                        ),
                        initialValue: distinctCategoryNames.contains(productState.selectedCategory)
                            ? productState.selectedCategory
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Category',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Categories', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                          ),
                          ...distinctCategoryNames.map((name) {
                            return DropdownMenuItem(
                              value: name,
                              child: Text(name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setState(() => _currentPage = 1);
                          context.read<ProductBloc>().add(FilterProductsByCategory(val));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Products Data Table
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            decoration: BoxDecoration(
              color: isDark ? themeState.currentPalette.surfaceDark : themeState.currentPalette.surfaceLight,
              borderRadius: BorderRadius.circular(themeState.borderRadius),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Product Catalog ($totalItems Products)',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                        ),
                      ),
                      Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (productState.selectedCategory != null)
                            Chip(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                              label: Text(
                                'Category: ${productState.selectedCategory}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                                ),
                              ),
                              onDeleted: () {
                                setState(() => _currentPage = 1);
                                context.read<ProductBloc>().add(const FilterProductsByCategory(null));
                                context.read<ProductBloc>().add(const FilterProductsBySubCategory(null));
                              },
                            ),
                          if (productState.selectedSubCategory != null)
                            Chip(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                              label: Text(
                                'Sub-Category: ${productState.selectedSubCategory}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                                ),
                              ),
                              onDeleted: () {
                                setState(() => _currentPage = 1);
                                context.read<ProductBloc>().add(const FilterProductsBySubCategory(null));
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CustomTable(
                    minWidth: 880,
                    isLoading: productState.isLoading,
                    loadingRowCount: 8,
                    columns: const [
                      TableColumnDef(label: 'Image', width: 50),
                      TableColumnDef(label: 'Product Title', flex: 3),
                      TableColumnDef(label: 'Category', flex: 2),
                      TableColumnDef(label: 'Price', flex: 2),
                      TableColumnDef(label: 'Variants', flex: 1),
                      TableColumnDef(label: 'Vendor / Brand', flex: 2),
                      TableColumnDef(label: 'Status', flex: 1),
                      TableColumnDef(label: 'Actions', width: 105, alignment: Alignment.centerRight),
                    ],
                    rows: pagedProducts.map((prod) {
                      final categoryName = prod.resolveCategoryName(categoryState.categories);

                      return [
                        // Image (Click to enlarge)
                        ImagePreview(
                          url: prod.images.isNotEmpty ? prod.images.first : null,
                          width: 36,
                          height: 36,
                          borderRadius: 6,
                          enableEnlarge: true,
                          title: prod.title,
                          subtitle: categoryName.isNotEmpty ? categoryName : null,
                          images: prod.images,
                        ),

                        // Title (Clickable)
                        InkWell(
                          onTap: () => _showProductDetailsModal(prod),
                          borderRadius: BorderRadius.circular(4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      prod.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (prod.buy1get1) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(
                                          color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: const Text(
                                        '1+1 Free',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFEF4444),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (prod.sku != null && prod.sku!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 1),
                                  child: Text(
                                    'Option: ${prod.sku!}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Category & Collections
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFF059669).withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.category_rounded, size: 11, color: Color(0xFF059669)),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        categoryName,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF059669),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (prod.assignedCollections.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 2,
                                  children: prod.assignedCollections.take(2).map((col) {
                                    final isSpecial = col.toLowerCase().contains('buy') || col.toLowerCase().contains('crop');
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(
                                          color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                                          width: 0.6,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isSpecial ? Icons.auto_awesome_rounded : Icons.eco_rounded,
                                            size: 9,
                                            color: const Color(0xFF7C3AED),
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            col,
                                            style: const TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF7C3AED),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Price & MRP
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '₹${prod.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                                  ),
                                ),
                                if (prod.mrp > prod.price) ...[
                                  const SizedBox(width: 5),
                                  Text(
                                    '₹${prod.mrp.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      decoration: TextDecoration.lineThrough,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),

                        // Variants Count & Preview
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                prod.variants.length <= 1 ? '1 Variant' : '${prod.variants.length} Variants',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            if (prod.variants.isNotEmpty && prod.variants.first.title != 'Default') ...[
                              const SizedBox(height: 2),
                              Text(
                                prod.variants.map((v) => v.title).take(2).join(', ') +
                                    (prod.variants.length > 2 ? '...' : ''),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),

                        // Vendor / Brand
                        Text(
                          prod.brand,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Status
                        prod.status == 'active'
                            ? StatusBadge.success('Active')
                            : prod.status == 'draft'
                                ? StatusBadge.warning('Draft')
                                : StatusBadge.neutral('Archived'),

                        // Actions
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TableActionButton.view(
                              tooltip: 'View Details',
                              onTap: () => _showProductDetailsModal(prod),
                            ),
                            const SizedBox(width: 5),
                            TableActionButton.edit(
                              tooltip: 'Edit Product',
                              color: themeState.currentPalette.primary,
                              onTap: () => _showAddEditProductModal(existingProduct: prod),
                            ),
                            const SizedBox(width: 5),
                            TableActionButton.delete(
                              tooltip: 'Delete Product',
                              onTap: () => _confirmDeleteProduct(prod),
                            ),
                          ],
                        ),
                      ];
                    }).toList(),
                  ),

                  const SizedBox(height: 10),

                  // Pagination Controls Footer
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.4) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Item counts & Page size selector
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              totalItems == 0
                                  ? 'No products found'
                                  : 'Showing ${startIndex + 1}–$endIndex of $totalItems products',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              'Rows per page:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(width: 6),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _pageSize,
                                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                items: const [
                                  DropdownMenuItem(value: 10, child: Text('10', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 20, child: Text('20', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 50, child: Text('50', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 100, child: Text('100', style: TextStyle(fontSize: 12))),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _pageSize = val;
                                      _currentPage = 1;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        // Right: Page navigation buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.first_page_rounded, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.tightFor(width: 26, height: 26),
                              tooltip: 'First Page',
                              onPressed: safeCurrentPage > 1
                                  ? () => setState(() => _currentPage = 1)
                                  : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_left_rounded, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.tightFor(width: 26, height: 26),
                              tooltip: 'Previous Page',
                              onPressed: safeCurrentPage > 1
                                  ? () => setState(() => _currentPage = safeCurrentPage - 1)
                                  : null,
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: themeState.currentPalette.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Page $safeCurrentPage of $totalPages',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: themeState.currentPalette.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.chevron_right_rounded, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.tightFor(width: 26, height: 26),
                              tooltip: 'Next Page',
                              onPressed: safeCurrentPage < totalPages
                                  ? () => setState(() => _currentPage = safeCurrentPage + 1)
                                  : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.last_page_rounded, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.tightFor(width: 26, height: 26),
                              tooltip: 'Last Page',
                              onPressed: safeCurrentPage < totalPages
                                  ? () => setState(() => _currentPage = totalPages)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String title,
    required int count,
    required bool isSelected,
    required Color primaryColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      hoverColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.14 : 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected
              ? Border.all(color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.25), width: 1)
              : Border.all(color: Colors.transparent, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? primaryColor : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
                color: isSelected
                    ? (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A))
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withValues(alpha: 0.16)
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? primaryColor.withValues(alpha: 0.3)
                      : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                  width: 0.7,
                ),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? primaryColor
                      : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, categoryState) {
            return BlocBuilder<ProductBloc, ProductState>(
              builder: (context, productState) {
                return BlocBuilder<CollectionBloc, CollectionState>(
                  builder: (context, collectionState) {
                    return BlocBuilder<BannerBloc, BannerState>(
                      builder: (context, bannerState) {
                        final productCount = productState.allProducts.length;
                        final categoryCount = categoryState.categories.length;
                        final collectionCount = collectionState.collections.length;
                        final bannerCount = bannerState.banners.length;

                        return Scaffold(
                          backgroundColor: Colors.transparent,
                          body: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Top Sub-Navigation Tab Bar
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildTabItem(
                                        icon: Icons.inventory_2_rounded,
                                        title: 'Products',
                                        count: productCount,
                                        isSelected: _tabController.index == 0,
                                        primaryColor: const Color(0xFF2563EB),
                                        isDark: isDark,
                                        onTap: () => _tabController.animateTo(0),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildTabItem(
                                        icon: Icons.category_rounded,
                                        title: 'Categories',
                                        count: categoryCount,
                                        isSelected: _tabController.index == 1,
                                        primaryColor: const Color(0xFF059669),
                                        isDark: isDark,
                                        onTap: () => _tabController.animateTo(1),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildTabItem(
                                        icon: Icons.collections_bookmark_rounded,
                                        title: 'Collections & Crops',
                                        count: collectionCount,
                                        isSelected: _tabController.index == 2,
                                        primaryColor: const Color(0xFF7C3AED),
                                        isDark: isDark,
                                        onTap: () => _tabController.animateTo(2),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildTabItem(
                                        icon: Icons.view_carousel_rounded,
                                        title: 'Banners & Promotions',
                                        count: bannerCount,
                                        isSelected: _tabController.index == 3,
                                        primaryColor: const Color(0xFFD97706),
                                        isDark: isDark,
                                        onTap: () => _tabController.animateTo(3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Tab Views Content
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    // 1. Products Tab
                                    _buildProductTab(
                                      context,
                                      themeState,
                                      isDark,
                                      productState,
                                      categoryState,
                                    ),

                                    // 2. Categories Tab
                                    const CategoriesView(isEmbedded: true),

                                    // 3. Collection Tab
                                    const CollectionsView(isEmbedded: true),

                                    // 4. Banners Tab
                                    const BannersView(isEmbedded: true),
                                  ],
                                ),
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
      },
    );
  }
}
