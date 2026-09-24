class SubCategory {
  final String id;
  final String name;

  SubCategory({required this.id, required this.name});

  factory SubCategory.fromJson(dynamic json) {
    if (json is String) {
      return SubCategory(id: json, name: json);
    } else if (json is Map) {
      final nameStr = (json['name'] ?? json['title'] ?? json['subCategoryName'] ?? json['label'] ?? json['slug'] ?? '').toString();
      final idStr = (json['_id'] ?? json['id'] ?? json['slug'] ?? nameStr).toString();
      return SubCategory(id: idStr, name: nameStr.isNotEmpty ? nameStr : idStr);
    }
    return SubCategory(id: '', name: '');
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
    final rawSubCats = json['subCategories'] ??
        json['subcategories'] ??
        json['sub_categories'] ??
        json['subCategory'] ??
        json['sub_category'] ??
        json['children'];

    if (rawSubCats != null && rawSubCats is List) {
      for (final item in rawSubCats) {
        if (item is Map) {
          final sub = SubCategory.fromJson(Map<String, dynamic>.from(item));
          if (sub.name.isNotEmpty) subCats.add(sub);
        } else if (item is String && item.trim().isNotEmpty) {
          subCats.add(SubCategory(id: item.trim(), name: item.trim()));
        }
      }
    }

    final catName = (json['name'] ?? '').toString().trim();

    // If subcategories in DB document are empty, populate standard agricultural subcategories
    if (subCats.isEmpty && catName.isNotEmpty) {
      final lowerName = catName.toLowerCase();
      if (lowerName.contains('fungicide')) {
        subCats = [
          SubCategory(id: 'sub_bio_fung', name: 'Bio-Fungicide'),
          SubCategory(id: 'sub_chem_fung', name: 'Chemical-Fungicide'),
          SubCategory(id: 'sub_org_fung', name: 'Organic-Fungicide'),
          SubCategory(id: 'sub_sys_fung', name: 'Systemic Fungicide'),
          SubCategory(id: 'sub_cont_fung', name: 'Contact Fungicide'),
        ];
      } else if (lowerName.contains('insecticide')) {
        subCats = [
          SubCategory(id: 'sub_bio_ins', name: 'Bio-Insecticide'),
          SubCategory(id: 'sub_chem_ins', name: 'Chemical-Insecticide'),
          SubCategory(id: 'sub_org_ins', name: 'Organic-Insecticide'),
          SubCategory(id: 'sub_suck_pest', name: 'Sucking Pest Control'),
          SubCategory(id: 'sub_larvicide', name: 'Larvicide'),
        ];
      } else if (lowerName.contains('herbicide') || lowerName.contains('weedicide')) {
        subCats = [
          SubCategory(id: 'sub_sel_herb', name: 'Selective Herbicide'),
          SubCategory(id: 'sub_nonsel_herb', name: 'Non-Selective Herbicide'),
          SubCategory(id: 'sub_pre_herb', name: 'Pre-Emergence'),
          SubCategory(id: 'sub_post_herb', name: 'Post-Emergence'),
        ];
      } else if (lowerName.contains('fertilizer') || lowerName.contains('fert')) {
        subCats = [
          SubCategory(id: 'sub_water_fert', name: 'Water Soluble Fertilizers'),
          SubCategory(id: 'sub_org_fert', name: 'Organic Fertilizers'),
          SubCategory(id: 'sub_npk', name: 'NPK Special'),
          SubCategory(id: 'sub_micro', name: 'Micronutrients'),
          SubCategory(id: 'sub_bio_fert', name: 'Bio-Fertilizers'),
        ];
      } else if (lowerName.contains('pgr') || lowerName.contains('growth')) {
        subCats = [
          SubCategory(id: 'sub_promoter', name: 'Plant Growth Promoters'),
          SubCategory(id: 'sub_regulator', name: 'Plant Growth Regulators'),
          SubCategory(id: 'sub_flower', name: 'Flowering Stimulants'),
          SubCategory(id: 'sub_yield', name: 'Yield Enhancers'),
        ];
      } else if (lowerName.contains('bio')) {
        subCats = [
          SubCategory(id: 'sub_bio_pest', name: 'Bio-Pesticides'),
          SubCategory(id: 'sub_bio_fung', name: 'Bio-Fungicides'),
          SubCategory(id: 'sub_bio_stim', name: 'Bio-Stimulants'),
          SubCategory(id: 'sub_bio_npk', name: 'Bio-NPK'),
        ];
      } else if (lowerName.contains('micro') || lowerName.contains('nutrient')) {
        subCats = [
          SubCategory(id: 'sub_zinc', name: 'Zinc & Boron'),
          SubCategory(id: 'sub_chelated', name: 'Chelated Micronutrients'),
          SubCategory(id: 'sub_foliar_spray', name: 'Foliar Spray Mix'),
          SubCategory(id: 'sub_soil_app', name: 'Soil Application'),
        ];
      } else if (lowerName.contains('antibiotic') || lowerName.contains('bactericide')) {
        subCats = [
          SubCategory(id: 'sub_plant_anti', name: 'Plant Antibiotics'),
          SubCategory(id: 'sub_bactericide', name: 'Bactericides'),
          SubCategory(id: 'sub_bio_anti', name: 'Bio-Antibacterial'),
        ];
      }
    }

    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: catName,
      slug: json['slug'] ?? json['handle'] ?? catName.toLowerCase().replaceAll(' ', '-'),
      title: json['title'] ?? json['bannerTitle'],
      description: json['description'],
      bannerImage: json['bannerImage'] ?? (json['image'] != null ? json['image']['src'] : null) ?? json['imageUrl'],
      stripBanner: json['stripBanner'],
      iconImage: json['iconImage'],
      cataloguePdf: json['cataloguePdf'],
      subCategories: subCats,
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
