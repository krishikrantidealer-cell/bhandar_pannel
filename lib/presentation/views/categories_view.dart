import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/categories/category_bloc.dart';
import '../../logic/categories/category_event.dart';
import '../../logic/categories/category_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_state.dart';
import '../../models/category_model.dart';
import '../widgets/image_preview.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

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
    final subCatController = TextEditingController(
      text: existingCategory?.subCategories.map((s) => s.name).join(', ') ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existingCategory == null ? 'Add New Category' : 'Edit Category'),
        content: SizedBox(
          width: 550,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Category Name *', hintText: 'e.g. Fungicides'),
                  onChanged: (val) {
                    if (existingCategory == null) {
                      slugController.text =
                          val.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9\-]'), '');
                    }
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: slugController,
                  decoration: const InputDecoration(labelText: 'Category Slug / Handle *', hintText: 'fungicides'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                      labelText: 'Banner / Header Title', hintText: 'Crop Disease Protection Solutions'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: bannerController,
                  decoration: const InputDecoration(
                      labelText: 'Category Banner Image URL', hintText: 'https://storage.googleapis.com/...'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: stripController,
                  decoration: const InputDecoration(
                      labelText: 'Strip Banner URL', hintText: 'https://storage.googleapis.com/...'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: pdfController,
                  decoration: const InputDecoration(
                      labelText: 'Catalogue PDF URL', hintText: 'https://storage.googleapis.com/...'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: subCatController,
                  decoration: const InputDecoration(
                    labelText: 'Subcategories (Comma separated)',
                    hintText: 'Chemical-Fungicide, Bio-Fungicide, Organic-Fungicide',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final slug = slugController.text.trim();
              if (name.isEmpty) return;

              final subCats = subCatController.text
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .map((s) => SubCategory(id: 'sub_${DateTime.now().millisecondsSinceEpoch}_$s', name: s))
                  .toList();

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
                  subCategories: subCats,
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
                  subCategories: subCats,
                );
                context.read<CategoryBloc>().add(UpdateCategoryEvent(updated));
              }
              Navigator.of(ctx).pop();
            },
            child: Text(existingCategory == null ? 'Create Category' : 'Save Changes'),
          ),
        ],
      ),
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
        return BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, categoryState) {
            final categories = categoryState.categories;

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
                            'Categories & Department Hierarchy',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Configure category titles, strip banners, subcategories, and catalogues',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditCategoryModal(),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Add Category'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Categories Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double width = constraints.maxWidth;
                      int crossAxisCount = 3;
                      if (width < 700) {
                        crossAxisCount = 1;
                      } else if (width < 1100) {
                        crossAxisCount = 2;
                      }

                      final itemWidth = (width - ((crossAxisCount - 1) * 20)) / crossAxisCount;

                      return Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: categories.map((cat) {
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
                                          height: 140,
                                          borderRadius: 0,
                                        ),
                                      ),
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.6),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                                                onPressed: () =>
                                                    _showAddEditCategoryModal(existingCategory: cat),
                                                tooltip: 'Edit Category',
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.6),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.delete_outline,
                                                    size: 16, color: Colors.redAccent),
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
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                cat.name,
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: themeState.currentPalette.primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '/${cat.slug}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: themeState.currentPalette.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (cat.description != null && cat.description!.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            cat.description!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF64748B),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        const SizedBox(height: 12),
                                        const Divider(height: 1),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Subcategories (${cat.subCategories.length})',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: cat.subCategories.map((sub) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? const Color(0xFF0F172A)
                                                    : const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: isDark
                                                      ? const Color(0xFF334155)
                                                      : const Color(0xFFE2E8F0),
                                                ),
                                              ),
                                              child: Text(
                                                sub.name,
                                                style: const TextStyle(
                                                    fontSize: 11, fontWeight: FontWeight.w500),
                                              ),
                                            );
                                          }).toList(),
                                        ),
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
  }
}
