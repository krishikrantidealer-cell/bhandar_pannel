import 'package:equatable/equatable.dart';
import '../../models/order_model.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrderEvent {
  const LoadOrders();
}

class UpdateOrderStatusEvent extends OrderEvent {
  final String orderId;
  final OrderStatus newStatus;

  const UpdateOrderStatusEvent({required this.orderId, required this.newStatus});

  @override
  List<Object?> get props => [orderId, newStatus];
}
