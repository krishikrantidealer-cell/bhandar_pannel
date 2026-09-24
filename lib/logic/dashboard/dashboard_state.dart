import 'package:equatable/equatable.dart';
import '../../models/dashboard_stats.dart';
import '../../models/order_model.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final DashboardStats stats;
  final List<OrderModel> recentOrders;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.stats = const DashboardStats(),
    this.recentOrders = const [],
    this.errorMessage,
  });

  bool get isLoading => status == DashboardStatus.loading;

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardStats? stats,
    List<OrderModel>? recentOrders,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      recentOrders: recentOrders ?? this.recentOrders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, stats, recentOrders, errorMessage];
}
