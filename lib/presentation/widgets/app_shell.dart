import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';
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

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? Drawer(child: Sidebar(currentPath: widget.currentPath)) : null,
      body: Row(
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
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
