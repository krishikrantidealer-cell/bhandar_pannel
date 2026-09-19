import 'package:equatable/equatable.dart';

abstract class CouponEvent extends Equatable {
  const CouponEvent();

  @override
  List<Object?> get props => [];
}

class LoadCoupons extends CouponEvent {
  const LoadCoupons();
}

class ToggleCouponStatusEvent extends CouponEvent {
  final String couponId;
  const ToggleCouponStatusEvent(this.couponId);

  @override
  List<Object?> get props => [couponId];
}
