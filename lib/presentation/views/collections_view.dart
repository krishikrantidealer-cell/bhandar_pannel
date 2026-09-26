import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/collections/collection_bloc.dart';
import '../../logic/collections/collection_event.dart';
import '../../logic/collections/collection_state.dart';
import '../../logic/products/product_bloc.dart';
import '../../logic/products/product_event.dart';
import '../../logic/products/product_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_state.dart';
import '../../models/collection_model.dart';
import '../../core/utils/image_upload_helper.dart';
import '../widgets/image_preview.dart';
import '../widgets/status_badge.dart';
import '../widgets/shimmer_loading.dart';

class CollectionsView extends StatefulWidget {
  final bool isEmbedded;
  const CollectionsView({super.key, this.isEmbedded = false});

  @override
  State<CollectionsView> createState() => _CollectionsViewState();
}

class _CollectionsViewState extends State<CollectionsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditSubCollectionDialog({
    required BuildContext parentContext,
    SubCollectionModel? existingSub,
    VoidCallback? onDelete,
    required Function(SubCollectionModel updatedSub) onSave,
  }) {
    final nameCtl = TextEditingController(text: existingSub?.name ?? '');
    final slugCtl = TextEditingController(text: existingSub?.slug ?? '');
    final countCtl = TextEditingController(text: existingSub?.count ?? '');
    final imgCtl = TextEditingController(text: existingSub?.image ?? '');

    showDialog(
      context: parentContext,
      builder: (subCtx) => StatefulBuilder(
        builder: (dialogCtx, setSubState) {
          final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;
          final primaryColor = Theme.of(dialogCtx).colorScheme.primary;
          final currentImg = imgCtl.text.trim();

          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    existingSub == null ? Icons.add_photo_alternate_rounded : Icons.edit_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  existingSub == null ? 'Add Sub-Category' : 'Edit Sub-Category Details',
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Live Image Preview
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: currentImg.isNotEmpty
                              ? ImagePreview(
                                  url: currentImg,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  enableEnlarge: true,
                                )
                              : const Center(
                                  child: Icon(Icons.image_outlined, size: 28, color: Color(0xFF94A3B8)),
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                existingSub == null ? 'Create Sub-Category' : 'Edit Sub-Category Details',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Upload a sub-category image directly to Google Storage or paste URL below',
                                style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: nameCtl,
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                              labelText: 'Sub-Category Name *',
                              hintText: 'e.g. Rice / Seeds',
                              isDense: true,
                            ),
                            onChanged: (v) {
                              if (slugCtl.text.isEmpty || existingSub == null) {
                                slugCtl.text = v.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9\-]'), '');
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: slugCtl,
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                              labelText: 'Slug',
                              hintText: 'rice',
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: countCtl,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Product Count Label (Optional)',
                        hintText: 'e.g. 50+ Products (Leave empty for live auto-count)',
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: imgCtl,
                      style: const TextStyle(fontSize: 13),
                      onChanged: (_) => setSubState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Sub-Category Image URL (Google Bucket)',
                        hintText: 'https://storage.googleapis.com/... or paste image URL',
                        prefixIcon: const Icon(Icons.image_search_rounded, size: 18),
                        suffixIcon: IconButton(
                          tooltip: 'Upload image to Krishi Bhandar Google Bucket',
                          icon: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF3B82F6), size: 18),
                          onPressed: () async {
                            final url = await ImageUploadHelper.pickAndUploadImage(
                              context: dialogCtx,
                              folder: 'crops',
                            );
                            if (url != null) {
                              setSubState(() {
                                imgCtl.text = url;
                              });
                            }
                          },
                        ),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              if (onDelete != null)
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text('Delete'),
                  onPressed: () {
                    onDelete();
                    Navigator.pop(subCtx);
                  },
                ),
              TextButton(onPressed: () => Navigator.pop(subCtx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final sName = nameCtl.text.trim();
                  if (sName.isEmpty) return;
                  final sSlug = slugCtl.text.trim().isNotEmpty
                      ? slugCtl.text.trim()
                      : sName.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9\-]'), '');
                  final updated = SubCollectionModel(
                    id: existingSub?.id ?? sSlug,
                    name: sName,
                    slug: sSlug,
                    count: countCtl.text.trim().isNotEmpty ? countCtl.text.trim() : null,
                    image: imgCtl.text.trim().isNotEmpty ? imgCtl.text.trim() : null,
                    isActive: existingSub?.isActive ?? true,
                  );
                  onSave(updated);
                  Navigator.pop(subCtx);
                },
                child: Text(existingSub == null ? 'Add Sub-Category' : 'Save Details'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showManageProductsDialog({
    required BuildContext parentContext,
    required String targetTitle,
    required String targetTagOrSlug,
    required List<String> matchKeys,
  }) {
    final productBloc = parentContext.read<ProductBloc>();
    final allProducts = productBloc.state.allProducts;

    final selectedIds = <String>{};
    for (final p in allProducts) {
      final isMatched = matchKeys.any((k) {
        final lower = k.toLowerCase().trim();
        return p.collectionIds.contains(k) ||
            p.subCollectionIds.contains(k) ||
            p.assignedCollections.contains(k) ||
            p.assignedCollections.any((ac) => ac.toLowerCase().trim() == lower) ||
            p.tags.any((t) => t.toLowerCase().trim() == lower);
      });
      if (isMatched) {
        selectedIds.add(p.id);
      }
    }

    String searchQuery = '';

    showDialog(
      context: parentContext,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final primaryColor = Theme.of(ctx).colorScheme.primary;

          final filteredProducts = allProducts.where((p) {
            final matchesSearch = searchQuery.isEmpty ||
                p.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                p.brand.toLowerCase().contains(searchQuery.toLowerCase()) ||
                (p.sku != null && p.sku!.toLowerCase().contains(searchQuery.toLowerCase()));
            return matchesSearch;
          }).toList();

          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF10B981), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Manage Products: $targetTitle', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(
                        'Select products to assign or remove from this collection / sub-category',
                        style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${selectedIds.length} Selected',
                    style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 580,
              height: 480,
              child: Column(
                children: [
                  // Filter Bar
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search by title, brand, sku...',
                            prefixIcon: const Icon(Icons.search, size: 18),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          style: const TextStyle(fontSize: 12.5),
                          onChanged: (v) => setDialogState(() => searchQuery = v.trim()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            final visibleIds = filteredProducts.map((p) => p.id);
                            selectedIds.addAll(visibleIds);
                          });
                        },
                        icon: const Icon(Icons.check_box_outlined, size: 16),
                        label: const Text('Select All', style: TextStyle(fontSize: 11.5)),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            final visibleIds = filteredProducts.map((p) => p.id).toSet();
                            selectedIds.removeWhere((id) => visibleIds.contains(id));
                          });
                        },
                        icon: const Icon(Icons.check_box_outline_blank, size: 16),
                        label: const Text('Clear', style: TextStyle(fontSize: 11.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  // Products List
                  Expanded(
                    child: filteredProducts.isEmpty
                        ? const Center(
                            child: Text('No products match the filter.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                          )
                        : ListView.separated(
                            itemCount: filteredProducts.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (ctx, idx) {
                              final p = filteredProducts[idx];
                              final isSelected = selectedIds.contains(p.id);
                              final imgUrl = p.images.isNotEmpty ? p.images.first : '';

                              return CheckboxListTile(
                                value: isSelected,
                                activeColor: primaryColor,
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                onChanged: (val) {
                                  setDialogState(() {
                                    if (val == true) {
                                      selectedIds.add(p.id);
                                    } else {
                                      selectedIds.remove(p.id);
                                    }
                                  });
                                },
                                secondary: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: imgUrl.isNotEmpty
                                      ? ImagePreview(url: imgUrl, width: 38, height: 38, fit: BoxFit.cover)
                                      : const Icon(Icons.inventory_2_outlined, size: 20, color: Color(0xFF94A3B8)),
                                ),
                                title: Text(p.title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text(
                                  '₹${p.price.toStringAsFixed(0)} • ${p.brand.isNotEmpty ? p.brand : 'Krishi Bhandar'}',
                                  style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
              ElevatedButton.icon(
                icon: const Icon(Icons.save_rounded, size: 16),
                label: Text('Save Assignments (${selectedIds.length})'),
                onPressed: () {
                  final tag = targetTagOrSlug.trim();
                  for (final p in allProducts) {
                    final shouldBeAssigned = selectedIds.contains(p.id);
                    final isCurrentlyAssigned = p.assignedCollections.contains(tag) ||
                        p.assignedCollections.any((ac) => ac.toLowerCase() == tag.toLowerCase());

                    if (shouldBeAssigned && !isCurrentlyAssigned) {
                      final updatedAssigned = [...p.assignedCollections, tag];
                      productBloc.add(UpdateProductEvent(p.copyWith(assignedCollections: updatedAssigned)));
                    } else if (!shouldBeAssigned && isCurrentlyAssigned) {
                      final updatedAssigned = p.assignedCollections.where((ac) => ac.toLowerCase() != tag.toLowerCase()).toList();
                      productBloc.add(UpdateProductEvent(p.copyWith(assignedCollections: updatedAssigned)));
                    }
                  }
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text('Updated: ${selectedIds.length} products assigned to $targetTitle'),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddEditCollectionModal({CollectionModel? existingCollection}) {
    final nameController = TextEditingController(text: existingCollection?.name ?? '');
    final slugController = TextEditingController(text: existingCollection?.slug ?? '');
    final descController = TextEditingController(text: existingCollection?.description ?? '');
    final bannerController = TextEditingController(text: existingCollection?.bannerImage ?? '');
    final stripBannerController = TextEditingController(text: existingCollection?.stripBanner ?? '');
    final bannerTitleController = TextEditingController(text: existingCollection?.bannerTitle ?? '');
    final priorityController = TextEditingController(
      text: existingCollection != null ? existingCollection.priority.toString() : '0',
    );
    
    // Copy existing subcollections so we can edit them
    List<SubCollectionModel> editableSubs = existingCollection != null
        ? List<SubCollectionModel>.from(existingCollection.subCollections)
        : [];

    bool isActive = existingCollection?.isActive ?? true;
    String headingType = existingCollection?.headingType ?? 'both';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final isDark = Theme.of(modalCtx).brightness == Brightness.dark;
          final primaryColor = Theme.of(modalCtx).colorScheme.primary;
          final bannerUrl = bannerController.text.trim();
          final stripUrl = stripBannerController.text.trim();

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
                    existingCollection == null ? Icons.collections_bookmark_rounded : Icons.edit_note_rounded,
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
                        existingCollection == null ? 'Add New Collection' : 'Edit Collection',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Configure collection banners, strip banner / text header, and sub-categories',
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
              width: 620,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dual Banner Previews (Main & Strip)
                    Row(
                      children: [
                        // Collection Main Banner Preview
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Main Banner Preview',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Container(
                                height: 100,
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
                                        height: 100,
                                        fit: BoxFit.cover,
                                        enableEnlarge: true,
                                      )
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.image_outlined,
                                                size: 26,
                                                color: isDark
                                                    ? const Color(0xFF475569)
                                                    : const Color(0xFF94A3B8)),
                                            const SizedBox(height: 4),
                                            Text(
                                              'No Banner Image',
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
                                height: 100,
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
                                        height: 100,
                                        fit: BoxFit.cover,
                                        enableEnlarge: true,
                                      )
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.view_stream_outlined,
                                                size: 26,
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
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: nameController,
                            style: const TextStyle(fontSize: 13.5),
                            decoration: InputDecoration(
                              labelText: 'Collection Name *',
                              hintText: 'e.g. Shop by Crop or Monsoon Offers',
                              isDense: true,
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onChanged: (val) {
                              if (existingCollection == null) {
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
                              hintText: 'shop-by-crop',
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

                    // Header / Heading Style Selector
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            initialValue: headingType,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Heading Display Style',
                              isDense: true,
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'both', child: Text('Both (Strip Banner + Title Text)')),
                              DropdownMenuItem(value: 'strip_banner', child: Text('Strip Banner Heading')),
                              DropdownMenuItem(value: 'text', child: Text('Text Title Heading')),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => headingType = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: priorityController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 13.5),
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              hintText: '10',
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
                      controller: bannerTitleController,
                      style: const TextStyle(fontSize: 13.5),
                      decoration: InputDecoration(
                        labelText: 'Banner / Header Title (Text Heading)',
                        hintText: 'Seasonal Agro Defense & Top Yield',
                        prefixIcon: const Icon(Icons.title_rounded, size: 18),
                        isDense: true,
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: bannerController,
                      style: const TextStyle(fontSize: 13.5),
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Main Banner Image URL (Optional if Strip Banner used)',
                        hintText: 'https://storage.googleapis.com/... or paste image URL',
                        prefixIcon: const Icon(Icons.image_outlined, size: 18),
                        suffixIcon: IconButton(
                          tooltip: 'Upload image to Krishi Bhandar Google Bucket',
                          icon: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF3B82F6), size: 20),
                          onPressed: () async {
                            final url = await ImageUploadHelper.pickAndUploadImage(
                              context: modalCtx,
                              folder: 'collections',
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
                      controller: stripBannerController,
                      style: const TextStyle(fontSize: 13.5),
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Strip Banner URL (Google Bucket) (Renders on Home Screen)',
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
                                stripBannerController.text = url;
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

                    // Sub-Categories Section Editor
                    Container(
                      padding: const EdgeInsets.all(12),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sub-Categories (${editableSubs.length})',
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    'Configure sub-categories and items for this collection',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: const Icon(Icons.add_photo_alternate_rounded, size: 16),
                                label: const Text('Add Sub-Category', style: TextStyle(fontSize: 11.5)),
                                onPressed: () {
                                  _showAddEditSubCollectionDialog(
                                    parentContext: modalCtx,
                                    onSave: (newSub) {
                                      setModalState(() {
                                        editableSubs.add(newSub);
                                      });
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (editableSubs.isEmpty)
                            Text(
                              'No sub-categories configured yet. Click "Add Sub-Category" above.',
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: editableSubs.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final sub = entry.value;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (sub.image != null && sub.image!.isNotEmpty) ...[
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: ImagePreview(
                                            url: sub.image!,
                                            width: 24,
                                            height: 24,
                                            fit: BoxFit.cover,
                                            enableEnlarge: true,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            sub.name,
                                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                                          ),
                                          if (sub.count != null && sub.count!.isNotEmpty)
                                            Text(
                                              sub.count!,
                                              style: TextStyle(
                                                fontSize: 9.5,
                                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 6),
                                      // Edit Sub Button
                                      InkWell(
                                        onTap: () {
                                          _showAddEditSubCollectionDialog(
                                            parentContext: modalCtx,
                                            existingSub: sub,
                                            onDelete: () {
                                              setModalState(() {
                                                editableSubs.removeAt(idx);
                                              });
                                            },
                                            onSave: (updatedSub) {
                                              setModalState(() {
                                                editableSubs[idx] = updatedSub;
                                              });
                                            },
                                          );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(3),
                                          child: Icon(Icons.edit, size: 14, color: Color(0xFF3B82F6)),
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      // Delete Sub Button
                                      InkWell(
                                        onTap: () {
                                          setModalState(() {
                                            editableSubs.removeAt(idx);
                                          });
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(3),
                                          child: Icon(Icons.close_rounded, size: 14, color: Color(0xFFEF4444)),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: descController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13.5),
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Brief summary of this product group',
                        isDense: true,
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    SwitchListTile(
                      title: const Text('Active on Apps & Web', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      value: isActive,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      onChanged: (val) {
                        setModalState(() => isActive = val);
                      },
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

                  final priority = int.tryParse(priorityController.text.trim()) ?? 0;

                  if (existingCollection == null) {
                    final newCol = CollectionModel(
                      id: 'col_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      slug: slug.isNotEmpty ? slug : name.toLowerCase(),
                      description: descController.text.trim(),
                      bannerImage: bannerController.text.trim(),
                      stripBanner: stripBannerController.text.trim(),
                      bannerTitle: bannerTitleController.text.trim(),
                      headingType: headingType,
                      priority: priority,
                      isActive: isActive,
                      subCollections: editableSubs,
                    );
                    context.read<CollectionBloc>().add(AddCollectionEvent(newCol));
                  } else {
                    final updated = existingCollection.copyWith(
                      name: name,
                      slug: slug,
                      description: descController.text.trim(),
                      bannerImage: bannerController.text.trim(),
                      stripBanner: stripBannerController.text.trim(),
                      bannerTitle: bannerTitleController.text.trim(),
                      headingType: headingType,
                      priority: priority,
                      isActive: isActive,
                      subCollections: editableSubs,
                    );
                    context.read<CollectionBloc>().add(UpdateCollectionEvent(updated));
                  }
                  Navigator.of(ctx).pop();
                },
                label: Text(existingCollection == null ? 'Create Collection' : 'Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteCollection(CollectionModel col) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Collection?'),
        content: Text('Are you sure you want to delete "${col.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              context.read<CollectionBloc>().add(DeleteCollectionEvent(col.id));
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
        return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, productState) {
            return BlocBuilder<CollectionBloc, CollectionState>(
              builder: (context, collectionState) {
            final collections = collectionState.collections;
            final query = _searchController.text.toLowerCase().trim();
            final filtered = collections.where((c) {
              if (query.isEmpty) return true;
              return c.name.toLowerCase().contains(query) ||
                  c.slug.toLowerCase().contains(query) ||
                  c.description.toLowerCase().contains(query);
            }).toList();

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
                      color: const Color(0xFF7C3AED).withValues(alpha: isDark ? 0.12 : 0.06),
                      borderRadius: BorderRadius.circular(themeState.borderRadius),
                      border: Border.all(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.collections_bookmark_rounded, size: 18, color: Color(0xFF7C3AED)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Curated Collections & Crop Sub-Categories',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED)),
                              ),
                              Text(
                                'Powers "Shop By Crop" circular grid and seasonal home shelves. Click "Manage Products" on any card or sub-category to bulk assign products.',
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
                          onPressed: () => context.read<CollectionBloc>().add(const LoadCollections()),
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Refresh'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showAddEditCollectionModal(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Add Collection', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),

                  // Action & Search Bar
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search collections by title or slug...',
                              prefixIcon: const Icon(Icons.search_rounded, size: 20),
                              suffixIcon: _searchController.text.isNotEmpty
                                   ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () => setState(() => _searchController.clear()),
                                    )
                                   : null,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.collections_bookmark_outlined,
                            size: 48,
                            color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No Collections Found',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Create promotional groups like Buy 1 Get 1 or Season Specials',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
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

                        if (collectionState.isLoading) {
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

                        final allProducts = productState.allProducts;

                        return Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: filtered.map((col) {
                            final colProductCount = allProducts.where((p) {
                              final matchCol = p.collectionIds.contains(col.id) ||
                                  p.collectionIds.contains(col.slug) ||
                                  p.assignedCollections.contains(col.id) ||
                                  p.assignedCollections.contains(col.slug) ||
                                  p.assignedCollections.any((c) => c.toLowerCase() == col.name.toLowerCase());
                              if (matchCol) return true;
                              if ((col.slug == 'buy-1-get-1' || col.slug == 'bogo' || col.name.toLowerCase().contains('buy 1 get 1')) && p.buy1get1) {
                                return true;
                              }
                              return p.tags.any((t) => t.toLowerCase() == col.slug.toLowerCase() || t.toLowerCase() == col.name.toLowerCase());
                            }).length;

                            final topImage = col.bannerImage.isNotEmpty ? col.bannerImage : (col.stripBanner ?? '');
                            final hasOnlyStrip = col.bannerImage.isEmpty && (col.stripBanner != null && col.stripBanner!.isNotEmpty);

                            return SizedBox(
                              width: itemWidth,
                              child: Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Banner Image / Strip Banner Header
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(themeState.borderRadius),
                                          ),
                                          child: topImage.isNotEmpty
                                              ? ImagePreview(
                                                  url: topImage,
                                                  width: double.infinity,
                                                  height: hasOnlyStrip ? 65 : 105,
                                                  borderRadius: 0,
                                                  fit: BoxFit.cover,
                                                  enableEnlarge: true,
                                                )
                                              : Container(
                                                  height: 70,
                                                  width: double.infinity,
                                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.collections_bookmark_outlined,
                                                      size: 28,
                                                      color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                                                    ),
                                                  ),
                                                ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withValues(alpha: 0.75),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'PRIORITY: ${col.priority}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: col.headingType == 'strip_banner'
                                                      ? const Color(0xFF3B82F6).withValues(alpha: 0.9)
                                                      : (col.headingType == 'text'
                                                          ? const Color(0xFF8B5CF6).withValues(alpha: 0.9)
                                                          : const Color(0xFF10B981).withValues(alpha: 0.9)),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  col.headingType == 'strip_banner'
                                                      ? 'STRIP BANNER'
                                                      : (col.headingType == 'text' ? 'TEXT' : 'HYBRID'),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 8.5,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF10B981).withValues(alpha: 0.92),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  '$colProductCount Products',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              col.isActive
                                                  ? StatusBadge.success('ACTIVE')
                                                  : StatusBadge.neutral('INACTIVE'),
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
                                                  col.name,
                                                  style: theme.textTheme.titleSmall?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 15,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.playlist_add_check_circle_rounded, size: 19, color: Color(0xFF10B981)),
                                                    tooltip: 'Manage Products ()',
                                                    onPressed: () {
                                                      _showManageProductsDialog(
                                                        parentContext: context,
                                                        targetTitle: col.name,
                                                        targetTagOrSlug: col.slug.isNotEmpty ? col.slug : col.name,
                                                        matchKeys: [col.id, col.slug, col.name],
                                                      );
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.edit_outlined, size: 18),
                                                    tooltip: 'Edit Collection',
                                                    onPressed: () =>
                                                        _showAddEditCollectionModal(existingCollection: col),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete_outline,
                                                        size: 18, color: Color(0xFFEF4444)),
                                                    tooltip: 'Delete Collection',
                                                    onPressed: () => _confirmDeleteCollection(col),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'slug: ${col.slug}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontFamily: 'monospace',
                                              color: themeState.currentPalette.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (col.bannerTitle.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(Icons.title_rounded, size: 14, color: Color(0xFF8B5CF6)),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    col.bannerTitle,
                                                    style: const TextStyle(
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFF8B5CF6),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          if (col.description.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              col.description,
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
                                          if (col.stripBanner != null && col.stripBanner!.isNotEmpty && col.bannerImage.isNotEmpty) ...[
                                            const SizedBox(height: 10),
                                            Container(
                                              height: 48,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                                ),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: ImagePreview(
                                                url: col.stripBanner!,
                                                width: double.infinity,
                                                height: 48,
                                                fit: BoxFit.cover,
                                                enableEnlarge: true,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 12),
                                          const Divider(height: 1),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Sub-Categories (${col.subCollections.length})',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  _showAddEditSubCollectionDialog(
                                                    parentContext: context,
                                                    onSave: (newSub) {
                                                      final updatedList = [...col.subCollections, newSub];
                                                      context.read<CollectionBloc>().add(
                                                            UpdateCollectionEvent(col.copyWith(subCollections: updatedList)),
                                                          );
                                                    },
                                                  );
                                                },
                                                child: Text(
                                                  '+ Add Sub-Category',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: themeState.currentPalette.primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          if (col.subCollections.isEmpty)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                                ),
                                              ),
                                              child: Text(
                                                'No sub-categories defined. Click "+ Add Sub-Category" to configure.',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                                ),
                                              ),
                                            )
                                          else
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: col.subCollections.asMap().entries.map((entry) {
                                                final subIdx = entry.key;
                                                final sub = entry.value;
                                                final isSpecial = sub.name.toLowerCase().contains('buy') || sub.name.toLowerCase().contains('crop');

                                                final liveSubCount = allProducts.where((p) {
                                                  final matchSub = p.subCollectionIds.contains(sub.id) ||
                                                      p.subCollectionIds.contains(sub.slug) ||
                                                      p.assignedCollections.contains(sub.id) ||
                                                      p.assignedCollections.contains(sub.slug) ||
                                                      p.assignedCollections.any((c) => c.toLowerCase() == sub.name.toLowerCase());
                                                  if (matchSub) return true;
                                                  final matchTag = p.tags.any((t) => t.toLowerCase() == sub.slug.toLowerCase() || t.toLowerCase() == sub.name.toLowerCase());
                                                  if (matchTag) return true;
                                                  final matchTitle = p.title.toLowerCase().contains(sub.name.toLowerCase()) ||
                                                      (p.description?.toLowerCase().contains(sub.name.toLowerCase()) ?? false);
                                                  return matchTitle;
                                                }).length;

                                                final displaySubCount = (sub.count != null && sub.count!.isNotEmpty)
                                                    ? sub.count!
                                                    : '$liveSubCount Products';

                                                return InkWell(
                                                  borderRadius: BorderRadius.circular(6),
                                                  onTap: () {
                                                    _showAddEditSubCollectionDialog(
                                                      parentContext: context,
                                                      existingSub: sub,
                                                      onDelete: () {
                                                        final updatedSubs = List<SubCollectionModel>.from(col.subCollections);
                                                        updatedSubs.removeAt(subIdx);
                                                        context.read<CollectionBloc>().add(
                                                              UpdateCollectionEvent(col.copyWith(subCollections: updatedSubs)),
                                                            );
                                                      },
                                                      onSave: (updatedSub) {
                                                        final updatedSubs = List<SubCollectionModel>.from(col.subCollections);
                                                        updatedSubs[subIdx] = updatedSub;
                                                        context.read<CollectionBloc>().add(
                                                              UpdateCollectionEvent(col.copyWith(subCollections: updatedSubs)),
                                                            );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 8, vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: isSpecial
                                                          ? const Color(0xFF8B5CF6).withValues(alpha: 0.12)
                                                          : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: Border.all(
                                                        color: isSpecial
                                                            ? const Color(0xFF8B5CF6).withValues(alpha: 0.35)
                                                            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        if (sub.image != null && sub.image!.isNotEmpty) ...[
                                                          ClipRRect(
                                                            borderRadius: BorderRadius.circular(4),
                                                            child: ImagePreview(
                                                              url: sub.image!,
                                                              width: 22,
                                                              height: 22,
                                                              fit: BoxFit.cover,
                                                              enableEnlarge: true,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 5),
                                                        ] else ...[
                                                          Icon(
                                                            isSpecial ? Icons.auto_awesome_rounded : Icons.eco_rounded,
                                                            size: 12,
                                                            color: isSpecial ? const Color(0xFF8B5CF6) : const Color(0xFF10B981),
                                                          ),
                                                          const SizedBox(width: 4),
                                                        ],
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              sub.name,
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                fontWeight: FontWeight.w600,
                                                                color: isSpecial
                                                                    ? const Color(0xFF8B5CF6)
                                                                    : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                                                              ),
                                                            ),
                                                            Text(
                                                              displaySubCount,
                                                              style: TextStyle(
                                                                fontSize: 9,
                                                                fontWeight: FontWeight.w500,
                                                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(width: 4),
                                                        InkWell(
                                                          onTap: () {
                                                            _showManageProductsDialog(
                                                              parentContext: context,
                                                              targetTitle: '${col.name} > ${sub.name}',
                                                              targetTagOrSlug: sub.slug.isNotEmpty ? sub.slug : sub.name,
                                                              matchKeys: [sub.id ?? '', sub.slug, sub.name],
                                                            );
                                                          },
                                                          child: const Padding(
                                                            padding: EdgeInsets.symmetric(horizontal: 2),
                                                            child: Tooltip(
                                                              message: 'Manage Products for this Sub-Category',
                                                              child: Icon(Icons.playlist_add_check_rounded, size: 14, color: Color(0xFF10B981)),
                                                            ),
                                                          ),
                                                        ),
                                                        const Icon(Icons.edit_outlined, size: 12, color: Color(0xFF94A3B8)),
                                                      ],
                                                    ),
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
      },
    );
  }
}
