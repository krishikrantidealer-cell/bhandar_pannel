import 'package:equatable/equatable.dart';
import '../../models/order_model.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrderEvent {
  final bool refresh;
  const LoadOrders({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class SearchOrders extends OrderEvent {
  final String query;
  const SearchOrders(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterOrdersByStatus extends OrderEvent {
  final OrderStatus? status;
  const FilterOrdersByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class UpdateOrderStatusEvent extends OrderEvent {
  final String orderId;
  final OrderStatus newStatus;

  const UpdateOrderStatusEvent({required this.orderId, required this.newStatus});

  @override
  List<Object?> get props => [orderId, newStatus];
}

