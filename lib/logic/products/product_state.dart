import 'package:equatable/equatable.dart';
import '../../models/product_model.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<ProductModel> allProducts;
  final String? selectedCategory;
  final String searchQuery;
  final String? errorMessage;

  const ProductState({
    this.status = ProductStatus.initial,
    this.allProducts = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.errorMessage,
  });

  List<ProductModel> get filteredProducts {
    return allProducts.where((p) {
      final matchesCategory = selectedCategory == null ||
          selectedCategory!.isEmpty ||
          p.category.toLowerCase() == selectedCategory!.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          p.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  ProductState copyWith({
    ProductStatus? status,
    List<ProductModel>? allProducts,
    String? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    String? errorMessage,
  }) {
    return ProductState(
      status: status ?? this.status,
      allProducts: allProducts ?? this.allProducts,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, allProducts, selectedCategory, searchQuery, errorMessage];
}
