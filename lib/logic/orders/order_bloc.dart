import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/bhandar_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final BhandarRepository repository;
  Timer? _pollingTimer;

  OrderBloc({required this.repository}) : super(const OrderState()) {
    on<LoadOrders>(_onLoadOrders);
    on<SearchOrders>(_onSearchOrders);
    on<FilterOrdersByStatus>(_onFilterOrdersByStatus);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);

    add(const LoadOrders());

    // Automatically poll every 10 seconds in the background so manual refresh is unnecessary
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      add(const LoadOrders(refresh: true));
    });
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrderState> emit) async {
    if (event.refresh && state.orders.isNotEmpty) {
      emit(state.copyWith(isRefreshing: true));
    } else {
      emit(state.copyWith(status: OrderStateStatus.loading));
    }

    try {
      final orders = await repository.getOrders();
      emit(state.copyWith(
        status: OrderStateStatus.success,
        orders: orders,
        isRefreshing: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: state.orders.isNotEmpty ? OrderStateStatus.success : OrderStateStatus.failure,
        errorMessage: e.toString(),
        isRefreshing: false,
      ));
    }
  }

  void _onSearchOrders(SearchOrders event, Emitter<OrderState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onFilterOrdersByStatus(FilterOrdersByStatus event, Emitter<OrderState> emit) {
    emit(state.copyWith(statusFilter: () => event.status));
  }

  Future<void> _onUpdateOrderStatus(UpdateOrderStatusEvent event, Emitter<OrderState> emit) async {
    // Optimistically update the UI immediately
    final updatedList = state.orders.map((o) {
      if (o.id == event.orderId || o.orderNumber == event.orderId) {
        return o.copyWith(status: event.newStatus);
      }
      return o;
    }).toList();
    emit(state.copyWith(orders: updatedList));

    try {
      final updatedOrder = await repository.updateOrderStatus(event.orderId, event.newStatus.name);
      final syncedList = state.orders.map((o) {
        if (o.id == event.orderId || o.id == updatedOrder.id || o.orderNumber == event.orderId) {
          return updatedOrder;
        }
        return o;
      }).toList();
      emit(state.copyWith(orders: syncedList));
    } catch (e) {
      // Re-fetch to guarantee consistency if server update failed
      add(const LoadOrders(refresh: true));
    }
  }
}

