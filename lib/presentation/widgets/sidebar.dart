import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_paths.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_event.dart';
import '../../logic/theme/theme_state.dart';
import '../../logic/products/product_bloc.dart';
import '../../logic/products/product_state.dart';
// import '../../logic/categories/category_bloc.dart';
// import '../../logic/categories/category_state.dart';
// import '../../logic/orders/order_bloc.dart';
// import '../../logic/orders/order_state.dart';

class Sidebar extends StatelessWidget {
  final String currentPath;

  const Sidebar({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isCollapsed = themeState.isSidebarCollapsed;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
          width: isCollapsed ? 80 : 260,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            border: Border(
              right: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Branding Header
              Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: isCollapsed
                    ? Center(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                themeState.currentPalette.primary,
                                themeState.currentPalette.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'KB',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  themeState.currentPalette.primary,
                                  themeState.currentPalette.secondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(Icons.agriculture_rounded, color: Colors.white, size: 24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  themeState.brandName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Admin Operations Web',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),

              const Divider(height: 1),

              // Nav Items List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  children: [
                    // Dashboard
                    // _buildNavItem(
                    //   context,
                    //   path: RoutePaths.dashboard,
                    //   title: 'Dashboard',
                    //   icon: Icons.dashboard_rounded,
                    //   isSelected: currentPath == RoutePaths.dashboard,
                    //   isCollapsed: isCollapsed,
                    //   primaryColor: themeState.currentPalette.primary,
                    // ),
                    BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, prodState) {
                        return _buildNavItem(
                          context,
                          path: RoutePaths.products,
                          title: 'Products',
                          icon: Icons.inventory_2_rounded,
                          isSelected: currentPath == RoutePaths.products,
                          badgeText: '${prodState.allProducts.length}',
                          isCollapsed: isCollapsed,
                          primaryColor: themeState.currentPalette.primary,
                        );
                      },
                    ),
                    // Categories
                    // BlocBuilder<CategoryBloc, CategoryState>(
                    //   builder: (context, catState) {
                    //     return _buildNavItem(
                    //       context,
                    //       path: RoutePaths.categories,
                    //       title: 'Categories',
                    //       icon: Icons.category_rounded,
                    //       isSelected: currentPath == RoutePaths.categories,
                    //       badgeText: '${catState.categories.length}',
                    //       isCollapsed: isCollapsed,
                    //       primaryColor: themeState.currentPalette.primary,
                    //     );
                    //   },
                    // ),
                    // Banners
                    // _buildNavItem(
                    //   context,
                    //   path: RoutePaths.banners,
                    //   title: 'Banners',
                    //   icon: Icons.view_carousel_rounded,
                    //   isSelected: currentPath == RoutePaths.banners,
                    //   isCollapsed: isCollapsed,
                    //   primaryColor: themeState.currentPalette.primary,
                    // ),
                    // Coupons
                    // _buildNavItem(
                    //   context,
                    //   path: RoutePaths.coupons,
                    //   title: 'Coupons',
                    //   icon: Icons.local_offer_rounded,
                    //   isSelected: currentPath == RoutePaths.coupons,
                    //   isCollapsed: isCollapsed,
                    //   primaryColor: themeState.currentPalette.primary,
                    // ),
                    // Orders
                    // BlocBuilder<OrderBloc, OrderState>(
                    //   builder: (context, ordState) {
                    //     return _buildNavItem(
                    //       context,
                    //       path: RoutePaths.orders,
                    //       title: 'Orders',
                    //       icon: Icons.shopping_bag_rounded,
                    //       isSelected: currentPath == RoutePaths.orders,
                    //       badgeText: '${ordState.orders.length}',
                    //       badgeColor: const Color(0xFFEF4444),
                    //       isCollapsed: isCollapsed,
                    //       primaryColor: themeState.currentPalette.primary,
                    //     );
                    //   },
                    // ),
                    // const SizedBox(height: 16),
                    // if (!isCollapsed)
                    //   Padding(
                    //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    //     child: Text(
                    //       'PREFERENCES & SYSTEM',
                    //       style: TextStyle(
                    //         fontSize: 10,
                    //         fontWeight: FontWeight.w700,
                    //         letterSpacing: 1.0,
                    //         color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    //       ),
                    //     ),
                    //   ),
                    // Theme & Settings
                    // _buildNavItem(
                    //   context,
                    //   path: RoutePaths.settings,
                    //   title: 'Theme & Settings',
                    //   icon: Icons.tune_rounded,
                    //   isSelected: currentPath == RoutePaths.settings,
                    //   isCollapsed: isCollapsed,
                    //   primaryColor: themeState.currentPalette.primary,
                    // ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Bottom Collapse / Expand Button
              InkWell(
                onTap: () => context.read<ThemeBloc>().add(const ToggleSidebar()),
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment:
                        isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                    children: [
                      if (!isCollapsed)
                        Text(
                          'Collapse Sidebar',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      Icon(
                        isCollapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                        size: 20,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String path,
    required String title,
    required IconData icon,
    required bool isSelected,
    required bool isCollapsed,
    required Color primaryColor,
    String? badgeText,
    Color? badgeColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Tooltip(
        message: isCollapsed ? title : '',
        child: InkWell(
          onTap: () {
            if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
              Navigator.of(context).pop();
            }
            context.go(path);
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 0 : 14,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withValues(alpha: isDark ? 0.2 : 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1)
                  : null,
            ),
            child: Row(
              mainAxisAlignment:
                  isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? primaryColor
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? primaryColor
                            : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155)),
                      ),
                    ),
                  ),
                  if (badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: (badgeColor ?? primaryColor).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: badgeColor ?? primaryColor,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
