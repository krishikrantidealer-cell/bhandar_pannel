import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  factory StatusBadge.success(String label, {IconData? icon}) =>
      StatusBadge(label: label, color: const Color(0xFF10B981), icon: icon ?? Icons.check_circle_outline);

  factory StatusBadge.warning(String label, {IconData? icon}) =>
      StatusBadge(label: label, color: const Color(0xFFF59E0B), icon: icon ?? Icons.warning_amber_rounded);

  factory StatusBadge.danger(String label, {IconData? icon}) =>
      StatusBadge(label: label, color: const Color(0xFFEF4444), icon: icon ?? Icons.cancel_outlined);

  factory StatusBadge.info(String label, {IconData? icon}) =>
      StatusBadge(label: label, color: const Color(0xFF3B82F6), icon: icon ?? Icons.info_outline);

  factory StatusBadge.neutral(String label, {IconData? icon}) =>
      StatusBadge(label: label, color: const Color(0xFF64748B), icon: icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
