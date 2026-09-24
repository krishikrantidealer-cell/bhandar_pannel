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

class AddBannerEvent extends BannerEvent {
  final Map<String, dynamic> data;
  const AddBannerEvent(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateBannerEvent extends BannerEvent {
  final String id;
  final Map<String, dynamic> data;
  const UpdateBannerEvent(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class DeleteBannerEvent extends BannerEvent {
  final String bannerId;
  const DeleteBannerEvent(this.bannerId);

  @override
  List<Object?> get props => [bannerId];
}
