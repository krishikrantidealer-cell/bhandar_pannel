enum BannerType {
  home,
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
  final String? imageUrlMedium;
  final BannerType type;
  final String? linkType;
  final String? linkValue;
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
    this.imageUrlMedium,
    this.type = BannerType.home,
    this.linkType,
    this.linkValue,
    this.targetLink,
    this.categorySlug,
    this.priority = 0,
    this.isActive = true,
    this.validUntil,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    BannerType bType = BannerType.home;
    final rawType = (json['type'] ?? json['bannerType'] ?? '').toString().toLowerCase();
    if (rawType.contains('strip')) {
      bType = BannerType.strip;
    } else if (rawType.contains('cat')) {
      bType = BannerType.category;
    } else if (rawType.contains('pop')) {
      bType = BannerType.popup;
    } else if (rawType.contains('hero')) {
      bType = BannerType.hero;
    } else {
      bType = BannerType.home;
    }

    final lType = json['linkType']?.toString();
    final lVal = json['linkValue']?.toString() ?? json['targetLink']?.toString() ?? json['link']?.toString() ?? json['url']?.toString();
    final catSlug = json['categorySlug']?.toString() ?? (lType == 'category' ? lVal : null);

    return BannerModel(
      id: json['_id'] ?? json['id']?.toString() ?? '',
      title: json['title'] ?? json['bannerTitle'] ?? 'Banner',
      subtitle: json['subtitle'] ?? json['description'],
      imageUrl: json['imageUrl'] ?? json['imageUrlMedium'] ?? json['image'] ?? json['bannerImage'] ?? '',
      imageUrlMedium: json['imageUrlMedium']?.toString(),
      type: bType,
      linkType: lType,
      linkValue: lVal,
      targetLink: lVal,
      categorySlug: catSlug,
      priority: json['order'] is int ? json['order'] : (int.tryParse(json['order']?.toString() ?? '') ?? (json['priority'] is int ? json['priority'] : int.tryParse(json['priority']?.toString() ?? '') ?? 0)),
      isActive: json['isActive'] ?? json['active'] ?? true,
      validUntil: json['validUntil'] != null ? DateTime.tryParse(json['validUntil']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'subtitle': subtitle,
        'imageUrl': imageUrl,
        'imageUrlMedium': imageUrlMedium,
        'type': type.name,
        'linkType': linkType,
        'linkValue': linkValue,
        'targetLink': targetLink,
        'categorySlug': categorySlug,
        'order': priority,
        'priority': priority,
        'isActive': isActive,
      };

  BannerModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? imageUrlMedium,
    BannerType? type,
    String? linkType,
    String? linkValue,
    String? targetLink,
    String? categorySlug,
    int? priority,
    bool? isActive,
    DateTime? validUntil,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrlMedium: imageUrlMedium ?? this.imageUrlMedium,
      type: type ?? this.type,
      linkType: linkType ?? this.linkType,
      linkValue: linkValue ?? this.linkValue,
      targetLink: targetLink ?? this.targetLink,
      categorySlug: categorySlug ?? this.categorySlug,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      validUntil: validUntil ?? this.validUntil,
    );
  }
}
