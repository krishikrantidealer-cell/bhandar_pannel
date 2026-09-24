import 'package:equatable/equatable.dart';
import '../../models/banner_model.dart';

enum BannerStateStatus { initial, loading, success, failure }

class BannerState extends Equatable {
  final BannerStateStatus status;
  final List<BannerModel> banners;
  final String? errorMessage;

  const BannerState({
    this.status = BannerStateStatus.initial,
    this.banners = const [],
    this.errorMessage,
  });

  bool get isLoading => status == BannerStateStatus.loading;

  BannerState copyWith({
    BannerStateStatus? status,
    List<BannerModel>? banners,
    String? errorMessage,
  }) {
    return BannerState(
      status: status ?? this.status,
      banners: banners ?? this.banners,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, banners, errorMessage];
}
