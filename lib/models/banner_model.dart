enum BannerType {
  hero,
  strip,
  category,
  popup,
}

class BannerModel {
  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final BannerType type;
  final String? targetLink;
  final String? categorySlug;
  final int priority;
  final bool isActive;
  final DateTime? validUntil;

  BannerModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.type = BannerType.hero,
    this.targetLink,
    this.categorySlug,
    this.priority = 0,
    this.isActive = true,
    this.validUntil,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    BannerType bType = BannerType.hero;
    final rawType = (json['type'] ?? json['bannerType'] ?? '').toString().toLowerCase();
    if (rawType.contains('strip')) {
      bType = BannerType.strip;
    } else if (rawType.contains('cat')) {
      bType = BannerType.category;
    } else if (rawType.contains('pop')) {
      bType = BannerType.popup;
    }

    return BannerModel(
      id: json['_id'] ?? json['id']?.toString() ?? '',
      title: json['title'] ?? json['bannerTitle'] ?? 'Banner',
      subtitle: json['subtitle'] ?? json['description'],
      imageUrl: json['imageUrl'] ?? json['image'] ?? json['bannerImage'] ?? '',
      type: bType,
      targetLink: json['targetLink'] ?? json['link'] ?? json['url'],
      categorySlug: json['categorySlug'] ?? json['category'],
      priority: json['priority'] ?? json['order'] ?? 0,
      isActive: json['isActive'] ?? json['active'] ?? true,
      validUntil: json['validUntil'] != null ? DateTime.tryParse(json['validUntil']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'subtitle': subtitle,
        'imageUrl': imageUrl,
        'type': type.name,
        'targetLink': targetLink,
        'categorySlug': categorySlug,
        'priority': priority,
        'isActive': isActive,
      };

  BannerModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    BannerType? type,
    String? targetLink,
    String? categorySlug,
    int? priority,
    bool? isActive,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      targetLink: targetLink ?? this.targetLink,
      categorySlug: categorySlug ?? this.categorySlug,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      validUntil: validUntil,
    );
  }
}
