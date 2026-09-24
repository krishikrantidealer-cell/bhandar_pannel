import 'package:flutter/material.dart';
import 'shimmer_loading.dart';

class TableColumnDef {
  final String label;
  final double? width;
  final int flex;
  final Alignment alignment;

  const TableColumnDef({
    required this.label,
    this.width,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
  });
}

enum TableActionType { view, edit, delete, custom }

class TableActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;
  final TableActionType type;

  const TableActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
    this.type = TableActionType.custom,
  });

  const TableActionButton.view({
    super.key,
    required this.onTap,
    this.tooltip = 'View Details',
    this.icon = Icons.visibility_outlined,
  })  : color = const Color(0xFF3B82F6),
        type = TableActionType.view;

  const TableActionButton.edit({
    super.key,
    required this.onTap,
    this.tooltip = 'Edit Record',
    this.icon = Icons.edit_outlined,
    this.color,
  }) : type = TableActionType.edit;

  const TableActionButton.delete({
    super.key,
    required this.onTap,
    this.tooltip = 'Delete Record',
    this.icon = Icons.delete_outline_rounded,
  })  : color = const Color(0xFFEF4444),
        type = TableActionType.delete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveColor = color ?? theme.colorScheme.primary;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          hoverColor: effectiveColor.withValues(alpha: 0.15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: isDark ? 0.14 : 0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: effectiveColor.withValues(alpha: isDark ? 0.35 : 0.22),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 14.5,
                color: effectiveColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTable extends StatelessWidget {
  final List<TableColumnDef> columns;
  final List<List<Widget>> rows;
  final bool isLoading;
  final bool isRefreshing;
  final int loadingRowCount;
  final String emptyMessage;
  final double minWidth;

  const CustomTable({
    super.key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
    this.isRefreshing = false,
    this.loadingRowCount = 6,
    this.emptyMessage = 'No records found',
    this.minWidth = 700,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!isLoading && rows.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 26,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your search criteria or clearing active category filters.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double effectiveWidth = (constraints.maxWidth.isFinite && constraints.maxWidth > minWidth)
            ? constraints.maxWidth
            : minWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: effectiveWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Row
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: columns.map((col) {
                      final child = Align(
                        alignment: col.alignment,
                        child: Text(
                          col.label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B),
                          ),
                        ),
                      );

                      if (col.width != null) {
                        return SizedBox(width: col.width, child: child);
                      }
                      return Expanded(flex: col.flex, child: child);
                    }).toList(),
                  ),
                ),

                // Top Accent Linear Progress Bar if refreshing
                if (isRefreshing)
                  const TopLinearProgressBar()
                else
                  const SizedBox.shrink(),

                // Content / Skeleton Rows
                if (isLoading)
                  TableSkeletonRows(
                    columns: columns,
                    rowCount: loadingRowCount,
                    isDark: isDark,
                  )
                else
                  // Table Data Rows
                  ...rows.asMap().entries.map((entry) {
                    final index = entry.key;
                    final cells = entry.value;
                    final isEven = index % 2 == 0;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isEven
                            ? Colors.transparent
                            : (isDark ? const Color(0xFF0F172A).withValues(alpha: 0.3) : const Color(0xFFF8FAFC)),
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? const Color(0xFF334155).withValues(alpha: 0.6) : const Color(0xFFE2E8F0),
                            width: 0.8,
                          ),
                        ),
                      ),
                      child: Row(
                        children: cells.asMap().entries.map((cellEntry) {
                          final colIdx = cellEntry.key;
                          final cellWidget = cellEntry.value;
                          final colDef = columns[colIdx];

                          final alignedChild = Align(
                            alignment: colDef.alignment,
                            child: cellWidget,
                          );

                          if (colDef.width != null) {
                            return SizedBox(width: colDef.width, child: alignedChild);
                          }
                          return Expanded(flex: colDef.flex, child: alignedChild);
                        }).toList(),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}

