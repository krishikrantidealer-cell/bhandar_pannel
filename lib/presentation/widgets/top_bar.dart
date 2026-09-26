import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/routing/route_paths.dart';
import '../../core/utils/responsive.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_state.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';
import '../../logic/auth/auth_state.dart';

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

    String sectionTitle = 'Products & Catalog Operations';
    if (currentPath == RoutePaths.products) {
      sectionTitle = 'Products & Catalog Operations';
    } else if (currentPath == RoutePaths.productNew) {
      sectionTitle = 'Create New Product';
    } else if (currentPath.endsWith('/edit')) {
      sectionTitle = 'Edit Product Catalog';
    } else if (currentPath.startsWith('/products/')) {
      sectionTitle = 'Product Details & Variants';
    }

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final user = authState.currentUser;
            final displayName = user?.name ?? 'Admin';
            final userRole = user?.userType.name.toUpperCase() ?? 'ADMIN';

            return AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOutCubic,
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
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
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
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
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // Admin Profile Menu Button
                  PopupMenuButton<String>(
                    tooltip: 'Admin Account Options',
                    offset: const Offset(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
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
                            Text(
                              displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              user?.email ?? 'admin@krishibhandar.com',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 6),
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
                            Text('Sign Out', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155).withValues(alpha: 0.6) : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: themeState.currentPalette.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: themeState.currentPalette.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          if (!isMobile) ...[
                            const SizedBox(width: 8),
                            Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: themeState.currentPalette.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                userRole,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: themeState.currentPalette.primary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
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
