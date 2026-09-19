import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/formatters.dart';
import '../../logic/coupons/coupon_bloc.dart';
import '../../logic/coupons/coupon_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_state.dart';
import '../../models/coupon_model.dart';
import '../widgets/custom_table.dart';
import '../widgets/status_badge.dart';

class CouponsView extends StatelessWidget {
  const CouponsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<CouponBloc, CouponState>(
          builder: (context, couponState) {
            final coupons = couponState.coupons;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Promotions & Discount Coupons',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Configure promotional codes, percentage discounts, and order thresholds',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Coupon generator modal opened')),
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Create Coupon'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CustomTable(
                        minWidth: 800,
                        columns: const [
                          TableColumnDef(label: 'Code', flex: 2),
                          TableColumnDef(label: 'Description', flex: 3),
                          TableColumnDef(label: 'Discount Value', flex: 2),
                          TableColumnDef(label: 'Min Order', flex: 2),
                          TableColumnDef(label: 'Usage Stats', flex: 2),
                          TableColumnDef(label: 'Status', width: 120, alignment: Alignment.center),
                        ],
                        rows: coupons.map((c) {
                          final isPercentage = c.discountType == DiscountType.percentage;
                          final discountStr = isPercentage
                              ? '${c.discountValue.toStringAsFixed(0)}% OFF'
                              : '₹${c.discountValue.toStringAsFixed(0)} FLAT';

                          return [
                            // Code
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: themeState.currentPalette.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: themeState.currentPalette.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                c.code,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: themeState.currentPalette.primary,
                                ),
                              ),
                            ),

                            // Description
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  c.title,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                if (c.description != null)
                                  Text(
                                    c.description!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                              ],
                            ),

                            // Discount Value
                            Text(
                              discountStr,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),

                            // Min Order
                            Text(
                              AppFormatters.formatCurrency(c.minOrderAmount),
                              style: const TextStyle(fontSize: 13),
                            ),

                            // Usage
                            Text(
                              '${c.usedCount} / ${c.usageLimit}',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),

                            // Status
                            c.isActive
                                ? StatusBadge.success('Active')
                                : StatusBadge.neutral('Inactive'),
                          ];
                        }).toList(),
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
