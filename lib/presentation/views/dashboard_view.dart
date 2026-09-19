import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_paths.dart';
import '../../core/utils/formatters.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_state.dart';
import '../../logic/dashboard/dashboard_bloc.dart';
import '../../logic/dashboard/dashboard_state.dart';
import '../../models/order_model.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_badge.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, dashboardState) {
            final stats = dashboardState.stats;
            final orders = dashboardState.recentOrders;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Banner
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeState.currentPalette.primary,
                          themeState.currentPalette.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(themeState.borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: themeState.currentPalette.primary.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to ${themeState.brandName} Portal',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                themeState.tagline,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => context.go(RoutePaths.products),
                          icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                          label: const Text('Manage Catalog'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: themeState.currentPalette.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stat Cards Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double width = constraints.maxWidth;
                      int crossAxisCount = 4;
                      if (width < 600) {
                        crossAxisCount = 1;
                      } else if (width < 1000) {
                        crossAxisCount = 2;
                      }

                      final itemWidth = (width - ((crossAxisCount - 1) * 16)) / crossAxisCount;

                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: StatCard(
                              title: 'Total Revenue',
                              value: AppFormatters.formatCurrency(stats.totalRevenue),
                              icon: Icons.currency_rupee_rounded,
                              iconColor: const Color(0xFF10B981),
                              trend: '+18.4% vs last week',
                              isTrendPositive: true,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: StatCard(
                              title: 'Total Orders',
                              value: AppFormatters.formatNumber(stats.totalOrders),
                              icon: Icons.shopping_bag_rounded,
                              iconColor: const Color(0xFF3B82F6),
                              trend: '+12 new today',
                              isTrendPositive: true,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: StatCard(
                              title: 'Active Products',
                              value: AppFormatters.formatNumber(stats.totalProducts),
                              icon: Icons.inventory_2_rounded,
                              iconColor: const Color(0xFF8B5CF6),
                              subtitle: 'Across ${stats.activeCategories} categories',
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: StatCard(
                              title: 'Low Stock Alerts',
                              value: '${stats.lowStockProducts}',
                              icon: Icons.warning_amber_rounded,
                              iconColor: const Color(0xFFEF4444),
                              trend: stats.lowStockProducts > 0 ? 'Requires attention' : 'Healthy stock',
                              isTrendPositive: stats.lowStockProducts == 0,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Analytics Chart & Low Stock Section
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;
                      return isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: _buildRevenueChart(context, themeState, isDark)),
                                const SizedBox(width: 24),
                                Expanded(flex: 2, child: _buildQuickActions(context, isDark)),
                              ],
                            )
                          : Column(
                              children: [
                                _buildRevenueChart(context, themeState, isDark),
                                const SizedBox(height: 24),
                                _buildQuickActions(context, isDark),
                              ],
                            );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Recent Orders Section
                  _buildRecentOrders(context, orders, isDark),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRevenueChart(
    BuildContext context,
    ThemeState themeState,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final points = [
      FlSpot(0, 38.4),
      FlSpot(1, 45.2),
      FlSpot(2, 51.8),
      FlSpot(3, 49.1),
      FlSpot(4, 62.4),
      FlSpot(5, 74.2),
      FlSpot(6, 63.4),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Sales & Revenue Trend (₹ in Thousands)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Live orders aggregated from Bhandar backend',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: themeState.currentPalette.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Last 7 Days',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: themeState.currentPalette.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: isDark
                          ? const Color(0xFF334155).withValues(alpha: 0.5)
                          : const Color(0xFFE2E8F0),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}k',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          final idx = value.toInt();
                          if (idx >= 0 && idx < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                days[idx],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: points,
                      isCurved: true,
                      color: themeState.currentPalette.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            themeState.currentPalette.primary.withValues(alpha: 0.3),
                            themeState.currentPalette.primary.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Shortcuts',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _buildActionTile(
              icon: Icons.add_box_rounded,
              title: 'Add New Product',
              subtitle: 'Create product with variants & pricing',
              color: const Color(0xFF10B981),
              onTap: () => context.go(RoutePaths.products),
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              icon: Icons.category_rounded,
              title: 'Organize Categories',
              subtitle: 'Update banners, catalogs & subcategories',
              color: const Color(0xFF3B82F6),
              onTap: () => context.go(RoutePaths.categories),
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              icon: Icons.local_offer_rounded,
              title: 'Create Coupon Code',
              subtitle: 'Add promotional percentage or flat discounts',
              color: const Color(0xFFF59E0B),
              onTap: () => context.go(RoutePaths.coupons),
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              icon: Icons.palette_rounded,
              title: 'Live Theme Studio',
              subtitle: 'Customize branding, colors and fonts',
              color: const Color(0xFF8B5CF6),
              onTap: () => context.go(RoutePaths.settings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders(
    BuildContext context,
    List<OrderModel> orders,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final recent = orders.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Recent Farmer Orders',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go(RoutePaths.orders),
                  child: const Text('View All Orders'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: Text('No orders yet')),
              )
            else
              ...recent.map((order) {
                StatusBadge badge;
                switch (order.status) {
                  case OrderStatus.confirmed:
                    badge = StatusBadge.success('Confirmed');
                    break;
                  case OrderStatus.processing:
                    badge = StatusBadge.warning('Processing');
                    break;
                  case OrderStatus.shipped:
                    badge = StatusBadge.info('Shipped');
                    break;
                  case OrderStatus.delivered:
                    badge = StatusBadge.success('Delivered');
                    break;
                  case OrderStatus.cancelled:
                    badge = StatusBadge.danger('Cancelled');
                    break;
                  case OrderStatus.pending:
                    badge = StatusBadge.neutral('Pending');
                    break;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.dividerTheme.color ?? Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.receipt_long_rounded, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.orderNumber,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Text(
                              '${order.customerName} • ${order.items.length} items',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AppFormatters.formatCurrency(order.totalAmount),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                      ),
                      const SizedBox(width: 16),
                      badge,
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
