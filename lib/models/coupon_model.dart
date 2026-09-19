enum DiscountType {
  percentage,
  flatAmount,
}

class CouponModel {
  final String id;
  final String code;
  final String title;
  final String? description;
  final DiscountType discountType;
  final double discountValue;
  final double minOrderAmount;
  final double maxDiscountAmount;
  final int usageLimit;
  final int usedCount;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? expiryDate;

  const CouponModel({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    this.discountType = DiscountType.percentage,
    required this.discountValue,
    this.minOrderAmount = 0.0,
    this.maxDiscountAmount = 1000.0,
    this.usageLimit = 100,
    this.usedCount = 0,
    this.isActive = true,
    this.startDate,
    this.expiryDate,
  });

  bool get isExpired => expiryDate != null && DateTime.now().isAfter(expiryDate!);

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    DiscountType dType = DiscountType.percentage;
    final typeStr = (json['discountType'] ?? json['type'] ?? '').toString().toLowerCase();
    if (typeStr.contains('flat') || typeStr.contains('amount')) {
      dType = DiscountType.flatAmount;
    }

    return CouponModel(
      id: json['_id'] ?? json['id']?.toString() ?? '',
      code: (json['code'] ?? 'BHANDAR10').toString().toUpperCase(),
      title: json['title'] ?? 'Promotional Discount',
      description: json['description'],
      discountType: dType,
      discountValue: (json['discountValue'] is num) ? (json['discountValue'] as num).toDouble() : (double.tryParse(json['discountValue']?.toString() ?? '10') ?? 10.0),
      minOrderAmount: (json['minOrderAmount'] is num) ? (json['minOrderAmount'] as num).toDouble() : (double.tryParse(json['minOrderAmount']?.toString() ?? '0') ?? 0.0),
      maxDiscountAmount: (json['maxDiscountAmount'] is num) ? (json['maxDiscountAmount'] as num).toDouble() : (double.tryParse(json['maxDiscountAmount']?.toString() ?? '1000') ?? 1000.0),
      usageLimit: json['usageLimit'] ?? 100,
      usedCount: json['usedCount'] ?? json['usageCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      expiryDate: json['expiryDate'] != null ? DateTime.tryParse(json['expiryDate']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'code': code,
        'title': title,
        'description': description,
        'discountType': discountType == DiscountType.percentage ? 'percentage' : 'flat',
        'discountValue': discountValue,
        'minOrderAmount': minOrderAmount,
        'maxDiscountAmount': maxDiscountAmount,
        'usageLimit': usageLimit,
        'isActive': isActive,
        'startDate': startDate?.toIso8601String(),
        'expiryDate': expiryDate?.toIso8601String(),
      };

  CouponModel copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    DiscountType? discountType,
    double? discountValue,
    double? minOrderAmount,
    double? maxDiscountAmount,
    int? usageLimit,
    int? usedCount,
    bool? isActive,
    DateTime? startDate,
    DateTime? expiryDate,
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}
