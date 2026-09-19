import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/bhandar_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final BhandarRepository repository;

  CategoryBloc({required this.repository}) : super(const CategoryState()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);

    add(const LoadCategories());
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      final categories = await repository.getCategories();
      emit(state.copyWith(status: CategoryStatus.success, categories: categories));
    } catch (e) {
      emit(state.copyWith(status: CategoryStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onAddCategory(AddCategoryEvent event, Emitter<CategoryState> emit) async {
    final updatedList = [event.category, ...state.categories];
    emit(state.copyWith(categories: updatedList));
    try {
      await repository.addCategory(event.category.toJson());
    } catch (_) {}
  }

  Future<void> _onUpdateCategory(UpdateCategoryEvent event, Emitter<CategoryState> emit) async {
    final updatedList = state.categories.map((c) => c.id == event.category.id ? event.category : c).toList();
    emit(state.copyWith(categories: updatedList));
    try {
      await repository.updateCategory(event.category.id, event.category.toJson());
    } catch (_) {}
  }

  Future<void> _onDeleteCategory(DeleteCategoryEvent event, Emitter<CategoryState> emit) async {
    final updatedList = state.categories.where((c) => c.id != event.categoryId).toList();
    emit(state.copyWith(categories: updatedList));
    try {
      await repository.deleteCategory(event.categoryId);
    } catch (_) {}
  }
}
