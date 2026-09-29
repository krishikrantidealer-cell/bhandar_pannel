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

  int countByStatus(OrderStatus s) => orders.where((o) => o.status == s).length;
  int get notConfirmedCount => countByStatus(OrderStatus.notConfirmed);
  int get pendingCount => notConfirmedCount;
  int get confirmedCount => countByStatus(OrderStatus.confirmed);
  int get processingCount => confirmedCount;
  int get shippedCount => countByStatus(OrderStatus.shipped);
  int get rackUpCount => countByStatus(OrderStatus.rackUp);
  int get inTransitCount => countByStatus(OrderStatus.inTransit);
  int get outForDeliveryCount => countByStatus(OrderStatus.outForDelivery);
  int get deliveredCount => countByStatus(OrderStatus.delivered);
  int get rtoInTransitCount => countByStatus(OrderStatus.rtoInTransit);
  int get rtoDeliveredCount => countByStatus(OrderStatus.rtoDelivered);
  int get holdCount => countByStatus(OrderStatus.hold);
  int get delayedCount => countByStatus(OrderStatus.delayed);
  int get lostCount => countByStatus(OrderStatus.lost);
  int get cancelledCount => countByStatus(OrderStatus.cancelled);

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
