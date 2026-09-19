import 'package:equatable/equatable.dart';
import '../../models/coupon_model.dart';

enum CouponStateStatus { initial, loading, success, failure }

class CouponState extends Equatable {
  final CouponStateStatus status;
  final List<CouponModel> coupons;
  final String? errorMessage;

  const CouponState({
    this.status = CouponStateStatus.initial,
    this.coupons = const [],
    this.errorMessage,
  });

  CouponState copyWith({
    CouponStateStatus? status,
    List<CouponModel>? coupons,
    String? errorMessage,
  }) {
    return CouponState(
      status: status ?? this.status,
      coupons: coupons ?? this.coupons,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, coupons, errorMessage];
}
