import 'category_model.dart';

class ProductVariant {
  final String id;
  final String title;
  final double price;
  final double mrp;
  final int inventoryQuantity;
  final String? sku;
  final String? weight;

  ProductVariant({
    required this.id,
    required this.title,
    required this.price,
    required this.mrp,
    this.inventoryQuantity = 0,
    this.sku,
    this.weight,
  });

  double get discountPercent => mrp > price && mrp > 0 ? ((mrp - price) / mrp) * 100 : 0.0;

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    int parsedStock = 0;
    final rawStock = json['inventoryQuantity'] ?? json['inventory_quantity'] ?? json['stock'];
    if (rawStock is num) {
      parsedStock = rawStock.toInt();
    } else if (rawStock != null) {
      parsedStock = int.tryParse(rawStock.toString()) ?? 0;
    }

    double parsedPrice = 0.0;
    final rawPrice = json['price'];
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice != null) {
      parsedPrice = double.tryParse(rawPrice.toString()) ?? 0.0;
    }

    double parsedMrp = parsedPrice;
    final rawMrp = json['mrp'] ?? json['compareAtPrice'] ?? json['compare_at_price'];
    if (rawMrp is num) {
      parsedMrp = rawMrp.toDouble();
    } else if (rawMrp != null) {
      parsedMrp = double.tryParse(rawMrp.toString()) ?? parsedPrice;
    }

    return ProductVariant(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? json['option'] ?? 'Default').toString(),
      price: parsedPrice,
      mrp: parsedMrp >= parsedPrice ? parsedMrp : parsedPrice,
      inventoryQuantity: parsedStock,
      sku: json['sku']?.toString(),
      weight: json['weight']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'mrp': mrp,
        'inventoryQuantity': inventoryQuantity,
        'sku': sku,
        'weight': weight,
      };
}

class ProductModel {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String? categoryId;
  final List<String> categoryIds;
  final String? subCategory;
  final String? productType;
  final List<String> tags;
  final List<String> assignedCollections;
  final List<String> collectionIds;
  final List<String> subCollectionIds;
  final String brand;
  final String status;
  final bool buy1get1;
  final List<String> images;
  final List<ProductVariant> variants;
  final double price;
  final double mrp;
  final int stock;
  final bool inStock;
  final bool isPublished;
  final bool isFeatured;
  final double rating;
  final int reviewsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.categoryId,
    this.categoryIds = const [],
    this.subCategory,
    this.productType,
    this.tags = const [],
    this.assignedCollections = const [],
    this.collectionIds = const [],
    this.subCollectionIds = const [],
    this.brand = 'Krishi Bhandar',
    this.status = 'active',
    this.buy1get1 = false,
    this.images = const [],
    this.variants = const [],
    required this.price,
    required this.mrp,
    this.stock = 0,
    this.inStock = true,
    this.isPublished = true,
    this.isFeatured = false,
    this.rating = 4.5,
    this.reviewsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  String get vendor => brand;
  String? get sku => variants.isNotEmpty && variants.first.sku != null && variants.first.sku!.isNotEmpty
      ? variants.first.sku
      : null;
  String get optionTitle => variants.isNotEmpty ? variants.first.title : 'Default';
  String get mainImage => images.isNotEmpty ? images.first : 'https://placehold.co/400x400/png?text=Bhandar+Product';
  double get discountPercent => mrp > price && mrp > 0 ? ((mrp - price) / mrp) * 100 : 0.0;
  List<String> get collections => assignedCollections;

  /// Resolves all distinct Category models associated with this product
  List<CategoryModel> resolveAllCategories(List<CategoryModel> categories) {
    final allIds = <String>[
      if (categoryId != null && categoryId!.isNotEmpty) categoryId!,
      ...categoryIds,
      if (category.isNotEmpty && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(category)) category,
    ];

    final matched = <CategoryModel>[];
    for (final id in allIds) {
      final found = categories.where((c) => c.id == id || c.slug == id).firstOrNull;
      if (found != null && !matched.contains(found)) {
        matched.add(found);
      }
    }

    if (matched.isEmpty && category.isNotEmpty && !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(category)) {
      final foundByName = categories.where((c) => c.name.toLowerCase() == category.toLowerCase()).firstOrNull;
      if (foundByName != null) matched.add(foundByName);
    }
    return matched;
  }

  /// Resolves all human-readable category names
  List<String> resolveAllCategoryNames(List<CategoryModel> categories) {
    final cats = resolveAllCategories(categories);
    final names = cats.map((c) => c.name).toList();
    if (names.isEmpty) {
      if (category.isNotEmpty && !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(category) && category != 'General') {
        names.add(category);
      } else {
        names.add('General');
      }
    }
    return names;
  }

  /// Resolves the primary category model from category & categoryIds
  CategoryModel? resolvePrimaryCategory(List<CategoryModel> categories) {
    final matchedCats = resolveAllCategories(categories);
    if (matchedCats.isEmpty) return null;

    // Prioritize main parent categories
    const topParents = [
      'fungicides',
      'insecticides',
      'herbicides',
      'pgrs',
      'plant-growth-regulators',
      'fertilizers',
      'bio products',
      'bio-pesticides',
      'seeds',
      'micronutrients',
      'antibiotics',
      'organic fertilizers'
    ];
    for (final cat in matchedCats) {
      if (topParents.contains(cat.slug.toLowerCase()) || topParents.contains(cat.name.toLowerCase())) {
        return cat;
      }
    }

    return matchedCats.first;
  }

  /// Resolves the actual human-readable Category name (e.g. "Fungicides")
  String resolveCategoryName(List<CategoryModel> categories) {
    final primary = resolvePrimaryCategory(categories);
    if (primary != null) return primary.name;
    if (category.isNotEmpty && !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(category) && category != 'General') {
      return category;
    }
    return 'General';
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<String> imgList = [];
    if (json['images'] != null && json['images'] is List) {
      for (var img in json['images']) {
        if (img is String) {
          if (img.isNotEmpty) imgList.add(img);
        } else if (img is Map) {
          final url = img['original'] ?? img['medium'] ?? img['low'] ?? img['src'] ?? img['url'];
          if (url != null && url.toString().isNotEmpty) {
            imgList.add(url.toString());
          }
        }
      }
    } else if (json['image'] != null) {
      if (json['image'] is String && json['image'].toString().isNotEmpty) {
        imgList.add(json['image'].toString());
      } else if (json['image'] is Map) {
        final url = json['image']['original'] ?? json['image']['medium'] ?? json['image']['src'] ?? json['image']['url'];
        if (url != null && url.toString().isNotEmpty) {
          imgList.add(url.toString());
        }
      }
    }

    List<ProductVariant> varList = [];
    if (json['variants'] != null && json['variants'] is List) {
      varList = (json['variants'] as List)
          .whereType<Map>()
          .map((v) => ProductVariant.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }

    double basePrice = 0.0;
    if (json['price'] != null) {
      basePrice = (json['price'] is num) ? (json['price'] as num).toDouble() : double.tryParse(json['price'].toString()) ?? 0.0;
    } else if (varList.isNotEmpty) {
      basePrice = varList.first.price;
    }

    double baseMrp = basePrice;
    if (json['mrp'] != null || json['compareAtPrice'] != null) {
      final raw = json['mrp'] ?? json['compareAtPrice'];
      baseMrp = (raw is num) ? raw.toDouble() : double.tryParse(raw.toString()) ?? basePrice;
    } else if (varList.isNotEmpty && varList.first.mrp > 0) {
      baseMrp = varList.first.mrp;
    }

    int totalStock = 0;
    final rawStock = json['stock'] ?? json['inventoryQuantity'];
    if (rawStock is num) {
      totalStock = rawStock.toInt();
    } else if (rawStock != null) {
      totalStock = int.tryParse(rawStock.toString()) ?? 0;
    }
    if (totalStock == 0 && varList.isNotEmpty) {
      totalStock = varList.fold(0, (sum, v) => sum + v.inventoryQuantity);
    }

    String? rawCatId;
    String catName = 'General';

    if (json['category'] != null) {
      if (json['category'] is Map) {
        catName = json['category']['name']?.toString() ?? json['category']['title']?.toString() ?? 'General';
        rawCatId = json['category']['_id']?.toString() ?? json['category']['id']?.toString();
      } else {
        catName = json['category'].toString();
      }
    }

    if (json['categoryId'] != null) {
      if (json['categoryId'] is Map) {
        catName = json['categoryId']['name']?.toString() ?? json['categoryId']['title']?.toString() ?? catName;
        rawCatId = json['categoryId']['_id']?.toString() ?? json['categoryId']['id']?.toString() ?? rawCatId;
      } else {
        rawCatId ??= json['categoryId'].toString();
        if (catName == 'General') catName = json['categoryId'].toString();
      }
    }

    final List<String> catIdsList = [];
    if (json['categoryIds'] != null && json['categoryIds'] is List && (json['categoryIds'] as List).isNotEmpty) {
      for (final item in json['categoryIds'] as List) {
        if (item is Map) {
          final cid = item['_id'] ?? item['id'];
          if (cid != null) catIdsList.add(cid.toString());
          catName = item['name']?.toString() ?? item['title']?.toString() ?? catName;
        } else if (item != null) {
          catIdsList.add(item.toString());
        }
      }
    }
    if (rawCatId != null && !catIdsList.contains(rawCatId)) {
      catIdsList.add(rawCatId);
    }

    if (catName == 'General' && json['productType'] != null && json['productType'].toString().isNotEmpty) {
      catName = json['productType'].toString();
    }

    final List<String> tagList = [];
    if (json['tags'] != null && json['tags'] is List) {
      for (final t in json['tags']) {
        if (t != null && t.toString().isNotEmpty) {
          tagList.add(t.toString());
        }
      }
    }

    final List<String> collectionList = [];
    final rawCollections = json['assignedCollections'] ?? json['collections'] ?? json['assigned_collections'];
    if (rawCollections != null && rawCollections is List) {
      for (final c in rawCollections) {
        if (c != null && c.toString().isNotEmpty) {
          collectionList.add(c.toString());
        }
      }
    }

    final List<String> colIdsList = [];
    final rawColIds = json['collectionIds'] ?? json['collection_ids'] ?? json['collectionId'];
    if (rawColIds is List) {
      for (final c in rawColIds) {
        if (c != null && c.toString().isNotEmpty) colIdsList.add(c.toString());
      }
    } else if (rawColIds != null && rawColIds.toString().isNotEmpty) {
      colIdsList.add(rawColIds.toString());
    }

    final List<String> subColIdsList = [];
    final rawSubColIds = json['subCollectionIds'] ?? json['sub_collection_ids'] ?? json['subCollectionId'];
    if (rawSubColIds is List) {
      for (final s in rawSubColIds) {
        if (s != null && s.toString().isNotEmpty) subColIdsList.add(s.toString());
      }
    } else if (rawSubColIds != null && rawSubColIds.toString().isNotEmpty) {
      subColIdsList.add(rawSubColIds.toString());
    }

    String? resolvedSubCat = json['subCategory']?.toString() ??
        json['subcategory']?.toString() ??
        json['subCategoryId']?.toString() ??
        json['sub_category']?.toString();

    final pType = json['productType']?.toString();
    if (resolvedSubCat == null && pType != null && pType.isNotEmpty && pType.toLowerCase() != catName.toLowerCase()) {
      resolvedSubCat = pType;
    }

    final productStatus = (json['status']?.toString() ?? 'active').toLowerCase();
    final isBogo = json['buy1get1'] == true || (json['title']?.toString().contains('1+1') ?? false);

    return ProductModel(
      id: (json['_id'] ?? json['id'] ?? json['handle'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? 'Untitled Product').toString(),
      description: json['description']?.toString() ?? json['bodyHtml']?.toString() ?? json['body_html']?.toString(),
      category: catName,
      categoryId: rawCatId,
      categoryIds: catIdsList,
      subCategory: resolvedSubCat,
      productType: pType,
      tags: tagList,
      assignedCollections: collectionList,
      collectionIds: colIdsList,
      subCollectionIds: subColIdsList,
      brand: (json['vendor'] ?? json['brand'] ?? 'Krishi Bhandar').toString(),
      status: productStatus,
      buy1get1: isBogo,
      images: imgList,
      variants: varList,
      price: basePrice,
      mrp: baseMrp >= basePrice ? baseMrp : basePrice,
      stock: totalStock,
      inStock: json['inStock'] == true || (productStatus == 'active'),
      isPublished: json['isPublished'] != false && productStatus != 'draft' && productStatus != 'archived',
      isFeatured: json['isFeatured'] == true || isBogo,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 4.5,
      reviewsCount: (json['reviewsCount'] is num) ? (json['reviewsCount'] as num).toInt() : 0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'description': description,
        'category': category,
        if (categoryId != null) 'categoryId': categoryId,
        'categoryIds': categoryIds,
        'subCategory': subCategory,
        'productType': productType,
        'tags': tags,
        'assignedCollections': assignedCollections,
        if (collectionIds.isNotEmpty) 'collectionIds': collectionIds,
        if (subCollectionIds.isNotEmpty) 'subCollectionIds': subCollectionIds,
        'vendor': brand,
        'brand': brand,
        'status': status,
        'buy1get1': buy1get1,
        'images': images.map((u) => {'original': u, 'medium': u, 'low': u}).toList(),
        'variants': variants.map((v) => v.toJson()).toList(),
        'price': price.toStringAsFixed(2),
        'compareAtPrice': mrp.toStringAsFixed(2),
        'mrp': mrp,
        'inStock': inStock,
        'isPublished': isPublished,
        'isFeatured': isFeatured,
      };

  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? categoryId,
    List<String>? categoryIds,
    String? subCategory,
    String? productType,
    List<String>? tags,
    List<String>? assignedCollections,
    List<String>? collectionIds,
    List<String>? subCollectionIds,
    String? brand,
    String? status,
    bool? buy1get1,
    List<String>? images,
    List<ProductVariant>? variants,
    double? price,
    double? mrp,
    int? stock,
    bool? inStock,
    bool? isPublished,
    bool? isFeatured,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      categoryIds: categoryIds ?? this.categoryIds,
      subCategory: subCategory ?? this.subCategory,
      productType: productType ?? this.productType,
      tags: tags ?? this.tags,
      assignedCollections: assignedCollections ?? this.assignedCollections,
      collectionIds: collectionIds ?? this.collectionIds,
      subCollectionIds: subCollectionIds ?? this.subCollectionIds,
      brand: brand ?? this.brand,
      status: status ?? this.status,
      buy1get1: buy1get1 ?? this.buy1get1,
      images: images ?? this.images,
      variants: variants ?? this.variants,
      price: price ?? this.price,
      mrp: mrp ?? this.mrp,
      stock: stock ?? this.stock,
      inStock: inStock ?? this.inStock,
      isPublished: isPublished ?? this.isPublished,
      isFeatured: isFeatured ?? this.isFeatured,
      rating: rating,
      reviewsCount: reviewsCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
