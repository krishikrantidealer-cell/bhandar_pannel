import 'package:equatable/equatable.dart';
import '../../models/order_model.dart';

enum OrderStateStatus { initial, loading, success, failure }

class OrderState extends Equatable {
  final OrderStateStatus status;
  final List<OrderModel> orders;
  final String? errorMessage;

  const OrderState({
    this.status = OrderStateStatus.initial,
    this.orders = const [],
    this.errorMessage,
  });

  bool get isLoading => status == OrderStateStatus.loading;

  OrderState copyWith({
    OrderStateStatus? status,
    List<OrderModel>? orders,
    String? errorMessage,
  }) {
    return OrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, orders, errorMessage];
}
