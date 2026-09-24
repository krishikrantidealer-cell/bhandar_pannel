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
    emit(state.copyWith(status: ProductStatus.loading));
    try {
      final products = await repository.getProducts();
      emit(state.copyWith(status: ProductStatus.success, allProducts: products));
    } catch (e) {
      emit(state.copyWith(status: ProductStatus.failure, errorMessage: e.toString()));
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
    final updatedList = [event.product, ...state.allProducts];
    emit(state.copyWith(allProducts: updatedList));
    try {
      await repository.addProduct(event.product.toJson());
    } catch (_) {}
  }

  Future<void> _onUpdateProduct(UpdateProductEvent event, Emitter<ProductState> emit) async {
    final updatedList = state.allProducts.map((p) => p.id == event.product.id ? event.product : p).toList();
    emit(state.copyWith(allProducts: updatedList));
    try {
      await repository.updateProduct(event.product.id, event.product.toJson());
    } catch (_) {}
  }

  Future<void> _onDeleteProduct(DeleteProductEvent event, Emitter<ProductState> emit) async {
    final updatedList = state.allProducts.where((p) => p.id != event.productId).toList();
    emit(state.copyWith(allProducts: updatedList));
    try {
      await repository.deleteProduct(event.productId);
    } catch (_) {}
  }
}
