import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/bhandar_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final BhandarRepository repository;

  ProductBloc({required this.repository}) : super(const ProductState()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
    on<FilterProductsByCategory>(_onFilterProductsByCategory);
    on<FilterProductsBySubCategory>(_onFilterProductsBySubCategory);
    on<AddProductEvent>(_onAddProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);

    add(const LoadProducts());
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    if (state.allProducts.isEmpty) {
      emit(state.copyWith(status: ProductStatus.loading));
    }
    try {
      final products = await repository.getProducts();
      emit(state.copyWith(status: ProductStatus.success, allProducts: products));
    } catch (e) {
      if (state.allProducts.isEmpty) {
        emit(state.copyWith(status: ProductStatus.failure, errorMessage: e.toString()));
      }
    }
  }

  void _onSearchProducts(SearchProducts event, Emitter<ProductState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onFilterProductsByCategory(FilterProductsByCategory event, Emitter<ProductState> emit) {
    if (event.category == null || event.category!.isEmpty) {
      emit(state.copyWith(clearCategory: true, clearSubCategory: true));
    } else {
      emit(state.copyWith(selectedCategory: event.category, clearSubCategory: true));
    }
  }

  void _onFilterProductsBySubCategory(FilterProductsBySubCategory event, Emitter<ProductState> emit) {
    if (event.subCategory == null || event.subCategory!.isEmpty) {
      emit(state.copyWith(clearSubCategory: true));
    } else {
      emit(state.copyWith(selectedSubCategory: event.subCategory));
    }
  }

  Future<void> _onAddProduct(AddProductEvent event, Emitter<ProductState> emit) async {
    final optimisticList = [event.product, ...state.allProducts];
    emit(state.copyWith(allProducts: optimisticList));
    try {
      final created = await repository.addProduct(event.product.toJson());
      final updatedList = [created, ...state.allProducts.where((p) => p.id != event.product.id && p.id != created.id)];
      emit(state.copyWith(allProducts: updatedList));
    } catch (_) {
      try {
        final products = await repository.getProducts();
        emit(state.copyWith(allProducts: products));
      } catch (_) {}
    }
  }

  Future<void> _onUpdateProduct(UpdateProductEvent event, Emitter<ProductState> emit) async {
    final optimisticList = state.allProducts.map((p) => p.id == event.product.id ? event.product : p).toList();
    emit(state.copyWith(allProducts: optimisticList));
    try {
      final updated = await repository.updateProduct(event.product.id, event.product.toJson());
      final finalizedList = state.allProducts.map((p) => p.id == event.product.id ? updated : p).toList();
      emit(state.copyWith(allProducts: finalizedList));
    } catch (_) {
      try {
        final products = await repository.getProducts();
        emit(state.copyWith(allProducts: products));
      } catch (_) {}
    }
  }

  Future<void> _onDeleteProduct(DeleteProductEvent event, Emitter<ProductState> emit) async {
    final updatedList = state.allProducts.where((p) => p.id != event.productId).toList();
    emit(state.copyWith(allProducts: updatedList));
    try {
      await repository.deleteProduct(event.productId);
    } catch (_) {
      try {
        final products = await repository.getProducts();
        emit(state.copyWith(allProducts: products));
      } catch (_) {}
    }
  }
}
