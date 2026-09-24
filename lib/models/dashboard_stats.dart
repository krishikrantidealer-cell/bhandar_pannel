class RevenueDataPoint {
  final String label;
  final double amount;
  final int orders;

  const RevenueDataPoint({
    required this.label,
    required this.amount,
    required this.orders,
  });

  factory RevenueDataPoint.fromJson(Map<String, dynamic> json) {
    return RevenueDataPoint(
      label: json['label']?.toString() ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      orders: json['orders'] is int ? json['orders'] : int.tryParse(json['orders']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'amount': amount,
        'orders': orders,
      };
}

class DashboardStats {
  final int totalProducts;
  final int activeCategories;
  final int totalOrders;
  final double totalRevenue;
  final int lowStockProducts;
  final int activeCoupons;
  final double averageOrderValue;
  final List<RevenueDataPoint> revenueTrend;

  const DashboardStats({
    this.totalProducts = 0,
    this.activeCategories = 0,
    this.totalOrders = 0,
    this.totalRevenue = 0.0,
    this.lowStockProducts = 0,
    this.activeCoupons = 0,
    this.averageOrderValue = 0.0,
    this.revenueTrend = const [],
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    List<RevenueDataPoint> trend = [];
    if (json['revenueTrend'] is List) {
      trend = (json['revenueTrend'] as List)
          .map((item) => RevenueDataPoint.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return DashboardStats(
      totalProducts: json['totalProducts'] is int ? json['totalProducts'] : int.tryParse(json['totalProducts']?.toString() ?? '0') ?? 0,
      activeCategories: json['activeCategories'] is int ? json['activeCategories'] : int.tryParse(json['activeCategories']?.toString() ?? '0') ?? 0,
      totalOrders: json['totalOrders'] is int ? json['totalOrders'] : int.tryParse(json['totalOrders']?.toString() ?? '0') ?? 0,
      totalRevenue: (json['totalRevenue'] is num) ? (json['totalRevenue'] as num).toDouble() : double.tryParse(json['totalRevenue']?.toString() ?? '0') ?? 0.0,
      lowStockProducts: json['lowStockProducts'] is int ? json['lowStockProducts'] : int.tryParse(json['lowStockProducts']?.toString() ?? '0') ?? 0,
      activeCoupons: json['activeCoupons'] is int ? json['activeCoupons'] : int.tryParse(json['activeCoupons']?.toString() ?? '0') ?? 0,
      averageOrderValue: (json['averageOrderValue'] is num) ? (json['averageOrderValue'] as num).toDouble() : double.tryParse(json['averageOrderValue']?.toString() ?? '0') ?? 0.0,
      revenueTrend: trend,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalProducts': totalProducts,
        'activeCategories': activeCategories,
        'totalOrders': totalOrders,
        'totalRevenue': totalRevenue,
        'lowStockProducts': lowStockProducts,
        'activeCoupons': activeCoupons,
        'averageOrderValue': averageOrderValue,
        'revenueTrend': revenueTrend.map((e) => e.toJson()).toList(),
      };
}
