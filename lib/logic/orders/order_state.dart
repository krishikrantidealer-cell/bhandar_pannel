import 'package:equatable/equatable.dart';
import '../../models/order_model.dart';

enum OrderStateStatus { initial, loading, success, failure }

class OrderState extends Equatable {
  final OrderStateStatus status;
  final List<OrderModel> orders;
  final String searchQuery;
  final OrderStatus? statusFilter;
  final String? errorMessage;
  final bool isRefreshing;

  const OrderState({
    this.status = OrderStateStatus.initial,
    this.orders = const [],
    this.searchQuery = '',
    this.statusFilter,
    this.errorMessage,
    this.isRefreshing = false,
  });

  bool get isLoading => status == OrderStateStatus.loading;

  List<OrderModel> get filteredOrders {
    var result = orders;

    if (statusFilter != null) {
      result = result.where((o) => o.status == statusFilter).toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      result = result.where((o) {
        final matchesOrderNum = o.orderNumber.toLowerCase().contains(q);
        final matchesCustomer = o.customerName.toLowerCase().contains(q);
        final matchesPhone = o.customerPhone.toLowerCase().contains(q);
        final matchesEmail = o.customerEmail?.toLowerCase().contains(q) ?? false;
        final matchesAddress = o.shippingAddress.toLowerCase().contains(q);
        final matchesItems = o.items.any((item) => item.title.toLowerCase().contains(q));
        final matchesPayment = o.paymentMethod.toLowerCase().contains(q) || o.paymentStatus.toLowerCase().contains(q);

        return matchesOrderNum || matchesCustomer || matchesPhone || matchesEmail || matchesAddress || matchesItems || matchesPayment;
      }).toList();
    }

    return result;
  }

  int get totalOrdersCount => orders.length;

  double get totalRevenue => orders
      .where((o) => o.status != OrderStatus.cancelled)
      .fold(0.0, (sum, o) => sum + o.totalAmount);

  int get pendingCount => orders.where((o) => o.status == OrderStatus.pending).length;
  int get confirmedCount => orders.where((o) => o.status == OrderStatus.confirmed).length;
  int get processingCount => orders.where((o) => o.status == OrderStatus.processing).length;
  int get shippedCount => orders.where((o) => o.status == OrderStatus.shipped).length;
  int get deliveredCount => orders.where((o) => o.status == OrderStatus.delivered).length;
  int get cancelledCount => orders.where((o) => o.status == OrderStatus.cancelled).length;

  OrderState copyWith({
    OrderStateStatus? status,
    List<OrderModel>? orders,
    String? searchQuery,
    OrderStatus? Function()? statusFilter,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return OrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter != null ? statusFilter() : this.statusFilter,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [status, orders, searchQuery, statusFilter, errorMessage, isRefreshing];
}
