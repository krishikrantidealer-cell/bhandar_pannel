import 'package:flutter/material.dart';

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

class CustomTable extends StatelessWidget {
  final List<TableColumnDef> columns;
  final List<List<Widget>> rows;
  final bool isLoading;
  final String emptyMessage;
  final double minWidth;

  const CustomTable({
    super.key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
    this.emptyMessage = 'No records found',
    this.minWidth = 700,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (rows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              const SizedBox(height: 12),
              Text(
                emptyMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
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
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeInOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  child: Row(
                    children: columns.map((col) {
                      final child = Align(
                        alignment: col.alignment,
                        child: Text(
                          col.label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
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

                const Divider(height: 1),

                // Table Rows
                ...rows.asMap().entries.map((entry) {
                  final index = entry.key;
                  final cells = entry.value;
                  final isEven = index % 2 == 0;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeInOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isEven
                          ? Colors.transparent
                          : (isDark ? const Color(0xFF0F172A).withValues(alpha: 0.3) : const Color(0xFFF8FAFC)),
                      border: Border(
                        bottom: BorderSide(
                          color: theme.dividerTheme.color ?? Colors.grey.withValues(alpha: 0.2),
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
