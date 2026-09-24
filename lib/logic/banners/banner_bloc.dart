import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/bhandar_repository.dart';
import 'banner_event.dart';
import 'banner_state.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  final BhandarRepository repository;

  BannerBloc({required this.repository}) : super(const BannerState()) {
    on<LoadBanners>(_onLoadBanners);
    on<ToggleBannerStatusEvent>(_onToggleBannerStatus);
    on<AddBannerEvent>(_onAddBanner);
    on<UpdateBannerEvent>(_onUpdateBanner);
    on<DeleteBannerEvent>(_onDeleteBanner);

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

  Future<void> _onToggleBannerStatus(ToggleBannerStatusEvent event, Emitter<BannerState> emit) async {
    bool? newActive;
    final updatedList = state.banners.map((b) {
      if (b.id == event.bannerId) {
        newActive = !b.isActive;
        return b.copyWith(isActive: newActive!);
      }
      return b;
    }).toList();
    emit(state.copyWith(banners: updatedList));

    if (newActive != null) {
      try {
        await repository.updateBanner(event.bannerId, {'isActive': newActive});
      } catch (_) {}
    }
  }

  Future<void> _onAddBanner(AddBannerEvent event, Emitter<BannerState> emit) async {
    try {
      final newBanner = await repository.addBanner(event.data);
      final updated = [newBanner, ...state.banners];
      emit(state.copyWith(banners: updated));
    } catch (_) {
      add(const LoadBanners());
    }
  }

  Future<void> _onUpdateBanner(UpdateBannerEvent event, Emitter<BannerState> emit) async {
    try {
      final updatedBanner = await repository.updateBanner(event.id, event.data);
      final updated = state.banners.map((b) => b.id == event.id ? updatedBanner : b).toList();
      emit(state.copyWith(banners: updated));
    } catch (_) {
      add(const LoadBanners());
    }
  }

  Future<void> _onDeleteBanner(DeleteBannerEvent event, Emitter<BannerState> emit) async {
    final updated = state.banners.where((b) => b.id != event.bannerId).toList();
    emit(state.copyWith(banners: updated));
    try {
      await repository.deleteBanner(event.bannerId);
    } catch (_) {
      add(const LoadBanners());
    }
  }
}
