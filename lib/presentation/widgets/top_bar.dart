import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/routing/route_paths.dart';
import '../../core/utils/responsive.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_event.dart';
import '../../logic/theme/theme_state.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/dashboard/dashboard_bloc.dart';
import '../../logic/dashboard/dashboard_event.dart';
import '../../logic/products/product_bloc.dart';
import '../../logic/products/product_event.dart';
import '../../logic/categories/category_bloc.dart';
import '../../logic/categories/category_event.dart';
import '../../logic/orders/order_bloc.dart';
import '../../logic/orders/order_event.dart';
import '../../logic/banners/banner_bloc.dart';
import '../../logic/banners/banner_event.dart';
import '../../logic/coupons/coupon_bloc.dart';
import '../../logic/coupons/coupon_event.dart';

class TopBar extends StatelessWidget {
  final String currentPath;
  final VoidCallback? onMobileMenuToggle;

  const TopBar({
    super.key,
    required this.currentPath,
    this.onMobileMenuToggle,
  });

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to sign out of the Bhandar Admin Panel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = ResponsiveLayout.isMobile(context);

    String sectionTitle = 'Dashboard Overview';
    if (currentPath == RoutePaths.products) {
      sectionTitle = 'Products & Inventory';
    } else if (currentPath == RoutePaths.categories) {
      sectionTitle = 'Categories & Subcategories';
    } else if (currentPath == RoutePaths.banners) {
      sectionTitle = 'Banners & Marketing Assets';
    } else if (currentPath == RoutePaths.coupons) {
      sectionTitle = 'Coupons & Discounts';
    } else if (currentPath == RoutePaths.orders) {
      sectionTitle = 'Customer Orders';
    } else if (currentPath == RoutePaths.settings) {
      sectionTitle = 'Theme & Panel Settings';
    }

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final user = authState.currentUser;
            final displayName = user?.name ?? 'Admin';
            final userRole = user?.userType.name.toUpperCase() ?? 'ADMIN';

            return Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Mobile Menu Button
                  if (isMobile)
                    IconButton(
                      icon: const Icon(Icons.menu_rounded),
                      onPressed: onMobileMenuToggle,
                      tooltip: 'Toggle Navigation',
                    ),

                  // Section Title
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sectionTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isMobile)
                          Text(
                            'Krishi Bhandar Operations Hub',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // Live Cloud Run Status Pill
                  if (!isMobile)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Cloud Run Live',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Refresh Data Button
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    tooltip: 'Sync Live Data across BLoCs',
                    onPressed: () {
                      context.read<DashboardBloc>().add(const LoadDashboardData());
                      context.read<ProductBloc>().add(const LoadProducts());
                      context.read<CategoryBloc>().add(const LoadCategories());
                      context.read<OrderBloc>().add(const LoadOrders());
                      context.read<BannerBloc>().add(const LoadBanners());
                      context.read<CouponBloc>().add(const LoadCoupons());

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Syncing all modules with Bhandar Cloud Run...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),

                  // Dark/Light Theme Quick Toggler
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      size: 20,
                    ),
                    tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
                    onPressed: () => context.read<ThemeBloc>().add(ToggleDarkMode(isDark)),
                  ),

                  const SizedBox(width: 8),

                  // Admin Profile Menu
                  PopupMenuButton<String>(
                    tooltip: 'Admin Account Options',
                    onSelected: (val) {
                      if (val == 'logout') {
                        _confirmLogout(context);
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(
                              user?.email ?? 'admin@krishibhandar.in',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: themeState.currentPalette.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                userRole,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: themeState.currentPalette.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
                            SizedBox(width: 8),
                            Text('Sign Out', style: TextStyle(color: Color(0xFFEF4444))),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: themeState.currentPalette.primary,
                            child: Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (!isMobile) ...[
                            const SizedBox(width: 8),
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, size: 16),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
