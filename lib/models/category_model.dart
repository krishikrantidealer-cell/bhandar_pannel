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
    this.productsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final catName = (json['name'] ?? json['title'] ?? '').toString().trim();

    // Safe extraction of bannerImage
    String? bannerImg;
    if (json['bannerImage'] != null && json['bannerImage'].toString().trim().isNotEmpty) {
      bannerImg = json['bannerImage'].toString().trim();
    } else if (json['image'] is Map && json['image']['src'] != null) {
      bannerImg = json['image']['src'].toString().trim();
    } else if (json['image'] != null && json['image'].toString().trim().isNotEmpty) {
      bannerImg = json['image'].toString().trim();
    } else if (json['imageUrl'] != null && json['imageUrl'].toString().trim().isNotEmpty) {
      bannerImg = json['imageUrl'].toString().trim();
    } else if (json['icon'] != null && json['icon'].toString().trim().isNotEmpty) {
      bannerImg = json['icon'].toString().trim();
    } else if (json['iconImage'] != null && json['iconImage'].toString().trim().isNotEmpty) {
      bannerImg = json['iconImage'].toString().trim();
    }

    final slug = (json['slug'] ?? json['handle'] ?? catName.toLowerCase().replaceAll(' ', '-')).toString().trim();

    // Safe extraction of stripBanner
    String? stripImg;
    if (json['stripBanner'] != null && json['stripBanner'].toString().trim().isNotEmpty) {
      stripImg = json['stripBanner'].toString().trim();
    } else if (json['stripBannerImage'] != null && json['stripBannerImage'].toString().trim().isNotEmpty) {
      stripImg = json['stripBannerImage'].toString().trim();
    } else if (json['strip'] != null && json['strip'].toString().trim().isNotEmpty) {
      stripImg = json['strip'].toString().trim();
    }

    // Safe extraction of iconImage
    String? iconImg;
    if (json['iconImage'] != null && json['iconImage'].toString().trim().isNotEmpty) {
      iconImg = json['iconImage'].toString().trim();
    } else if (json['icon'] != null && json['icon'].toString().trim().isNotEmpty) {
      iconImg = json['icon'].toString().trim();
    }

    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: catName,
      slug: slug,
      title: json['title'] ?? json['bannerTitle'],
      description: json['description'],
      bannerImage: bannerImg,
      stripBanner: stripImg,
      iconImage: iconImg,
      cataloguePdf: json['cataloguePdf'],
      productsCount: json['productsCount'] ?? json['products_count'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
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
        'image': bannerImage,
        'imageUrl': bannerImage,
        'iconImage': iconImage,
        'cataloguePdf': cataloguePdf,
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
      productsCount: productsCount ?? this.productsCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
