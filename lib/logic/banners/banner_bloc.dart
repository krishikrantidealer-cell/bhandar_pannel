import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/bhandar_repository.dart';
import 'banner_event.dart';
import 'banner_state.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  final BhandarRepository repository;

  BannerBloc({required this.repository}) : super(const BannerState()) {
    on<LoadBanners>(_onLoadBanners);
    on<ToggleBannerStatusEvent>(_onToggleBannerStatus);

    add(const LoadBanners());
  }

  Future<void> _onLoadBanners(LoadBanners event, Emitter<BannerState> emit) async {
    emit(state.copyWith(status: BannerStateStatus.loading));
    try {
      final banners = await repository.getBanners();
      emit(state.copyWith(status: BannerStateStatus.success, banners: banners));
    } catch (e) {
      emit(state.copyWith(status: BannerStateStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onToggleBannerStatus(ToggleBannerStatusEvent event, Emitter<BannerState> emit) {
    final updatedList = state.banners.map((b) {
      if (b.id == event.bannerId) {
        return b.copyWith(isActive: !b.isActive);
      }
      return b;
    }).toList();
    emit(state.copyWith(banners: updatedList));
  }
}
