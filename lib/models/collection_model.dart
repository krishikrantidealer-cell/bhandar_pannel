class SubCollectionModel {
  final String? id;
  final String name;
  final String slug;
  final bool isActive;
  final String? image;
  final String? count;

  const SubCollectionModel({
    this.id,
    required this.name,
    required this.slug,
    this.isActive = true,
    this.image,
    this.count,
  });

  static String? getFallbackCropImage(String nameOrSlug) {
    return null;
  }

  factory SubCollectionModel.fromJson(dynamic json) {
    if (json is String) {
      final trimmed = json.trim();
      final slugStr = trimmed.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9\-]'), '');
      return SubCollectionModel(
        id: trimmed,
        name: trimmed,
        slug: slugStr,
        isActive: true,
        image: getFallbackCropImage(trimmed),
      );
    } else if (json is Map) {
      final nameStr = (json['name'] ?? json['title'] ?? json['subCollectionName'] ?? json['label'] ?? json['slug'] ?? '').toString();
      final idStr = (json['_id'] ?? json['id'] ?? json['slug'] ?? nameStr).toString();
      final slugStr = (json['slug'] ?? json['handle'] ?? nameStr.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9\-]'), '')).toString();

      String? img;
      if (json['image'] is Map && json['image']['src'] != null) {
        img = json['image']['src'].toString();
      } else if (json['image'] != null && json['image'].toString().trim().isNotEmpty) {
        img = json['image'].toString().trim();
      } else if (json['imageUrl'] != null && json['imageUrl'].toString().trim().isNotEmpty) {
        img = json['imageUrl'].toString().trim();
      } else if (json['bannerImage'] != null && json['bannerImage'].toString().trim().isNotEmpty) {
        img = json['bannerImage'].toString().trim();
      } else if (json['icon'] != null && json['icon'].toString().trim().isNotEmpty) {
        img = json['icon'].toString().trim();
      }

      img ??= getFallbackCropImage(nameStr) ?? getFallbackCropImage(slugStr);

      final countStr = (json['count'] ?? json['productsCount'] ?? json['productCount'])?.toString();

      return SubCollectionModel(
        id: idStr.isNotEmpty ? idStr : null,
        name: nameStr.isNotEmpty ? nameStr : idStr,
        slug: slugStr,
        isActive: json['isActive'] == true || json['isActive'] == null || json['is_active'] == true,
        image: img,
        count: countStr,
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
      if (image != null && image!.isNotEmpty) 'image': image,
      if (count != null && count!.isNotEmpty) 'count': count,
    };
  }

  SubCollectionModel copyWith({
    String? id,
    String? name,
    String? slug,
    bool? isActive,
    String? image,
    String? count,
  }) {
    return SubCollectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      isActive: isActive ?? this.isActive,
      image: image ?? this.image,
      count: count ?? this.count,
    );
  }
}

class CollectionModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String bannerImage;
  final String? stripBanner;
  final String bannerTitle;
  final String headingType; // 'strip_banner' | 'text' | 'both'
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
    this.stripBanner,
    this.bannerTitle = '',
    this.headingType = 'both',
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
    final colSlug = (json['slug'] ?? colName.toLowerCase().replaceAll(' ', '-')).toString().trim();

    String bannerImg = '';
    if (json['bannerImage'] != null && json['bannerImage'].toString().trim().isNotEmpty) {
      bannerImg = json['bannerImage'].toString().trim();
    } else if (json['image'] is Map && json['image']['src'] != null) {
      bannerImg = json['image']['src'].toString().trim();
    } else if (json['image'] != null && json['image'].toString().trim().isNotEmpty) {
      bannerImg = json['image'].toString().trim();
    } else if (json['imageUrl'] != null && json['imageUrl'].toString().trim().isNotEmpty) {
      bannerImg = json['imageUrl'].toString().trim();
    }

    String? stripImg;
    if (json['stripBanner'] != null && json['stripBanner'].toString().trim().isNotEmpty) {
      stripImg = json['stripBanner'].toString().trim();
    } else if (json['stripBannerImage'] != null && json['stripBannerImage'].toString().trim().isNotEmpty) {
      stripImg = json['stripBannerImage'].toString().trim();
    } else if (json['strip'] != null && json['strip'].toString().trim().isNotEmpty) {
      stripImg = json['strip'].toString().trim();
    }

    final hType = (json['headingType'] ?? json['displayStyle'] ?? 'both').toString();

    return CollectionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? 'col_${DateTime.now().millisecondsSinceEpoch}',
      name: colName,
      slug: colSlug,
      description: json['description']?.toString() ?? '',
      bannerImage: bannerImg,
      stripBanner: stripImg,
      bannerTitle: json['bannerTitle']?.toString() ?? '',
      headingType: hType,
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
      'image': bannerImage,
      'imageUrl': bannerImage,
      if (stripBanner != null && stripBanner!.isNotEmpty) 'stripBanner': stripBanner,
      'bannerTitle': bannerTitle,
      'headingType': headingType,
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
    String? stripBanner,
    String? bannerTitle,
    String? headingType,
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
      stripBanner: stripBanner ?? this.stripBanner,
      bannerTitle: bannerTitle ?? this.bannerTitle,
      headingType: headingType ?? this.headingType,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      subCollections: subCollections ?? this.subCollections,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
