import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import 'image_preview.dart';

class ProductEditDialog extends StatefulWidget {
  final ProductModel? existingProduct;
  final List<CategoryModel> categories;
  final void Function(ProductModel product) onSave;

  const ProductEditDialog({
    super.key,
    this.existingProduct,
    required this.categories,
    required this.onSave,
  });

  @override
  State<ProductEditDialog> createState() => _ProductEditDialogState();
}

class _ProductEditDialogState extends State<ProductEditDialog> {
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

  late List<String> _images;
  late List<_VariantEditRow> _variants;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;

    _titleController = TextEditingController(text: p?.title ?? '');
    _brandController = TextEditingController(text: p?.brand ?? 'Krishi Bhandar');
    _descController = TextEditingController(text: p?.description ?? '');
    _tagsController = TextEditingController(text: p?.tags.join(', ') ?? '');
    _newImageUrlController = TextEditingController();

    _selectedStatus = p?.status ?? 'active';
    _buy1get1 = p?.buy1get1 ?? false;

    // Resolve initial category
    if (p != null) {
      _selectedCategory = p.resolveCategoryName(widget.categories);
      _selectedSubCategory = p.resolveSubCategoryName(widget.categories);
    } else if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first.name;
    }

    _images = p != null && p.images.isNotEmpty ? List<String>.from(p.images) : [];

    if (p != null && p.variants.isNotEmpty) {
      _variants = p.variants.map((v) => _VariantEditRow.fromModel(v)).toList();
    } else {
      _variants = [
        _VariantEditRow(
          title: TextEditingController(text: 'Standard (1 Unit)'),
          sku: TextEditingController(text: ''),
          price: TextEditingController(text: p != null ? p.price.toStringAsFixed(0) : '299'),
          mrp: TextEditingController(text: p != null ? p.mrp.toStringAsFixed(0) : '399'),
        ),
      ];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _brandController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    _newImageUrlController.dispose();
    for (final v in _variants) {
      v.dispose();
    }
    super.dispose();
  }

  List<String> _getAvailableSubCategories() {
    if (_selectedCategory == null) return [];
    final matched = widget.categories
        .where((c) => c.name.toLowerCase() == _selectedCategory!.toLowerCase())
        .firstOrNull;
    if (matched != null) {
      return matched.subCategories.map((s) => s.name).toList();
    }
    return [];
  }

  void _addImageUrl() {
    final url = _newImageUrlController.text.trim();
    if (url.isNotEmpty) {
      setState(() {
        _images.add(url);
        _newImageUrlController.clear();
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _makeImagePrimary(int index) {
    if (index > 0 && index < _images.length) {
      setState(() {
        final img = _images.removeAt(index);
        _images.insert(0, img);
      });
    }
  }

  void _addVariantRow() {
    setState(() {
      _variants.add(_VariantEditRow(
        title: TextEditingController(text: 'New Variant'),
        sku: TextEditingController(text: ''),
        price: TextEditingController(text: '199'),
        mrp: TextEditingController(text: '299'),
      ));
    });
  }

  void _removeVariantRow(int index) {
    if (_variants.length > 1) {
      setState(() {
        final removed = _variants.removeAt(index);
        removed.dispose();
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Convert variants
    final List<ProductVariant> productVariants = _variants.map((v) {
      final price = double.tryParse(v.price.text.trim()) ?? 0.0;
      final mrp = double.tryParse(v.mrp.text.trim()) ?? price;
      return ProductVariant(
        id: v.id ?? 'var_${DateTime.now().millisecondsSinceEpoch}_${_variants.indexOf(v)}',
        title: v.title.text.trim().isEmpty ? 'Default' : v.title.text.trim(),
        sku: v.sku.text.trim().isEmpty ? null : v.sku.text.trim(),
        price: price,
        mrp: mrp >= price ? mrp : price,
      );
    }).toList();

    final primaryPrice = productVariants.isNotEmpty ? productVariants.first.price : 0.0;
    final primaryMrp = productVariants.isNotEmpty ? productVariants.first.mrp : primaryPrice;

    // Tags
    final rawTags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    // Category resolution
    final matchedCat = widget.categories
        .where((c) => c.name.toLowerCase() == (_selectedCategory ?? '').toLowerCase())
        .firstOrNull;

    final updatedProduct = ProductModel(
      id: widget.existingProduct?.id ?? 'prod_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      category: _selectedCategory ?? 'General',
      categoryId: matchedCat?.id,
      categoryIds: matchedCat != null ? [matchedCat.id] : [],
      subCategory: _selectedSubCategory,
      tags: rawTags,
      brand: _brandController.text.trim().isEmpty ? 'Krishi Bhandar' : _brandController.text.trim(),
      status: _selectedStatus,
      buy1get1: _buy1get1,
      images: _images,
      variants: productVariants,
      price: primaryPrice,
      mrp: primaryMrp,
      inStock: _selectedStatus == 'active',
      isPublished: _selectedStatus == 'active',
      isFeatured: _buy1get1,
    );

    widget.onSave(updatedProduct);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.existingProduct != null;
    final availableSubCategories = _getAvailableSubCategories();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 880,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isEditing ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                          size: 22,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Edit Catalog Product' : 'Create New Product',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            isEditing
                                ? 'Update images, variants, categorization and inventory'
                                : 'Add a new product to your Krishi Bhandar store',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Scrollable Form Body
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SECTION 1: Product Images & Gallery Editor
                      _buildSectionHeader('1. Product Media & Image Gallery (${_images.length} Images)', Icons.photo_library_outlined, isDark),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Images Strip / Cards
                            if (_images.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: Text(
                                    'No images added yet. Add image URLs below.',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: _images.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final imgUrl = entry.value;
                                  final isPrimary = idx == 0;

                                  return Container(
                                    width: 140,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isPrimary
                                            ? theme.colorScheme.primary
                                            : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                        width: isPrimary ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                                              child: ImagePreview(
                                                url: imgUrl,
                                                width: 140,
                                                height: 110,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            if (isPrimary)
                                              Positioned(
                                                top: 6,
                                                left: 6,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: theme.colorScheme.primary,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Text(
                                                    'COVER',
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w800,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (!isPrimary)
                                                InkWell(
                                                  onTap: () => _makeImagePrimary(idx),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                    child: Text(
                                                      'Set Cover',
                                                      style: TextStyle(
                                                        fontSize: 10.5,
                                                        fontWeight: FontWeight.w700,
                                                        color: theme.colorScheme.primary,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              else
                                                const SizedBox(width: 4),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints.tightFor(width: 24, height: 24),
                                                tooltip: 'Remove Image',
                                                onPressed: () => _removeImage(idx),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),

                            const SizedBox(height: 14),

                            // Add New Image Input
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    child: TextField(
                                      controller: _newImageUrlController,
                                      style: const TextStyle(fontSize: 13),
                                      decoration: const InputDecoration(
                                        hintText: 'Paste Image URL (https://storage.googleapis.com/... or https://...)',
                                        prefixIcon: Icon(Icons.add_link_rounded, size: 18),
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  height: 40,
                                  child: ElevatedButton.icon(
                                    onPressed: _addImageUrl,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                    ),
                                    icon: const Icon(Icons.add_photo_alternate_rounded, size: 16),
                                    label: const Text('Add Image', style: TextStyle(fontSize: 12.5)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // SECTION 2: General Product Info
                      _buildSectionHeader('2. General Product Information', Icons.info_outline_rounded, isDark),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          labelText: 'Product Title / Name *',
                          hintText: 'e.g. All Expert Bio Pesticide Liquid 500ml',
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _brandController,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                labelText: 'Brand / Manufacturer / Vendor *',
                                hintText: 'e.g. Krishi Bhandar, Syngenta, Bayer',
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedStatus,
                              isExpanded: true,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                              decoration: const InputDecoration(labelText: 'Publish Status *'),
                              items: const [
                                DropdownMenuItem(value: 'active', child: Text('Active (Live in store)')),
                                DropdownMenuItem(value: 'draft', child: Text('Draft (Hidden)')),
                                DropdownMenuItem(value: 'archived', child: Text('Archived')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedStatus = val);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Buy 1 Get 1 Free Promo Toggle
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _buy1get1
                                ? const Color(0xFFEF4444).withValues(alpha: 0.6)
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.local_offer_rounded,
                                  size: 20,
                                  color: _buy1get1 ? const Color(0xFFEF4444) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Buy 1 Get 1 Free (1+1 BOGO Promotion)',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      'Displays promotional 1+1 badge and flags item across banners',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      ),
                                    ),
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

                      const SizedBox(height: 20),

                      // SECTION 3: Categorization & Hierarchy
                      _buildSectionHeader('3. Categories & Sub-Category Hierarchy', Icons.category_rounded, isDark),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          // Parent Category Dropdown
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              initialValue: widget.categories.any((c) => c.name == _selectedCategory)
                                  ? _selectedCategory
                                  : (widget.categories.isNotEmpty ? widget.categories.first.name : null),
                              isExpanded: true,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                              decoration: const InputDecoration(labelText: 'Parent Category *'),
                              items: widget.categories.map((c) {
                                return DropdownMenuItem(value: c.name, child: Text(c.name, overflow: TextOverflow.ellipsis));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedCategory = val;
                                    // Reset subcategory when parent changes
                                    final subCats = _getAvailableSubCategories();
                                    _selectedSubCategory = subCats.isNotEmpty ? subCats.first : null;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Sub-Category Dropdown (Dynamic)
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String?>(
                              initialValue: availableSubCategories.contains(_selectedSubCategory)
                                  ? _selectedSubCategory
                                  : (availableSubCategories.isNotEmpty ? availableSubCategories.first : null),
                              isExpanded: true,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                              decoration: InputDecoration(
                                labelText: availableSubCategories.isEmpty
                                    ? 'Sub-Category (None in category)'
                                    : 'Sub-Category',
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('No Sub-Category')),
                                ...availableSubCategories.map((s) {
                                  return DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis));
                                }),
                              ],
                              onChanged: availableSubCategories.isEmpty
                                  ? null
                                  : (val) => setState(() => _selectedSubCategory = val),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _tagsController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Search Tags / Keywords (Comma separated)',
                          hintText: 'e.g. Bio, Organic, Systemic, 500ml, Liquid',
                          prefixIcon: Icon(Icons.tag_rounded, size: 18),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // SECTION 4: Product Variants & Price Packaging
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader('4. Variants, Pack Sizes & Prices', Icons.layers_outlined, isDark),
                          ElevatedButton.icon(
                            onPressed: _addVariantRow,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              textStyle: const TextStyle(fontSize: 11.5),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('Add Variant'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                child: Row(
                                  children: [
                                    const Expanded(flex: 3, child: Text('PACK / OPTION *', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700))),
                                    const SizedBox(width: 8),
                                    const Expanded(flex: 2, child: Text('SKU', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700))),
                                    const SizedBox(width: 8),
                                    const Expanded(flex: 2, child: Text('PRICE (₹) *', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700))),
                                    const SizedBox(width: 8),
                                    const Expanded(flex: 2, child: Text('MRP (₹)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700))),
                                    const SizedBox(width: 32),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              ..._variants.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final v = entry.value;

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: theme.dividerTheme.color ?? Colors.grey.withValues(alpha: 0.2),
                                        width: 0.8,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Title / Option
                                      Expanded(
                                        flex: 3,
                                        child: SizedBox(
                                          height: 36,
                                          child: TextFormField(
                                            controller: v.title,
                                            style: const TextStyle(fontSize: 12.5),
                                            decoration: const InputDecoration(
                                              hintText: 'e.g. 500 ml',
                                              isDense: true,
                                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // SKU
                                      Expanded(
                                        flex: 2,
                                        child: SizedBox(
                                          height: 36,
                                          child: TextFormField(
                                            controller: v.sku,
                                            style: const TextStyle(fontSize: 12.5),
                                            decoration: const InputDecoration(
                                              hintText: 'SKU Code',
                                              isDense: true,
                                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Price
                                      Expanded(
                                        flex: 2,
                                        child: SizedBox(
                                          height: 36,
                                          child: TextFormField(
                                            controller: v.price,
                                            keyboardType: TextInputType.number,
                                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                                            decoration: const InputDecoration(
                                              prefixText: '₹ ',
                                              isDense: true,
                                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // MRP
                                      Expanded(
                                        flex: 2,
                                        child: SizedBox(
                                          height: 36,
                                          child: TextFormField(
                                            controller: v.mrp,
                                            keyboardType: TextInputType.number,
                                            style: const TextStyle(fontSize: 12.5),
                                            decoration: const InputDecoration(
                                              prefixText: '₹ ',
                                              isDense: true,
                                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),

                                      // Remove Variant Button
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints.tightFor(width: 26, height: 26),
                                        tooltip: 'Remove Variant',
                                        onPressed: _variants.length > 1 ? () => _removeVariantRow(idx) : null,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // SECTION 5: Description
                      _buildSectionHeader('5. Product Description & Specifications', Icons.description_outlined, isDark),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: _descController,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Enter detailed agricultural composition, usage dosage, recommended crops...',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 24),

              // Bottom Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: Icon(isEditing ? Icons.save_rounded : Icons.check_rounded, size: 18),
                    label: Text(isEditing ? 'Save Changes' : 'Create Product'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

class _VariantEditRow {
  final String? id;
  final TextEditingController title;
  final TextEditingController sku;
  final TextEditingController price;
  final TextEditingController mrp;

  _VariantEditRow({
    this.id,
    required this.title,
    required this.sku,
    required this.price,
    required this.mrp,
  });

  factory _VariantEditRow.fromModel(ProductVariant v) {
    return _VariantEditRow(
      id: v.id,
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
