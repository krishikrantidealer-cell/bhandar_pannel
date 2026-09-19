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
    return ProductVariant(
      id: json['_id'] ?? json['id']?.toString() ?? '',
      title: json['title'] ?? 'Default',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      mrp: (json['mrp'] is num) ? (json['mrp'] as num).toDouble() : (json['compareAtPrice'] is num ? (json['compareAtPrice'] as num).toDouble() : double.tryParse(json['mrp']?.toString() ?? '0') ?? 0.0),
      inventoryQuantity: json['inventoryQuantity'] ?? json['inventory_quantity'] ?? json['stock'] ?? 0,
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
  final String? subCategory;
  final String brand;
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
    this.subCategory,
    this.brand = 'Krishi Bhandar',
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

  String get mainImage => images.isNotEmpty ? images.first : 'https://placehold.co/400x400/png?text=Bhandar+Product';
  double get discountPercent => mrp > price && mrp > 0 ? ((mrp - price) / mrp) * 100 : 0.0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<String> imgList = [];
    if (json['images'] != null && json['images'] is List) {
      for (var img in json['images']) {
        if (img is String) {
          imgList.add(img);
        } else if (img is Map && img.containsKey('src')) {
          imgList.add(img['src']);
        } else if (img is Map && img.containsKey('url')) {
          imgList.add(img['url']);
        }
      }
    } else if (json['image'] != null) {
      if (json['image'] is String) {
        imgList.add(json['image']);
      } else if (json['image'] is Map && json['image'].containsKey('src')) {
        imgList.add(json['image']['src']);
      }
    }

    List<ProductVariant> varList = [];
    if (json['variants'] != null && json['variants'] is List) {
      varList = (json['variants'] as List)
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

    int totalStock = json['stock'] ?? json['inventoryQuantity'] ?? 0;
    if (totalStock == 0 && varList.isNotEmpty) {
      totalStock = varList.fold(0, (sum, v) => sum + v.inventoryQuantity);
    }

    return ProductModel(
      id: json['_id'] ?? json['id']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? 'Untitled Product',
      description: json['description'] ?? json['body_html'],
      category: json['category'] ?? json['product_type'] ?? 'General',
      subCategory: json['subCategory'],
      brand: json['brand'] ?? json['vendor'] ?? 'Krishi Bhandar',
      images: imgList,
      variants: varList,
      price: basePrice,
      mrp: baseMrp >= basePrice ? baseMrp : basePrice,
      stock: totalStock,
      inStock: json['inStock'] ?? (totalStock > 0),
      isPublished: json['isPublished'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 4.5,
      reviewsCount: json['reviewsCount'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'description': description,
        'category': category,
        'subCategory': subCategory,
        'brand': brand,
        'images': images,
        'variants': variants.map((v) => v.toJson()).toList(),
        'price': price,
        'mrp': mrp,
        'stock': stock,
        'inStock': inStock,
        'isPublished': isPublished,
        'isFeatured': isFeatured,
      };

  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? subCategory,
    String? brand,
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
      subCategory: subCategory ?? this.subCategory,
      brand: brand ?? this.brand,
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
