import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/bhandar_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final BhandarRepository repository;

  DashboardBloc({required this.repository}) : super(const DashboardState()) {
    on<LoadDashboardData>(_onLoadDashboardData);

    add(const LoadDashboardData());
  }

  Future<void> _onLoadDashboardData(LoadDashboardData event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final results = await Future.wait([
        repository.getDashboardStats(),
        repository.getOrders(),
      ]);

      emit(state.copyWith(
        status: DashboardStatus.success,
        stats: results[0] as dynamic,
        recentOrders: results[1] as dynamic,
      ));
    } catch (e) {
      emit(state.copyWith(status: DashboardStatus.failure, errorMessage: e.toString()));
    }
  }
}
