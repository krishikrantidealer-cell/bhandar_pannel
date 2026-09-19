import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/formatters.dart';
import '../../logic/products/product_bloc.dart';
import '../../logic/products/product_event.dart';
import '../../logic/products/product_state.dart';
import '../../logic/categories/category_bloc.dart';
import '../../logic/categories/category_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_state.dart';
import '../../models/product_model.dart';
import '../widgets/custom_table.dart';
import '../widgets/status_badge.dart';
import '../widgets/image_preview.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditProductModal({ProductModel? existingProduct}) {
    final catState = context.read<CategoryBloc>().state;
    final titleController = TextEditingController(text: existingProduct?.title ?? '');
    final descController = TextEditingController(text: existingProduct?.description ?? '');
    final priceController = TextEditingController(
        text: existingProduct != null ? existingProduct.price.toStringAsFixed(0) : '');
    final mrpController = TextEditingController(
        text: existingProduct != null ? existingProduct.mrp.toStringAsFixed(0) : '');
    final stockController = TextEditingController(
        text: existingProduct != null ? existingProduct.stock.toString() : '50');
    final imageController = TextEditingController(
        text: existingProduct?.images.isNotEmpty == true ? existingProduct!.images.first : '');

    String selectedCategory = existingProduct?.category ??
        (catState.categories.isNotEmpty ? catState.categories.first.name : 'Insecticides');

    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(existingProduct == null ? 'Add New Product' : 'Edit Product'),
              content: SizedBox(
                width: 550,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Product Title *',
                          hintText: 'e.g. Bhandar Chlorpyrifos 50% EC',
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(labelText: 'Category *'),
                        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        items: catState.categories.map((c) {
                          return DropdownMenuItem(value: c.name, child: Text(c.name));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedCategory = val);
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Selling Price (₹) *',
                                prefixText: '₹ ',
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: mrpController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'MRP Price (₹) *',
                                prefixText: '₹ ',
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: stockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Stock Quantity *',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: imageController,
                        decoration: const InputDecoration(
                          labelText: 'Product Image URL',
                          hintText: 'https://storage.googleapis.com/...',
                          prefixIcon: Icon(Icons.link_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description / Usage Instructions',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final price = double.tryParse(priceController.text) ?? 0.0;
                    final mrp = double.tryParse(mrpController.text) ?? price;
                    final stock = int.tryParse(stockController.text) ?? 0;
                    final img = imageController.text.trim();

                    if (title.isEmpty) return;

                    if (existingProduct == null) {
                      final newProduct = ProductModel(
                        id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
                        title: title,
                        category: selectedCategory,
                        price: price,
                        mrp: mrp,
                        stock: stock,
                        inStock: stock > 0,
                        description: descController.text.trim(),
                        images: img.isNotEmpty ? [img] : [],
                      );
                      context.read<ProductBloc>().add(AddProductEvent(newProduct));
                    } else {
                      final updated = existingProduct.copyWith(
                        title: title,
                        category: selectedCategory,
                        price: price,
                        mrp: mrp,
                        stock: stock,
                        inStock: stock > 0,
                        description: descController.text.trim(),
                        images: img.isNotEmpty ? [img] : existingProduct.images,
                      );
                      context.read<ProductBloc>().add(UpdateProductEvent(updated));
                    }
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(existingProduct == null ? 'Create Product' : 'Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
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
                final products = productState.filteredProducts;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Action Bar
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) =>
                                      context.read<ProductBloc>().add(SearchProducts(val)),
                                  decoration: InputDecoration(
                                    hintText: 'Search products by title or active ingredient...',
                                    prefixIcon: const Icon(Icons.search_rounded),
                                    suffixIcon: _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear_rounded),
                                            onPressed: () {
                                              _searchController.clear();
                                              context.read<ProductBloc>().add(const SearchProducts(''));
                                            },
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String?>(
                                  initialValue: productState.selectedCategory,
                                  decoration: const InputDecoration(
                                    labelText: 'Filter by Category',
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  items: [
                                    const DropdownMenuItem(value: null, child: Text('All Categories')),
                                    ...categoryState.categories.map((c) {
                                      return DropdownMenuItem(value: c.name, child: Text(c.name));
                                    }),
                                  ],
                                  onChanged: (val) => context
                                      .read<ProductBloc>()
                                      .add(FilterProductsByCategory(val)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: () => _showAddEditProductModal(),
                                icon: const Icon(Icons.add_rounded, size: 20),
                                label: const Text('Add Product'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Products Data Table
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Catalog Inventory (${products.length} Items)',
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  if (productState.selectedCategory != null)
                                    Chip(
                                      label: Text('Filter: ${productState.selectedCategory}'),
                                      onDeleted: () => context
                                          .read<ProductBloc>()
                                          .add(const FilterProductsByCategory(null)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              CustomTable(
                                minWidth: 850,
                                columns: const [
                                  TableColumnDef(label: 'Image', width: 64),
                                  TableColumnDef(label: 'Product Title', flex: 3),
                                  TableColumnDef(label: 'Category', flex: 2),
                                  TableColumnDef(label: 'Price (MRP)', flex: 2),
                                  TableColumnDef(label: 'Stock Status', flex: 2),
                                  TableColumnDef(
                                      label: 'Actions', width: 110, alignment: Alignment.centerRight),
                                ],
                                rows: products.map((prod) {
                                  final hasDiscount = prod.discountPercent > 0;
                                  final isLowStock = prod.stock < 25;

                                  return [
                                    // Image
                                    ImagePreview(
                                      url: prod.images.isNotEmpty ? prod.images.first : null,
                                      width: 44,
                                      height: 44,
                                      borderRadius: themeState.borderRadius * 0.6,
                                    ),

                                    // Title
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          prod.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600, fontSize: 13.5),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (prod.subCategory != null)
                                          Text(
                                            prod.subCategory!,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF64748B),
                                            ),
                                          ),
                                      ],
                                    ),

                                    // Category
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            themeState.currentPalette.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        prod.category,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: themeState.currentPalette.primary,
                                        ),
                                      ),
                                    ),

                                    // Price
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          AppFormatters.formatCurrency(prod.price),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700, fontSize: 13.5),
                                        ),
                                        if (hasDiscount)
                                          Text(
                                            AppFormatters.formatCurrency(prod.mrp),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark
                                                  ? const Color(0xFF64748B)
                                                  : const Color(0xFF94A3B8),
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                      ],
                                    ),

                                    // Stock
                                    isLowStock
                                        ? StatusBadge.warning('${prod.stock} left (Low)')
                                        : StatusBadge.success('${prod.stock} in stock'),

                                    // Actions
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18),
                                          tooltip: 'Edit Product',
                                          onPressed: () =>
                                              _showAddEditProductModal(existingProduct: prod),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded,
                                              size: 18, color: Color(0xFFEF4444)),
                                          tooltip: 'Delete Product',
                                          onPressed: () => _confirmDeleteProduct(prod),
                                        ),
                                      ],
                                    ),
                                  ];
                                }).toList(),
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
          },
        );
      },
    );
  }
}
