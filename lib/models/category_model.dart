class SubCategory {
  final String id;
  final String name;

  SubCategory({required this.id, required this.name});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
      };
}

class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? title;
  final String? description;
  final String? bannerImage;
  final String? stripBanner;
  final String? iconImage;
  final String? cataloguePdf;
  final List<SubCategory> subCategories;
  final int productsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.title,
    this.description,
    this.bannerImage,
    this.stripBanner,
    this.iconImage,
    this.cataloguePdf,
    this.subCategories = const [],
    this.productsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    List<SubCategory> subCats = [];
    if (json['subCategories'] != null && json['subCategories'] is List) {
      subCats = (json['subCategories'] as List)
          .map((item) => SubCategory.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? json['handle'] ?? '',
      title: json['title'] ?? json['bannerTitle'],
      description: json['description'],
      bannerImage: json['bannerImage'] ?? (json['image'] != null ? json['image']['src'] : null) ?? json['imageUrl'],
      stripBanner: json['stripBanner'],
      iconImage: json['iconImage'],
      cataloguePdf: json['cataloguePdf'],
      subCategories: subCats,
      productsCount: json['productsCount'] ?? json['products_count'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'slug': slug,
        'title': title,
        'description': description,
        'bannerImage': bannerImage,
        'stripBanner': stripBanner,
        'iconImage': iconImage,
        'cataloguePdf': cataloguePdf,
        'subCategories': subCategories.map((s) => s.toJson()).toList(),
        'productsCount': productsCount,
      };

  CategoryModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? title,
    String? description,
    String? bannerImage,
    String? stripBanner,
    String? iconImage,
    String? cataloguePdf,
    List<SubCategory>? subCategories,
    int? productsCount,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      description: description ?? this.description,
      bannerImage: bannerImage ?? this.bannerImage,
      stripBanner: stripBanner ?? this.stripBanner,
      iconImage: iconImage ?? this.iconImage,
      cataloguePdf: cataloguePdf ?? this.cataloguePdf,
      subCategories: subCategories ?? this.subCategories,
      productsCount: productsCount ?? this.productsCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
