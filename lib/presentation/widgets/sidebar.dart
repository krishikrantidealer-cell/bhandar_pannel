import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_paths.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_event.dart';
import '../../logic/theme/theme_state.dart';
import '../../logic/products/product_bloc.dart';
import '../../logic/products/product_state.dart';

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
        final primaryColor = themeState.currentPalette.primary;

        return ClipRect(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
            width: isCollapsed ? 72 : 248,
            height: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              border: Border(
                right: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // ── Brand Header ──────────────────────────────────────────
                Container(
                  height: 64,
                  padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 12 : 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                      if (!isCollapsed) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                themeState.brandName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                  color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Operations Hub',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Navigation Items ───────────────────────────────────────
                Expanded(
                  child: BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, prodState) {
                      final isProductsSelected = currentPath.startsWith(RoutePaths.products) || currentPath == '/';

                      return ListView(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        children: [
                          if (!isCollapsed)
                            _buildSectionHeader(
                              title: 'CATALOG MANAGEMENT',
                              isDark: isDark,
                            ),

                          _buildNavItem(
                            context,
                            title: 'Products',
                            icon: Icons.inventory_2_outlined,
                            activeIcon: Icons.inventory_2_rounded,
                            isSelected: isProductsSelected,
                            badgeText: '${prodState.allProducts.length}',
                            isCollapsed: isCollapsed,
                            primaryColor: primaryColor,
                            onTap: () => context.go(RoutePaths.products),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // ── Footer: User Profile & Quick Actions ───────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // User Identity
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          final user = authState.currentUser;
                          final userName = user?.name ?? 'Admin User';
                          final userPhone = user?.phone ?? 'Admin';

                          if (isCollapsed) {
                            return Tooltip(
                              message: '$userName ($userPhone)',
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155).withValues(alpha: 0.6) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        userPhone,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 6),

                      // Sidebar Action Controls (Theme Toggle & Collapse)
                      Row(
                        mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                        children: [
                          // Theme Mode Toggle
                          Tooltip(
                            message: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                            child: InkWell(
                              onTap: () {
                                context.read<ThemeBloc>().add(
                                  ChangeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark),
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                                  size: 17,
                                  color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),

                          // Collapse / Expand Toggle
                          Tooltip(
                            message: isCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar',
                            child: InkWell(
                              onTap: () => context.read<ThemeBloc>().add(const ToggleSidebar()),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  isCollapsed
                                      ? Icons.keyboard_double_arrow_right_rounded
                                      : Icons.keyboard_double_arrow_left_rounded,
                                  size: 17,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required IconData activeIcon,
    required bool isSelected,
    required bool isCollapsed,
    required Color primaryColor,
    required VoidCallback onTap,
    String? badgeText,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Tooltip(
        message: isCollapsed ? title : '',
        waitDuration: const Duration(milliseconds: 300),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () {
              if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                Navigator.of(context).pop();
              }
              onTap();
            },
            borderRadius: BorderRadius.circular(8),
            hoverColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 0 : 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withValues(alpha: isDark ? 0.16 : 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? primaryColor.withValues(alpha: isDark ? 0.3 : 0.2)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: isCollapsed
                  ? Center(
                      child: Icon(
                        isSelected ? activeIcon : icon,
                        size: 19,
                        color: isSelected
                            ? primaryColor
                            : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)),
                      ),
                    )
                  : Row(
                      children: [
                        Icon(
                          isSelected ? activeIcon : icon,
                          size: 18,
                          color: isSelected
                              ? primaryColor
                              : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A))
                                  : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badgeText != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withValues(alpha: 0.15)
                                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor.withValues(alpha: 0.3)
                                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? primaryColor
                                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
