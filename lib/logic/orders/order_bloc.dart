import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/bhandar_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final BhandarRepository repository;

  OrderBloc({required this.repository}) : super(const OrderState()) {
    on<LoadOrders>(_onLoadOrders);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);

    add(const LoadOrders());
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStateStatus.loading));
    try {
      final orders = await repository.getOrders();
      emit(state.copyWith(status: OrderStateStatus.success, orders: orders));
    } catch (e) {
      emit(state.copyWith(status: OrderStateStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateOrderStatus(UpdateOrderStatusEvent event, Emitter<OrderState> emit) async {
    final updatedList = state.orders.map((o) {
      if (o.id == event.orderId) {
        return o.copyWith(status: event.newStatus);
      }
      return o;
    }).toList();
    emit(state.copyWith(orders: updatedList));
    try {
      await repository.updateOrderStatus(event.orderId, event.newStatus.name);
    } catch (_) {}
  }
}
