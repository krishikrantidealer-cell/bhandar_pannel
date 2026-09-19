import 'package:equatable/equatable.dart';

abstract class BannerEvent extends Equatable {
  const BannerEvent();

  @override
  List<Object?> get props => [];
}

class LoadBanners extends BannerEvent {
  const LoadBanners();
}

class ToggleBannerStatusEvent extends BannerEvent {
  final String bannerId;
  const ToggleBannerStatusEvent(this.bannerId);

  @override
  List<Object?> get props => [bannerId];
}
