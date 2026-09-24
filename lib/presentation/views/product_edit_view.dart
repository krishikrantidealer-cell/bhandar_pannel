import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/responsive.dart';
import '../../logic/categories/category_bloc.dart';
import '../../logic/categories/category_state.dart';
import '../../logic/products/product_bloc.dart';
import '../../logic/products/product_event.dart';
import '../../logic/products/product_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_state.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../widgets/image_preview.dart';

class _VariantEditRow {
  final TextEditingController title;
  final TextEditingController sku;
  final TextEditingController price;
  final TextEditingController mrp;

  _VariantEditRow({
    required this.title,
    required this.sku,
    required this.price,
    required this.mrp,
  });

  factory _VariantEditRow.fromModel(ProductVariant v) {
    return _VariantEditRow(
      title: TextEditingController(text: v.title),
      sku: TextEditingController(text: v.sku ?? ''),
      price: TextEditingController(text: v.price.toStringAsFixed(0)),
      mrp: TextEditingController(text: v.mrp.toStringAsFixed(0)),
    );
  }

  void dispose() {
    title.dispose();
    sku.dispose();
    price.dispose();
    mrp.dispose();
  }
}

class ProductEditView extends StatefulWidget {
  final String? productId;
  final ProductModel? initialProduct;

  const ProductEditView({
    super.key,
    this.productId,
    this.initialProduct,
  });

  @override
  State<ProductEditView> createState() => _ProductEditViewState();
}

class _ProductEditViewState extends State<ProductEditView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _brandController;
  late TextEditingController _descController;
  late TextEditingController _tagsController;
  late TextEditingController _newImageUrlController;

  late String _selectedStatus;
  late bool _buy1get1;
  String? _selectedCategory;
  String? _selectedSubCategory;
  late List<String> _assignedCollections;
  late TextEditingController _newCollectionController;

  late List<String> _images;
  late List<_VariantEditRow> _variants;
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _brandController = TextEditingController(text: 'Krishi Bhandar');
    _descController = TextEditingController();
    _tagsController = TextEditingController();
    _newImageUrlController = TextEditingController();
    _newCollectionController = TextEditingController();

    _selectedStatus = 'active';
    _buy1get1 = false;
    _assignedCollections = [];
    _images = [];
    _variants = [
      _VariantEditRow(
        title: TextEditingController(text: 'Standard (1 Unit)'),
        sku: TextEditingController(text: ''),
        price: TextEditingController(text: '299'),
        mrp: TextEditingController(text: '399'),
      ),
    ];

    final productState = context.read<ProductBloc>().state;
    if (productState.products.isEmpty && !productState.isLoading) {
      context.read<ProductBloc>().add(const LoadProducts());
    }
  }

  void _initFromProduct(ProductModel p, List<CategoryModel> categories) {
    if (_initialized) return;
    _initialized = true;

    _titleController.text = p.title;
    _brandController.text = p.brand;
    _descController.text = p.description ?? '';
    _tagsController.text = p.tags.join(', ');

    final validStatuses = ['active', 'draft', 'archived'];
    _selectedStatus = validStatuses.contains(p.status) ? p.status : 'active';
    _buy1get1 = p.buy1get1;
    _assignedCollections = List<String>.from(p.assignedCollections);

    _selectedCategory = p.resolveCategoryName(categories);
    _selectedSubCategory = p.resolveSubCategoryName(categories);

    _images = p.images.isNotEmpty ? List<String>.from(p.images) : [];

    if (p.variants.isNotEmpty) {
      for (final v in _variants) {
        v.dispose();
      }
      _variants = p.variants.map((v) => _VariantEditRow.fromModel(v)).toList();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _brandController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    _newImageUrlController.dispose();
    _newCollectionController.dispose();
    for (final v in _variants) {
      v.dispose();
    }
    super.dispose();
  }

  List<String> _getAvailableSubCategories(List<CategoryModel> categories) {
    if (_selectedCategory == null) return [];
    final matched = categories
        .where((c) => c.name.trim().toLowerCase() == _selectedCategory!.trim().toLowerCase())
        .firstOrNull;
    if (matched != null) {
      final names = <String>[];
      for (final s in matched.subCategories) {
        final n = s.name.trim();
        if (n.isNotEmpty && !names.contains(n)) {
          names.add(n);
        }
      }
      return names;
    }
    return [];
  }

  void _saveProduct(ProductModel? existingProduct, List<CategoryModel> categories) {
    if (!_formKey.currentState!.validate()) return;

    if (_variants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product variant.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final tagsList = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    // Map Category IDs matching MongoDB structure
    String catId = existingProduct?.category ?? '';
    String? subCatId = existingProduct?.subCategory;

    if (_selectedCategory != null) {
      final matchedCat = categories
          .where((c) => c.name.toLowerCase() == _selectedCategory!.toLowerCase())
          .firstOrNull;
      if (matchedCat != null) {
        catId = matchedCat.id;
        if (_selectedSubCategory != null) {
          final matchedSub = matchedCat.subCategories
              .where((s) => s.name.toLowerCase() == _selectedSubCategory!.toLowerCase())
              .firstOrNull;
          if (matchedSub != null) {
            subCatId = matchedSub.id;
          }
        }
      }
    }

    final variantModels = _variants.map((v) {
      final double pr = double.tryParse(v.price.text.trim()) ?? 0.0;
      final double mr = double.tryParse(v.mrp.text.trim()) ?? pr;
      return ProductVariant(
        id: 'var_${DateTime.now().millisecondsSinceEpoch}_${v.title.text.trim()}',
        title: v.title.text.trim().isNotEmpty ? v.title.text.trim() : 'Default',
        sku: v.sku.text.trim().isNotEmpty ? v.sku.text.trim() : null,
        price: pr,
        mrp: mr,
      );
    }).toList();

    final primaryVariant = variantModels.first;

    final isCreatingNew = existingProduct == null;
    final id = isCreatingNew ? 'prod_${DateTime.now().millisecondsSinceEpoch}' : existingProduct.id;

    final updated = ProductModel(
      id: id,
      title: _titleController.text.trim(),
      brand: _brandController.text.trim(),
      category: catId,
      categoryId: catId.isNotEmpty ? catId : existingProduct?.categoryId,
      categoryIds: existingProduct?.categoryIds.isNotEmpty == true
          ? existingProduct!.categoryIds
          : (catId.isNotEmpty ? [catId] : const []),
      subCategory: subCatId,
      assignedCollections: _assignedCollections,
      price: primaryVariant.price,
      mrp: primaryVariant.mrp,
      images: _images,
      status: _selectedStatus,
      buy1get1: _buy1get1,
      description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
      tags: tagsList,
      variants: variantModels,
      createdAt: existingProduct?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (isCreatingNew) {
      context.read<ProductBloc>().add(AddProductEvent(updated));
    } else {
      context.read<ProductBloc>().add(UpdateProductEvent(updated));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCreatingNew ? 'Created product "${updated.title}"' : 'Updated product "${updated.title}"'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() => _isSaving = false);
    context.go('/products');
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
                final isEditing = widget.productId != null && widget.productId!.isNotEmpty && widget.productId != 'new';
                final existingProduct = isEditing
                    ? productState.products.where((p) => p.id == widget.productId).firstOrNull ?? widget.initialProduct
                    : null;

                if (isEditing && existingProduct != null && !_initialized) {
                  _initFromProduct(existingProduct, categoryState.categories);
                }

                if (!_initialized && categoryState.categories.isNotEmpty && _selectedCategory == null) {
                  _selectedCategory = categoryState.categories.first.name;
                }

                final availableSubCats = _getAvailableSubCategories(categoryState.categories);

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Bar
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
                                  Text(
                                    isEditing ? 'Edit: ${_titleController.text.isNotEmpty ? _titleController.text : "Product"}' : 'Create New Product',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),

                              // Action Buttons
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () => context.go('/products'),
                                    child: const Text('Discard', style: TextStyle(color: Color(0xFF94A3B8))),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: _isSaving ? null : () => _saveProduct(existingProduct, categoryState.categories),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: themeState.currentPalette.primary,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                    icon: _isSaving
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          )
                                        : const Icon(Icons.save_rounded, size: 16, color: Colors.white),
                                    label: Text(
                                      isEditing ? 'Save Changes' : 'Create Product',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Form Layout
                        if (!isMobile)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Column: Media Gallery + Categories + Collections + Promotions
                              Expanded(
                                flex: 5,
                                child: Column(
                                  children: [
                                    _buildMediaSection(themeState, isDark),
                                    const SizedBox(height: 16),
                                    _buildCategorySection(categoryState.categories, availableSubCats, themeState, isDark),
                                    const SizedBox(height: 16),
                                    _buildCollectionsSection(themeState, isDark),
                                    const SizedBox(height: 16),
                                    _buildPromoSection(themeState, isDark),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Right Column: Basic Info + Variants Table + Description
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    _buildBasicInfoSection(themeState, isDark),
                                    const SizedBox(height: 16),
                                    _buildVariantsSection(themeState, isDark),
                                    const SizedBox(height: 16),
                                    _buildDescriptionSection(themeState, isDark),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBasicInfoSection(themeState, isDark),
                              const SizedBox(height: 16),
                              _buildMediaSection(themeState, isDark),
                              const SizedBox(height: 16),
                              _buildCategorySection(categoryState.categories, availableSubCats, themeState, isDark),
                              const SizedBox(height: 16),
                              _buildCollectionsSection(themeState, isDark),
                              const SizedBox(height: 16),
                              _buildPromoSection(themeState, isDark),
                              const SizedBox(height: 16),
                              _buildVariantsSection(themeState, isDark),
                              const SizedBox(height: 16),
                              _buildDescriptionSection(themeState, isDark),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBasicInfoSection(ThemeState themeState, bool isDark) {
    return _buildCard(
      title: '1. BASIC INFORMATION',
      icon: Icons.info_outline_rounded,
      themeState: themeState,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _titleController,
            label: 'Product Title *',
            hint: 'e.g. Organic Fungicide 500ml',
            isDark: isDark,
            validator: (val) => val == null || val.trim().isEmpty ? 'Product title is required' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _brandController,
                  label: 'Brand / Manufacturer',
                  hint: 'e.g. Krishi Bhandar',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('Active (Visible in Store)', style: TextStyle(fontSize: 12.5))),
                        DropdownMenuItem(value: 'draft', child: Text('Draft (Hidden)', style: TextStyle(fontSize: 12.5))),
                        DropdownMenuItem(value: 'archived', child: Text('Archived (Discontinued)', style: TextStyle(fontSize: 12.5))),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStatus = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _tagsController,
            label: 'Search Tags (Comma separated)',
            hint: 'e.g. crop-protection, organic, bestseller',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(ThemeState themeState, bool isDark) {
    return _buildCard(
      title: '2. MULTI-IMAGE MEDIA GALLERY',
      icon: Icons.photo_library_rounded,
      themeState: themeState,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _newImageUrlController,
                  label: 'Add Image URL',
                  hint: 'https://storage.googleapis.com/...',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton.icon(
                  onPressed: () {
                    final url = _newImageUrlController.text.trim();
                    if (url.isNotEmpty && !_images.contains(url)) {
                      setState(() {
                        _images.add(url);
                        _newImageUrlController.clear();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeState.currentPalette.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.add_photo_alternate_rounded, size: 16, color: Colors.white),
                  label: const Text('Add', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_images.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), style: BorderStyle.solid),
              ),
              child: const Center(
                child: Text('No images added. Paste an image URL above to add to gallery.', style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _images.asMap().entries.map((entry) {
                final idx = entry.key;
                final url = entry.value;
                final isCover = idx == 0;

                return Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCover ? themeState.currentPalette.primary : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      width: isCover ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                        child: SizedBox(
                          height: 75,
                          width: double.infinity,
                          child: ImagePreview(url: url, fit: BoxFit.cover),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (isCover)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: themeState.currentPalette.primary,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Text('Cover', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Colors.white)),
                              )
                            else
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    final img = _images.removeAt(idx);
                                    _images.insert(0, img);
                                  });
                                },
                                child: Text('Make Cover', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: themeState.currentPalette.primary)),
                              ),
                            InkWell(
                              onTap: () => setState(() => _images.removeAt(idx)),
                              child: const Icon(Icons.delete_outline_rounded, size: 15, color: Color(0xFFEF4444)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(List<CategoryModel> categories, List<String> availableSubCats, ThemeState themeState, bool isDark) {
    // 1. Deduplicate Category Names
    final uniqueCategoryNames = <String>[];
    for (final c in categories) {
      final n = c.name.trim();
      if (n.isNotEmpty && !uniqueCategoryNames.contains(n)) {
        uniqueCategoryNames.add(n);
      }
    }

    // Ensure selected category is present in list if it's set
    if (_selectedCategory != null && _selectedCategory!.trim().isNotEmpty) {
      final match = uniqueCategoryNames.where((c) => c.toLowerCase() == _selectedCategory!.trim().toLowerCase()).firstOrNull;
      if (match != null) {
        _selectedCategory = match;
      } else {
        uniqueCategoryNames.insert(0, _selectedCategory!);
      }
    } else if (uniqueCategoryNames.isNotEmpty) {
      _selectedCategory = uniqueCategoryNames.first;
    }

    // 2. Deduplicate Sub-Category Names
    final uniqueSubCatNames = <String>[];
    for (final s in availableSubCats) {
      final n = s.trim();
      if (n.isNotEmpty && !uniqueSubCatNames.contains(n)) {
        uniqueSubCatNames.add(n);
      }
    }

    // Ensure selected sub-category is valid
    if (_selectedSubCategory != null && _selectedSubCategory!.trim().isNotEmpty) {
      final subMatch = uniqueSubCatNames.where((s) => s.toLowerCase() == _selectedSubCategory!.trim().toLowerCase()).firstOrNull;
      if (subMatch != null) {
        _selectedSubCategory = subMatch;
      } else {
        _selectedSubCategory = null;
      }
    }

    return _buildCard(
      title: '3. CATEGORY & SUB-CATEGORY',
      icon: Icons.category_rounded,
      themeState: themeState,
      isDark: isDark,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569))),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  key: ValueKey('cat_${_selectedCategory}_${uniqueCategoryNames.length}'),
                  initialValue: _selectedCategory,
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: uniqueCategoryNames.map((name) => DropdownMenuItem(value: name, child: Text(name, style: const TextStyle(fontSize: 12.5)))).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategory = val;
                      _selectedSubCategory = null;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sub-Category', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569))),
                const SizedBox(height: 6),
                DropdownButtonFormField<String?>(
                  key: ValueKey('sub_${_selectedCategory}_${_selectedSubCategory}_${uniqueSubCatNames.length}'),
                  initialValue: _selectedSubCategory,
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    hintText: uniqueSubCatNames.isEmpty ? 'None Available' : 'Select Sub-Category',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('None (Main Category Only)', style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8))),
                    ),
                    ...uniqueSubCatNames.map((s) => DropdownMenuItem<String?>(value: s, child: Text(s, style: const TextStyle(fontSize: 12.5)))),
                  ],
                  onChanged: (val) => setState(() => _selectedSubCategory = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsSection(ThemeState themeState, bool isDark) {
    const quickCollections = [
      'Shop By Crop',
      'Buy 1 Get 1',
      'Rice',
      'Wheat',
      'Cotton',
      'Sugarcane',
      'Chilli',
      'Tomato',
      'Potato',
      'Mustard',
      'Paddy',
      'Groundnut',
      'Soybean',
      'Vegetables',
      'Fruits',
    ];

    return _buildCard(
      title: '4. ASSIGNED COLLECTIONS & CROPS',
      icon: Icons.collections_bookmark_rounded,
      themeState: themeState,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _newCollectionController,
                  label: 'Add Collection / Crop Tag',
                  hint: 'e.g. Cotton, Shop By Crop, Wheat',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton.icon(
                  onPressed: () {
                    final col = _newCollectionController.text.trim();
                    if (col.isNotEmpty && !_assignedCollections.contains(col)) {
                      setState(() {
                        _assignedCollections.add(col);
                        _newCollectionController.clear();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeState.currentPalette.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                  label: const Text('Add', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Quick Add Suggestions:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: quickCollections.map((qc) {
              final isAssigned = _assignedCollections.contains(qc);
              return ActionChip(
                label: Text(
                  qc,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isAssigned ? FontWeight.w800 : FontWeight.w600,
                    color: isAssigned ? themeState.currentPalette.primary : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                  ),
                ),
                avatar: Icon(
                  isAssigned ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                  size: 13,
                  color: isAssigned ? themeState.currentPalette.primary : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                ),
                backgroundColor: isAssigned
                    ? themeState.currentPalette.primary.withValues(alpha: 0.12)
                    : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                side: BorderSide(
                  color: isAssigned
                      ? themeState.currentPalette.primary.withValues(alpha: 0.4)
                      : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                  width: 0.8,
                ),
                onPressed: () {
                  setState(() {
                    if (isAssigned) {
                      _assignedCollections.remove(qc);
                    } else {
                      _assignedCollections.add(qc);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          if (_assignedCollections.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: Text(
                  'No collections assigned yet. Click any quick suggestion or type above.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else ...[
            Text(
              'Currently Assigned (${_assignedCollections.length}):',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _assignedCollections.map((col) {
                final isSpecial = col.toLowerCase().contains('buy') || col.toLowerCase().contains('crop');
                return Chip(
                  label: Text(
                    col,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSpecial ? const Color(0xFF8B5CF6) : const Color(0xFF059669),
                    ),
                  ),
                  avatar: Icon(
                    isSpecial ? Icons.auto_awesome_rounded : Icons.eco_rounded,
                    size: 13,
                    color: isSpecial ? const Color(0xFF8B5CF6) : const Color(0xFF10B981),
                  ),
                  deleteIcon: const Icon(Icons.close_rounded, size: 14),
                  onDeleted: () => setState(() => _assignedCollections.remove(col)),
                  backgroundColor: isSpecial
                      ? const Color(0xFF8B5CF6).withValues(alpha: 0.12)
                      : const Color(0xFF10B981).withValues(alpha: 0.12),
                  side: BorderSide(
                    color: isSpecial
                        ? const Color(0xFF8B5CF6).withValues(alpha: 0.35)
                        : const Color(0xFF10B981).withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPromoSection(ThemeState themeState, bool isDark) {
    return _buildCard(
      title: '5. PROMOTIONS & OFFERS',
      icon: Icons.local_offer_rounded,
      themeState: themeState,
      isDark: isDark,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _buy1get1 ? const Color(0xFFEF4444).withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _buy1get1 ? const Color(0xFFEF4444).withValues(alpha: 0.3) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.card_giftcard_rounded, size: 20, color: Color(0xFFEF4444)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Buy 1 Get 1 Free (1+1 Offer)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                    Text('Auto attaches promotion badge on customer storefront', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
            Switch(
              value: _buy1get1,
              activeThumbColor: const Color(0xFFEF4444),
              onChanged: (val) => setState(() => _buy1get1 = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantsSection(ThemeState themeState, bool isDark) {
    return _buildCard(
      title: '6. VARIANT PRICING & OPTIONS',
      icon: Icons.tune_rounded,
      themeState: themeState,
      isDark: isDark,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Multi-Variant Breakdown', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A))),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _variants.add(_VariantEditRow(
                      title: TextEditingController(text: 'Option ${_variants.length + 1}'),
                      sku: TextEditingController(text: ''),
                      price: TextEditingController(text: '299'),
                      mrp: TextEditingController(text: '399'),
                    ));
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeState.currentPalette.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                label: const Text('Add Variant', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._variants.asMap().entries.map((entry) {
            final idx = entry.key;
            final v = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildTextField(controller: v.title, label: 'Title / Weight', hint: '1 Liter', isDark: isDark),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _buildTextField(controller: v.sku, label: 'SKU', hint: 'KB-001', isDark: isDark),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _buildTextField(controller: v.price, label: 'Price (₹)', hint: '299', isDark: isDark, isNumber: true),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _buildTextField(controller: v.mrp, label: 'MRP (₹)', hint: '399', isDark: isDark, isNumber: true),
                  ),
                  if (_variants.length > 1) ...[
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                        onPressed: () {
                          setState(() {
                            final removed = _variants.removeAt(idx);
                            removed.dispose();
                          });
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(ThemeState themeState, bool isDark) {
    return _buildCard(
      title: '7. DETAILED PRODUCT DESCRIPTION',
      icon: Icons.description_rounded,
      themeState: themeState,
      isDark: isDark,
      child: _buildTextField(
        controller: _descController,
        label: 'Description & Application Directions',
        hint: 'Enter full product description, usage instructions, chemical composition, dosage...',
        isDark: isDark,
        maxLines: 5,
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required ThemeState themeState,
    required bool isDark,
    required Widget child,
  }) {
    return AnimatedContainer(
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
            children: [
              Icon(icon, size: 16, color: themeState.currentPalette.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    bool isNumber = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(fontSize: 12.5, color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}
