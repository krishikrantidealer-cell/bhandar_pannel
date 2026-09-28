import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_paths.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../logic/orders/order_bloc.dart';
import '../../logic/orders/order_event.dart';
import '../../logic/orders/order_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_state.dart';
import '../../models/order_model.dart';
import '../widgets/image_preview.dart';
import '../widgets/status_badge.dart';

class OrderDetailsView extends StatefulWidget {
  final String orderId;
  final OrderModel? initialOrder;

  const OrderDetailsView({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  @override
  void initState() {
    super.initState();
    final orderState = context.read<OrderBloc>().state;
    if (orderState.orders.isEmpty && !orderState.isLoading) {
      context.read<OrderBloc>().add(const LoadOrders());
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateStatus(OrderModel order, OrderStatus newStatus) {
    context.read<OrderBloc>().add(
      UpdateOrderStatusEvent(orderId: order.id, newStatus: newStatus),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ${order.orderNumber} status changed to ${newStatus.name.toUpperCase()}'),
        backgroundColor: _getStatusColor(newStatus),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return const Color(0xFF3B82F6);
      case OrderStatus.processing:
        return const Color(0xFFF59E0B);
      case OrderStatus.shipped:
        return const Color(0xFF8B5CF6);
      case OrderStatus.delivered:
        return const Color(0xFF10B981);
      case OrderStatus.cancelled:
        return const Color(0xFFEF4444);
      case OrderStatus.pending:
        return const Color(0xFF64748B);
    }
  }

  Widget _buildStatusBadge(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return StatusBadge.info('Confirmed');
      case OrderStatus.processing:
        return StatusBadge.warning('Processing');
      case OrderStatus.shipped:
        return const StatusBadge(
          label: 'Shipped',
          color: Color(0xFF8B5CF6),
          icon: Icons.local_shipping_outlined,
        );
      case OrderStatus.delivered:
        return StatusBadge.success('Delivered');
      case OrderStatus.cancelled:
        return StatusBadge.danger('Cancelled');
      case OrderStatus.pending:
        return StatusBadge.neutral('Pending');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = ResponsiveLayout.isMobile(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final primaryColor = themeState.currentPalette.primary;

        return BlocBuilder<OrderBloc, OrderState>(
          builder: (context, orderState) {
            final order = orderState.orders
                    .where((o) => o.id == widget.orderId || o.orderNumber == widget.orderId)
                    .firstOrNull ??
                widget.initialOrder;

            if (order == null) {
              if (orderState.isLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                );
              }
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 54, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 12),
                    Text(
                      'Order Not Found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'The order with ID "${widget.orderId}" could not be located.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.go(RoutePaths.orders),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Return to Orders List'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Breadcrumb & Top Action Header ─────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Breadcrumbs
                      Row(
                        children: [
                          InkWell(
                            onTap: () => context.go(RoutePaths.orders),
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_back_rounded,
                                    size: 16,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Orders',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            ),
                          ),
                          Text(
                            order.orderNumber,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),

                      // Actions
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _copyToClipboard(order.orderNumber, 'Order Number'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            icon: const Icon(Icons.copy_rounded, size: 15),
                            label: const Text('Copy ID', style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => context.read<OrderBloc>().add(const LoadOrders(refresh: true)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Refresh', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Order Title & Status Banner ────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.receipt_long_rounded, color: primaryColor, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Order ${order.orderNumber}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.4,
                                        color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _buildStatusBadge(order.status),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Placed on ${AppFormatters.formatDate(order.createdAt)} • Payment: ${order.paymentMethod} (${order.paymentStatus})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          AppFormatters.formatCurrency(order.totalAmount),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Main Content Grid (Items & Logistics) ──────────────────
                  isMobile
                      ? Column(
                          children: [
                            _buildItemsCard(context, order, isDark, primaryColor),
                            const SizedBox(height: 16),
                            _buildFinancialSummaryCard(context, order, isDark),
                            const SizedBox(height: 16),
                            _buildStatusUpdaterCard(context, order, isDark, primaryColor),
                            const SizedBox(height: 16),
                            _buildCustomerCard(context, order, isDark),
                            const SizedBox(height: 16),
                            _buildShippingCard(context, order, isDark),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Main Column (65%)
                            Expanded(
                              flex: 65,
                              child: Column(
                                children: [
                                  _buildItemsCard(context, order, isDark, primaryColor),
                                  const SizedBox(height: 16),
                                  _buildFinancialSummaryCard(context, order, isDark),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Right Sidebar Column (35%)
                            Expanded(
                              flex: 35,
                              child: Column(
                                children: [
                                  _buildStatusUpdaterCard(context, order, isDark, primaryColor),
                                  const SizedBox(height: 16),
                                  _buildCustomerCard(context, order, isDark),
                                  const SizedBox(height: 16),
                                  _buildShippingCard(context, order, isDark),
                                ],
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Items Ordered Card with prominent SKU & Thumbnails ─────────────────────
  Widget _buildItemsCard(BuildContext context, OrderModel order, bool isDark, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 18, color: Color(0xFF3B82F6)),
                  const SizedBox(width: 8),
                  Text(
                    'Line Items (${order.items.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${order.items.fold(0, (sum, i) => sum + i.quantity)} Total Units',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                SizedBox(width: 48, child: Text('ITEM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
                Expanded(flex: 5, child: Text('TITLE & SKU', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
                Expanded(flex: 2, child: Text('UNIT PRICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800), textAlign: TextAlign.right)),
                Expanded(flex: 1, child: Text('QTY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('LINE TOTAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800), textAlign: TextAlign.right)),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Items
          ...order.items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: idx < order.items.length - 1
                    ? Border(
                        bottom: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          width: 0.8,
                        ),
                      )
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image
                  ImagePreview(
                    url: item.image,
                    width: 44,
                    height: 44,
                    borderRadius: 8,
                    enableEnlarge: true,
                    title: item.title,
                    subtitle: item.sku != null ? 'SKU: ${item.sku}' : null,
                  ),
                  const SizedBox(width: 12),

                  // Title, SKU & Variant
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // SKU Badge
                            if (item.sku != null && item.sku!.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  'SKU: ${item.sku}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'monospace',
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            if (item.variantTitle != null && item.variantTitle != item.sku) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Option: ${item.variantTitle}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Unit Price
                  Expanded(
                    flex: 2,
                    child: Text(
                      AppFormatters.formatCurrency(item.unitPrice),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),

                  // Quantity
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${item.quantity}',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Total
                  Expanded(
                    flex: 2,
                    child: Text(
                      AppFormatters.formatCurrency(item.totalAmount),
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Financial Summary Card ────────────────────────────────────────────────
  Widget _buildFinancialSummaryCard(BuildContext context, OrderModel order, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_outlined, size: 18, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Text(
                'Financial & Payment Summary',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildSummaryRow(
            'Subtotal',
            AppFormatters.formatCurrency(order.subtotal > 0 ? order.subtotal : order.totalAmount),
            isDark,
          ),
          if (order.discount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Discount Applied',
              '-${AppFormatters.formatCurrency(order.discount)}',
              isDark,
              color: const Color(0xFFEF4444),
            ),
          ],
          if (order.deliveryCharge > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Delivery / Shipping Fee',
              AppFormatters.formatCurrency(order.deliveryCharge),
              isDark,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Grand Total',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Via ${order.paymentMethod} • Status: ${order.paymentStatus}',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Text(
                AppFormatters.formatCurrency(order.totalAmount),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Status Updater Card ───────────────────────────────────────────────────
  Widget _buildStatusUpdaterCard(BuildContext context, OrderModel order, bool isDark, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sync_alt_rounded, size: 18, color: Color(0xFF8B5CF6)),
              const SizedBox(width: 8),
              Text(
                'Fulfillment Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: OrderStatus.values.map((status) {
              final isSelected = order.status == status;
              final color = _getStatusColor(status);

              return FilterChip(
                label: Text(
                  status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                  ),
                ),
                selected: isSelected,
                selectedColor: color,
                checkmarkColor: Colors.white,
                backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: isSelected ? color : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                  ),
                ),
                onSelected: (selected) {
                  if (selected && !isSelected) {
                    _updateStatus(order, status);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Customer Profile Card ─────────────────────────────────────────────────
  Widget _buildCustomerCard(BuildContext context, OrderModel order, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 18, color: Color(0xFF3B82F6)),
              const SizedBox(width: 8),
              Text(
                'Customer Profile',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    order.customerName.isNotEmpty ? order.customerName[0].toUpperCase() : 'C',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF3B82F6)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      order.customerPhone,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (order.customerEmail != null && order.customerEmail!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 14, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.customerEmail!,
                    style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Shipping & Delivery Card ──────────────────────────────────────────────
  Widget _buildShippingCard(BuildContext context, OrderModel order, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, size: 18, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Text(
                'Shipping & Delivery',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            order.shippingAddress.isNotEmpty ? order.shippingAddress : 'No physical shipping address provided',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: color ?? (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}
