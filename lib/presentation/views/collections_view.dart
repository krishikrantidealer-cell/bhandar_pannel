import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/collections/collection_bloc.dart';
import '../../logic/collections/collection_event.dart';
import '../../logic/collections/collection_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_state.dart';
import '../../models/collection_model.dart';
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

  void _showAddEditCollectionModal({CollectionModel? existingCollection}) {
    final nameController = TextEditingController(text: existingCollection?.name ?? '');
    final slugController = TextEditingController(text: existingCollection?.slug ?? '');
    final descController = TextEditingController(text: existingCollection?.description ?? '');
    final bannerController = TextEditingController(text: existingCollection?.bannerImage ?? '');
    final bannerTitleController = TextEditingController(text: existingCollection?.bannerTitle ?? '');
    final priorityController = TextEditingController(
      text: existingCollection != null ? existingCollection.priority.toString() : '0',
    );
    final subColController = TextEditingController(
      text: existingCollection?.subCollections.map((s) => s.name).join(', ') ?? '',
    );
    bool isActive = existingCollection?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text(existingCollection == null ? 'Add New Collection' : 'Edit Collection'),
          content: SizedBox(
            width: 550,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Collection Name *',
                      hintText: 'e.g. Monsoon Special Care',
                    ),
                    onChanged: (val) {
                      if (existingCollection == null) {
                        slugController.text =
                            val.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9\-]'), '');
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: slugController,
                    decoration: const InputDecoration(
                      labelText: 'Collection Slug / Key *',
                      hintText: 'monsoon-special',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: bannerTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Banner / Header Title',
                      hintText: 'Kharif Crop Rain Defense',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: bannerController,
                    decoration: const InputDecoration(
                      labelText: 'Banner Image URL',
                      hintText: 'https://storage.googleapis.com/...',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: priorityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Display Priority (Higher = Appears First)',
                      hintText: '10',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: subColController,
                    decoration: const InputDecoration(
                      labelText: 'Sub-collections (Comma separated)',
                      hintText: 'Top Sellers, New Releases, Combos',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Brief summary of this product group',
                    ),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    title: const Text('Active on Apps & Web', style: TextStyle(fontWeight: FontWeight.w600)),
                    value: isActive,
                    contentPadding: EdgeInsets.zero,
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
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final slug = slugController.text.trim();
                if (name.isEmpty) return;

                final subCols = subColController.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .map((s) => SubCollectionModel(
                          name: s,
                          slug: s.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9\-]'), ''),
                          isActive: true,
                        ))
                    .toList();

                final priority = int.tryParse(priorityController.text.trim()) ?? 0;

                if (existingCollection == null) {
                  final newCol = CollectionModel(
                    id: 'col_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    slug: slug.isNotEmpty ? slug : name.toLowerCase(),
                    description: descController.text.trim(),
                    bannerImage: bannerController.text.trim(),
                    bannerTitle: bannerTitleController.text.trim(),
                    priority: priority,
                    isActive: isActive,
                    subCollections: subCols,
                  );
                  context.read<CollectionBloc>().add(AddCollectionEvent(newCol));
                } else {
                  final updated = existingCollection.copyWith(
                    name: name,
                    slug: slug,
                    description: descController.text.trim(),
                    bannerImage: bannerController.text.trim(),
                    bannerTitle: bannerTitleController.text.trim(),
                    priority: priority,
                    isActive: isActive,
                    subCollections: subCols,
                  );
                  context.read<CollectionBloc>().add(UpdateCollectionEvent(updated));
                }
                Navigator.of(ctx).pop();
              },
              child: Text(existingCollection == null ? 'Create Collection' : 'Save Changes'),
            ),
          ],
        ),
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
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditCollectionModal(),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Add Collection'),
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
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
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

                        if (collectionState.isLoading) {
                          return Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: List.generate(
                              6,
                              (index) => SizedBox(
                                width: itemWidth,
                                child: CategoryCardSkeleton(borderRadius: themeState.borderRadius),
                              ),
                            ),
                          );
                        }

                        return Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: filtered.map((col) {
                            return SizedBox(
                              width: itemWidth,
                              child: Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Banner Image
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(themeState.borderRadius),
                                          ),
                                          child: ImagePreview(
                                            url: col.bannerImage,
                                            width: double.infinity,
                                            height: 130,
                                            borderRadius: 0,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.75),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'PRIORITY: ${col.priority}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: col.isActive
                                              ? StatusBadge.success('ACTIVE')
                                              : StatusBadge.neutral('INACTIVE'),
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
                                          if (col.subCollections.isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: col.subCollections.map((sub) {
                                                return Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? const Color(0xFF334155)
                                                        : const Color(0xFFF1F5F9),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    sub.name,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                      color: isDark
                                                          ? const Color(0xFFCBD5E1)
                                                          : const Color(0xFF475569),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
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
  }
}
