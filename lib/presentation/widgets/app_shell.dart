import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/responsive.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_state.dart';
import 'sidebar.dart';
import 'top_bar.dart';

class AppShell extends StatefulWidget {
  final String currentPath;
  final Widget child;

  const AppShell({
    super.key,
    required this.currentPath,
    required this.child,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.themeMode == ThemeMode.dark ||
            (themeState.themeMode == ThemeMode.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark);
        final bg = isDark ? themeState.currentPalette.backgroundDark : themeState.currentPalette.backgroundLight;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: bg,
          drawer: isMobile ? Drawer(child: Sidebar(currentPath: widget.currentPath)) : null,
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            color: bg,
            child: Row(
              children: [
                // Sidebar (Desktop & Tablet)
                if (!isMobile) Sidebar(currentPath: widget.currentPath),

                // Main Content Area
                Expanded(
                  child: Column(
                    children: [
                      TopBar(
                        currentPath: widget.currentPath,
                        onMobileMenuToggle: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                      Expanded(
                        child: SelectionArea(
                          child: widget.child,
                        ),
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
}
