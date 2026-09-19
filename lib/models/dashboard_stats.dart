class RevenueDataPoint {
  final String label;
  final double amount;
  final int orders;

  const RevenueDataPoint({
    required this.label,
    required this.amount,
    required this.orders,
  });
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
}
