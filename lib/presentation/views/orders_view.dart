import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/formatters.dart';
import '../../logic/orders/order_bloc.dart';
import '../../logic/orders/order_event.dart';
import '../../logic/orders/order_state.dart';
import '../../models/order_model.dart';
import '../widgets/custom_table.dart';
import '../widgets/status_badge.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  void _showOrderDetailsModal(BuildContext context, OrderModel order) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order Details ${order.orderNumber}'),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width: 580,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Customer details block
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_pin_rounded, size: 20, color: Color(0xFF3B82F6)),
                          const SizedBox(width: 8),
                          Text(
                            order.customerName,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          const Spacer(),
                          Text(
                            order.customerPhone,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Delivery Address: ${order.shippingAddress}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Payment: ${order.paymentMethod} • Status: ${order.paymentStatus}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Text('Items Ordered', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                const SizedBox(height: 8),

                ...order.items.map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.dividerTheme.color ?? Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text('x${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 24),
                        Text(
                          AppFormatters.formatCurrency(item.totalAmount),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Paid', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    Text(
                      AppFormatters.formatCurrency(order.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF10B981)),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Text('Update Order Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: OrderStatus.values.map((status) {
                    final isSelected = order.status == status;
                    return ChoiceChip(
                      label: Text(status.name.toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          context
                              .read<OrderBloc>()
                              .add(UpdateOrderStatusEvent(orderId: order.id, newStatus: status));
                          Navigator.of(ctx).pop();
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, orderState) {
        final orders = orderState.orders;

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
                        'Farmer Order Management',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track, verify, dispatch and deliver orders placed across Bhandar apps',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomTable(
                    minWidth: 900,
                    columns: const [
                      TableColumnDef(label: 'Order ID', flex: 2),
                      TableColumnDef(label: 'Customer', flex: 3),
                      TableColumnDef(label: 'Items & Amount', flex: 2),
                      TableColumnDef(label: 'Date & Time', flex: 2),
                      TableColumnDef(label: 'Status', flex: 2),
                      TableColumnDef(label: 'Action', width: 90, alignment: Alignment.centerRight),
                    ],
                    rows: orders.map((order) {
                      StatusBadge badge;
                      switch (order.status) {
                        case OrderStatus.confirmed:
                          badge = StatusBadge.success('Confirmed');
                          break;
                        case OrderStatus.processing:
                          badge = StatusBadge.warning('Processing');
                          break;
                        case OrderStatus.shipped:
                          badge = StatusBadge.info('Shipped');
                          break;
                        case OrderStatus.delivered:
                          badge = StatusBadge.success('Delivered');
                          break;
                        case OrderStatus.cancelled:
                          badge = StatusBadge.danger('Cancelled');
                          break;
                        case OrderStatus.pending:
                          badge = StatusBadge.neutral('Pending');
                          break;
                      }

                      return [
                        // Order Number
                        Text(
                          order.orderNumber,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),

                        // Customer
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              order.customerName,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(
                              order.customerPhone,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),

                        // Amount
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppFormatters.formatCurrency(order.totalAmount),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                            ),
                            Text(
                              '${order.items.length} item(s)',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),

                        // Date
                        Text(
                          AppFormatters.formatDateShort(order.createdAt),
                          style: const TextStyle(fontSize: 12),
                        ),

                        // Status
                        badge,

                        // Action
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                          tooltip: 'View Details',
                          onPressed: () => _showOrderDetailsModal(context, order),
                        ),
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
  }
}
