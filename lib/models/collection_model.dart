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

  factory SubCollectionModel.fromJson(Map<String, dynamic> json) {
    return SubCollectionModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      isActive: json['isActive'] == true || json['isActive'] == null,
      image: json['image']?.toString(),
    );
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
    if (json['subCollections'] is List) {
      subs = (json['subCollections'] as List)
          .map((s) => SubCollectionModel.fromJson(Map<String, dynamic>.from(s)))
          .toList();
    }

    return CollectionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? 'col_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      bannerImage: json['bannerImage']?.toString() ?? '',
      bannerTitle: json['bannerTitle']?.toString() ?? '',
      isActive: json['isActive'] == true || json['isActive'] == null,
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
