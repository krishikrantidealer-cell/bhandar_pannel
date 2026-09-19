import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/bhandar_repository.dart';
import 'coupon_event.dart';
import 'coupon_state.dart';

class CouponBloc extends Bloc<CouponEvent, CouponState> {
  final BhandarRepository repository;

  CouponBloc({required this.repository}) : super(const CouponState()) {
    on<LoadCoupons>(_onLoadCoupons);
    on<ToggleCouponStatusEvent>(_onToggleCouponStatus);

    add(const LoadCoupons());
  }

  Future<void> _onLoadCoupons(LoadCoupons event, Emitter<CouponState> emit) async {
    emit(state.copyWith(status: CouponStateStatus.loading));
    try {
      final coupons = await repository.getCoupons();
      emit(state.copyWith(status: CouponStateStatus.success, coupons: coupons));
    } catch (e) {
      emit(state.copyWith(status: CouponStateStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onToggleCouponStatus(ToggleCouponStatusEvent event, Emitter<CouponState> emit) {
    final updatedList = state.coupons.map((c) {
      if (c.id == event.couponId) {
        return c.copyWith(isActive: !c.isActive);
      }
      return c;
    }).toList();
    emit(state.copyWith(coupons: updatedList));
  }
}
