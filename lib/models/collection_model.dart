class SubCollectionModel {
  final String? id;
  final String name;
  final String slug;
  final bool isActive;
  final String? image;

  const SubCollectionModel({
    this.id,
    required this.name,
    required this.slug,
    this.isActive = true,
    this.image,
  });

  factory SubCollectionModel.fromJson(dynamic json) {
    if (json is String) {
      final trimmed = json.trim();
      return SubCollectionModel(
        id: trimmed,
        name: trimmed,
        slug: trimmed.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9\-]'), ''),
        isActive: true,
      );
    } else if (json is Map) {
      final nameStr = (json['name'] ?? json['title'] ?? json['subCollectionName'] ?? json['label'] ?? json['slug'] ?? '').toString();
      final idStr = (json['_id'] ?? json['id'] ?? json['slug'] ?? nameStr).toString();
      final slugStr = (json['slug'] ?? json['handle'] ?? nameStr.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9\-]'), '')).toString();
      return SubCollectionModel(
        id: idStr.isNotEmpty ? idStr : null,
        name: nameStr.isNotEmpty ? nameStr : idStr,
        slug: slugStr,
        isActive: json['isActive'] == true || json['isActive'] == null || json['is_active'] == true,
        image: json['image']?.toString() ?? json['bannerImage']?.toString() ?? json['icon']?.toString(),
      );
    }
    return const SubCollectionModel(name: '', slug: '');
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'slug': slug,
      'isActive': isActive,
      if (image != null) 'image': image,
    };
  }
}

class CollectionModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String bannerImage;
  final String bannerTitle;
  final bool isActive;
  final int priority;
  final List<SubCollectionModel> subCollections;
  final DateTime? createdAt;

  const CollectionModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.bannerImage = '',
    this.bannerTitle = '',
    this.isActive = true,
    this.priority = 0,
    this.subCollections = const [],
    this.createdAt,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    List<SubCollectionModel> subs = [];
    final rawSubs = json['subCollections'] ??
        json['subcollections'] ??
        json['sub_collections'] ??
        json['subCollection'] ??
        json['crops'] ??
        json['children'];

    if (rawSubs != null && rawSubs is List) {
      for (final s in rawSubs) {
        if (s is Map) {
          final sub = SubCollectionModel.fromJson(Map<String, dynamic>.from(s));
          if (sub.name.isNotEmpty) subs.add(sub);
        } else if (s is String && s.trim().isNotEmpty) {
          subs.add(SubCollectionModel.fromJson(s.trim()));
        }
      }
    }

    final colName = (json['name'] ?? json['title'] ?? '').toString().trim();

    // If sub-collections are empty in DB, provide intelligent agricultural collection defaults
    if (subs.isEmpty && colName.isNotEmpty) {
      final lower = colName.toLowerCase();
      if (lower.contains('crop') || lower.contains('fasal')) {
        subs = [
          const SubCollectionModel(name: 'Rice / Paddy', slug: 'rice'),
          const SubCollectionModel(name: 'Wheat', slug: 'wheat'),
          const SubCollectionModel(name: 'Cotton', slug: 'cotton'),
          const SubCollectionModel(name: 'Sugarcane', slug: 'sugarcane'),
          const SubCollectionModel(name: 'Chilli', slug: 'chilli'),
          const SubCollectionModel(name: 'Tomato', slug: 'tomato'),
          const SubCollectionModel(name: 'Potato', slug: 'potato'),
          const SubCollectionModel(name: 'Mustard', slug: 'mustard'),
          const SubCollectionModel(name: 'Groundnut', slug: 'groundnut'),
          const SubCollectionModel(name: 'Soybean', slug: 'soybean'),
        ];
      } else if (lower.contains('offer') || lower.contains('deal') || lower.contains('buy 1') || lower.contains('bogo')) {
        subs = [
          const SubCollectionModel(name: 'Buy 1 Get 1 Free', slug: 'bogo'),
          const SubCollectionModel(name: 'Combo Deals', slug: 'combos'),
          const SubCollectionModel(name: 'Clearance Sale', slug: 'clearance'),
          const SubCollectionModel(name: 'Farmer Special Discounts', slug: 'special-discounts'),
        ];
      } else if (lower.contains('season') || lower.contains('kharif') || lower.contains('rabi') || lower.contains('monsoon')) {
        subs = [
          const SubCollectionModel(name: 'Kharif Season', slug: 'kharif'),
          const SubCollectionModel(name: 'Rabi Season', slug: 'rabi'),
          const SubCollectionModel(name: 'Zaid / Summer', slug: 'zaid'),
          const SubCollectionModel(name: 'Monsoon Care', slug: 'monsoon'),
        ];
      } else if (lower.contains('best') || lower.contains('trending') || lower.contains('popular')) {
        subs = [
          const SubCollectionModel(name: 'Top Sellers', slug: 'top-sellers'),
          const SubCollectionModel(name: 'Most Popular', slug: 'most-popular'),
          const SubCollectionModel(name: 'New Releases', slug: 'new-releases'),
        ];
      }
    }

    return CollectionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? 'col_${DateTime.now().millisecondsSinceEpoch}',
      name: colName,
      slug: json['slug']?.toString() ?? colName.toLowerCase().replaceAll(' ', '-'),
      description: json['description']?.toString() ?? '',
      bannerImage: json['bannerImage']?.toString() ?? json['image']?.toString() ?? '',
      bannerTitle: json['bannerTitle']?.toString() ?? '',
      isActive: json['isActive'] == true || json['isActive'] == null || json['is_active'] == true,
      priority: int.tryParse(json['priority']?.toString() ?? '0') ?? 0,
      subCollections: subs,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'description': description,
      'bannerImage': bannerImage,
      'bannerTitle': bannerTitle,
      'isActive': isActive,
      'priority': priority,
      'subCollections': subCollections.map((s) => s.toJson()).toList(),
    };
  }

  CollectionModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? bannerImage,
    String? bannerTitle,
    bool? isActive,
    int? priority,
    List<SubCollectionModel>? subCollections,
    DateTime? createdAt,
  }) {
    return CollectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      bannerImage: bannerImage ?? this.bannerImage,
      bannerTitle: bannerTitle ?? this.bannerTitle,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      subCollections: subCollections ?? this.subCollections,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
