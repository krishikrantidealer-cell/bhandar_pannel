import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/formatters.dart';
import '../../logic/orders/order_bloc.dart';
import '../../logic/orders/order_event.dart';
import '../../logic/orders/order_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_state.dart';
import '../../models/order_model.dart';
import '../widgets/custom_table.dart';
import '../widgets/status_badge.dart';
import '../widgets/image_preview.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  int _pageSize = 20;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToOrderDetails(BuildContext context, OrderModel order) {
    context.push('/orders/${order.id}', extra: order);
  }

  void _handleStatusChange(BuildContext context, OrderModel order, OrderStatus newStatus) {
    if (order.status == newStatus) return;
    context.read<OrderBloc>().add(
      UpdateOrderStatusEvent(orderId: order.id, newStatus: newStatus),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ${order.orderNumber} status changed to ${newStatus.name.toUpperCase()}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _getStatusColor(newStatus),
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

  Widget _buildInteractiveStatusCell(BuildContext context, OrderModel order, bool isDark) {
    return PopupMenuButton<OrderStatus>(
      tooltip: 'Click to change order status',
      initialValue: order.status,
      onSelected: (newStatus) => _handleStatusChange(context, order, newStatus),
      offset: const Offset(0, 30),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      itemBuilder: (context) => OrderStatus.values.map((status) {
        final color = _getStatusColor(status);
        final isCurrent = order.status == status;
        return PopupMenuItem<OrderStatus>(
          value: status,
          height: 36,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                status.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                  color: isCurrent
                      ? color
                      : (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B)),
                ),
              ),
              if (isCurrent) ...[
                const Spacer(),
                Icon(Icons.check_rounded, size: 14, color: color),
              ],
            ],
          ),
        );
      }).toList(),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusBadge(order.status),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 16,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    String? subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.16 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final primaryColor = themeState.currentPalette.primary;

        return BlocBuilder<OrderBloc, OrderState>(
          builder: (context, orderState) {
            final filteredOrders = orderState.filteredOrders;
            final totalItems = filteredOrders.length;
            final totalPages = (totalItems / _pageSize).ceil().clamp(1, 999999);
            final safeCurrentPage = _currentPage.clamp(1, totalPages);
            final startIndex = (safeCurrentPage - 1) * _pageSize;
            final endIndex = (startIndex + _pageSize).clamp(0, totalItems);
            final pagedOrders = totalItems > 0 ? filteredOrders.sublist(startIndex, endIndex) : <OrderModel>[];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header & Refresh Row ──────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Order Management',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                  color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${orderState.totalOrdersCount} Total',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Real-time customer sales, automated order fulfillment tracking, and status dispatching',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: orderState.isLoading || orderState.isRefreshing
                            ? null
                            : () => context.read<OrderBloc>().add(const LoadOrders(refresh: true)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: orderState.isRefreshing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.refresh_rounded, size: 16),
                        label: Text(
                          orderState.isRefreshing ? 'Refreshing...' : 'Refresh Orders',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── KPI Summary Cards ─────────────────────────────────────
                  Row(
                    children: [
                      _buildKpiCard(
                        title: 'Total Orders',
                        value: '${orderState.totalOrdersCount}',
                        icon: Icons.receipt_long_rounded,
                        color: const Color(0xFF3B82F6),
                        isDark: isDark,
                        subtitle: 'All customer checkouts',
                      ),
                      const SizedBox(width: 10),
                      _buildKpiCard(
                        title: 'Total Revenue',
                        value: AppFormatters.formatCompactCurrency(orderState.totalRevenue),
                        icon: Icons.currency_rupee_rounded,
                        color: const Color(0xFF10B981),
                        isDark: isDark,
                        subtitle: 'Gross non-cancelled sales',
                      ),
                      const SizedBox(width: 10),
                      _buildKpiCard(
                        title: 'Pending Action',
                        value: '${orderState.pendingCount + orderState.processingCount}',
                        icon: Icons.pending_actions_rounded,
                        color: const Color(0xFFF59E0B),
                        isDark: isDark,
                        subtitle: '${orderState.pendingCount} pending, ${orderState.processingCount} in process',
                      ),
                      const SizedBox(width: 10),
                      _buildKpiCard(
                        title: 'Delivered',
                        value: '${orderState.deliveredCount}',
                        icon: Icons.task_alt_rounded,
                        color: const Color(0xFF059669),
                        isDark: isDark,
                        subtitle: '${orderState.shippedCount} currently in transit',
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Search & Filter Bar ───────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Search Field
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: TextField(
                                  controller: _searchController,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                                  ),
                                  onChanged: (val) {
                                    setState(() => _currentPage = 1);
                                    context.read<OrderBloc>().add(SearchOrders(val));
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search by order #, customer name, phone, SKU, address, or item...',
                                    hintStyle: TextStyle(
                                      fontSize: 12.5,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                    isDense: true,
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                                    suffixIcon: _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear_rounded, size: 16),
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() => _currentPage = 1);
                                              context.read<OrderBloc>().add(const SearchOrders(''));
                                            },
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Status Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildStatusFilterChip(
                                label: 'All Orders',
                                count: orderState.totalOrdersCount,
                                isSelected: orderState.statusFilter == null,
                                primaryColor: primaryColor,
                                isDark: isDark,
                                onTap: () {
                                  setState(() => _currentPage = 1);
                                  context.read<OrderBloc>().add(const FilterOrdersByStatus(null));
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildStatusFilterChip(
                                label: 'Pending',
                                count: orderState.pendingCount,
                                isSelected: orderState.statusFilter == OrderStatus.pending,
                                primaryColor: const Color(0xFF64748B),
                                isDark: isDark,
                                onTap: () {
                                  setState(() => _currentPage = 1);
                                  context.read<OrderBloc>().add(const FilterOrdersByStatus(OrderStatus.pending));
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildStatusFilterChip(
                                label: 'Confirmed',
                                count: orderState.confirmedCount,
                                isSelected: orderState.statusFilter == OrderStatus.confirmed,
                                primaryColor: const Color(0xFF3B82F6),
                                isDark: isDark,
                                onTap: () {
                                  setState(() => _currentPage = 1);
                                  context.read<OrderBloc>().add(const FilterOrdersByStatus(OrderStatus.confirmed));
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildStatusFilterChip(
                                label: 'Processing',
                                count: orderState.processingCount,
                                isSelected: orderState.statusFilter == OrderStatus.processing,
                                primaryColor: const Color(0xFFF59E0B),
                                isDark: isDark,
                                onTap: () {
                                  setState(() => _currentPage = 1);
                                  context.read<OrderBloc>().add(const FilterOrdersByStatus(OrderStatus.processing));
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildStatusFilterChip(
                                label: 'Shipped',
                                count: orderState.shippedCount,
                                isSelected: orderState.statusFilter == OrderStatus.shipped,
                                primaryColor: const Color(0xFF8B5CF6),
                                isDark: isDark,
                                onTap: () {
                                  setState(() => _currentPage = 1);
                                  context.read<OrderBloc>().add(const FilterOrdersByStatus(OrderStatus.shipped));
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildStatusFilterChip(
                                label: 'Delivered',
                                count: orderState.deliveredCount,
                                isSelected: orderState.statusFilter == OrderStatus.delivered,
                                primaryColor: const Color(0xFF10B981),
                                isDark: isDark,
                                onTap: () {
                                  setState(() => _currentPage = 1);
                                  context.read<OrderBloc>().add(const FilterOrdersByStatus(OrderStatus.delivered));
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildStatusFilterChip(
                                label: 'Cancelled',
                                count: orderState.cancelledCount,
                                isSelected: orderState.statusFilter == OrderStatus.cancelled,
                                primaryColor: const Color(0xFFEF4444),
                                isDark: isDark,
                                onTap: () {
                                  setState(() => _currentPage = 1);
                                  context.read<OrderBloc>().add(const FilterOrdersByStatus(OrderStatus.cancelled));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Orders Data Table ─────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Orders List ($totalItems matching)',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        CustomTable(
                          minWidth: 950,
                          isLoading: orderState.isLoading,
                          isRefreshing: orderState.isRefreshing,
                          loadingRowCount: 8,
                          emptyMessage: 'No orders found matching your criteria',
                          columns: const [
                            TableColumnDef(label: 'Order #', flex: 2),
                            TableColumnDef(label: 'Customer', flex: 3),
                            TableColumnDef(label: 'Items & SKU', flex: 3),
                            TableColumnDef(label: 'Payment', flex: 2),
                            TableColumnDef(label: 'Date & Time', flex: 2),
                            TableColumnDef(label: 'Status', flex: 2),
                            TableColumnDef(label: 'Actions', width: 90, alignment: Alignment.centerRight),
                          ],
                          rows: pagedOrders.map((order) {
                            return [
                              // Order #
                              InkWell(
                                onTap: () => _navigateToOrderDetails(context, order),
                                borderRadius: BorderRadius.circular(4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      order.orderNumber,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: primaryColor,
                                      ),
                                    ),
                                    Text(
                                      'ID: ${order.id.length > 8 ? order.id.substring(order.id.length - 8) : order.id}',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Customer
                              InkWell(
                                onTap: () => _navigateToOrderDetails(context, order),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      order.customerName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      order.customerPhone,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              // Items & Amount
                              InkWell(
                                onTap: () => _navigateToOrderDetails(context, order),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (order.items.isNotEmpty)
                                      ImagePreview(
                                        url: order.items.first.image,
                                        width: 32,
                                        height: 32,
                                        borderRadius: 5,
                                        enableEnlarge: true,
                                        title: order.items.first.title,
                                        subtitle: order.items.first.sku != null ? 'SKU: ${order.items.first.sku}' : null,
                                      ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            AppFormatters.formatCurrency(order.totalAmount),
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                                            ),
                                          ),
                                          Text(
                                            order.items.isNotEmpty && order.items.first.sku != null && order.items.first.sku!.isNotEmpty
                                                ? 'SKU: ${order.items.first.sku}'
                                                : '${order.items.length} item(s)',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w600,
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
                              ),

                              // Payment
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    order.paymentMethod,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    order.paymentStatus,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),

                              // Date & Time
                              Text(
                                AppFormatters.formatDate(order.createdAt),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                ),
                              ),

                              // Status
                              _buildInteractiveStatusCell(context, order, isDark),

                              // Actions
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TableActionButton.view(
                                    tooltip: 'View Order Details',
                                    onTap: () => _navigateToOrderDetails(context, order),
                                  ),
                                ],
                              ),
                            ];
                          }).toList(),
                        ),

                        const SizedBox(height: 10),

                        // ── Pagination Footer ─────────────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.4) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left: Count & Page size selector
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    totalItems == 0
                                        ? 'No orders'
                                        : 'Showing ${startIndex + 1}–$endIndex of $totalItems orders',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF334155),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    'Rows per page:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF334155),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: _pageSize,
                                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                      items: const [
                                        DropdownMenuItem(value: 10, child: Text('10', style: TextStyle(fontSize: 12))),
                                        DropdownMenuItem(value: 20, child: Text('20', style: TextStyle(fontSize: 12))),
                                        DropdownMenuItem(value: 50, child: Text('50', style: TextStyle(fontSize: 12))),
                                        DropdownMenuItem(value: 100, child: Text('100', style: TextStyle(fontSize: 12))),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            _pageSize = val;
                                            _currentPage = 1;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              // Right: Page navigation buttons
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.first_page_rounded, size: 18),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints.tightFor(width: 26, height: 26),
                                    tooltip: 'First Page',
                                    onPressed: safeCurrentPage > 1
                                        ? () => setState(() => _currentPage = 1)
                                        : null,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left_rounded, size: 18),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints.tightFor(width: 26, height: 26),
                                    tooltip: 'Previous Page',
                                    onPressed: safeCurrentPage > 1
                                        ? () => setState(() => _currentPage = safeCurrentPage - 1)
                                        : null,
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Page $safeCurrentPage of $totalPages',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right_rounded, size: 18),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints.tightFor(width: 26, height: 26),
                                    tooltip: 'Next Page',
                                    onPressed: safeCurrentPage < totalPages
                                        ? () => setState(() => _currentPage = safeCurrentPage + 1)
                                        : null,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.last_page_rounded, size: 18),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints.tightFor(width: 26, height: 26),
                                    tooltip: 'Last Page',
                                    onPressed: safeCurrentPage < totalPages
                                        ? () => setState(() => _currentPage = totalPages)
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildStatusFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required Color primaryColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.25 : 0.12)
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : primaryColor)
                    : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
