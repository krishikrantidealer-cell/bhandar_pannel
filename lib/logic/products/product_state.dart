import 'package:equatable/equatable.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<ProductModel> allProducts;
  final String? selectedCategory;
  final String? selectedSubCategory;
  final String searchQuery;
  final String? errorMessage;

  const ProductState({
    this.status = ProductStatus.initial,
    this.allProducts = const [],
    this.selectedCategory,
    this.selectedSubCategory,
    this.searchQuery = '',
    this.errorMessage,
  });

  bool get isLoading => status == ProductStatus.loading;
  List<ProductModel> get products => allProducts;

  List<ProductModel> getFilteredProducts(List<CategoryModel> categories) {
    return allProducts.where((p) {
      final catName = p.resolveCategoryName(categories);
      final subCatName = p.resolveSubCategoryName(categories);

      final matchesCategory = selectedCategory == null ||
          selectedCategory!.isEmpty ||
          catName.toLowerCase() == selectedCategory!.toLowerCase() ||
          p.category.toLowerCase() == selectedCategory!.toLowerCase() ||
          p.categoryIds.any((cid) {
            final c = categories.where((cat) => cat.id == cid || cat.slug == cid).firstOrNull;
            return c != null && c.name.toLowerCase() == selectedCategory!.toLowerCase();
          });

      final matchesSubCategory = selectedSubCategory == null ||
          selectedSubCategory!.isEmpty ||
          (subCatName != null && subCatName.toLowerCase() == selectedSubCategory!.toLowerCase()) ||
          (p.subCategory != null && p.subCategory!.toLowerCase() == selectedSubCategory!.toLowerCase()) ||
          p.categoryIds.any((cid) {
            final c = categories.where((cat) => cat.id == cid || cat.slug == cid).firstOrNull;
            return c != null && c.name.toLowerCase() == selectedSubCategory!.toLowerCase();
          });

      final matchesSearch = searchQuery.isEmpty ||
          p.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          catName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (subCatName != null && subCatName.toLowerCase().contains(searchQuery.toLowerCase())) ||
          p.brand.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (p.sku != null && p.sku!.toLowerCase().contains(searchQuery.toLowerCase()));

      return matchesCategory && matchesSubCategory && matchesSearch;
    }).toList();
  }

  List<ProductModel> get filteredProducts => getFilteredProducts(const []);

  ProductState copyWith({
    ProductStatus? status,
    List<ProductModel>? allProducts,
    String? selectedCategory,
    bool clearCategory = false,
    String? selectedSubCategory,
    bool clearSubCategory = false,
    String? searchQuery,
    String? errorMessage,
  }) {
    return ProductState(
      status: status ?? this.status,
      allProducts: allProducts ?? this.allProducts,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedSubCategory: clearSubCategory ? null : (selectedSubCategory ?? this.selectedSubCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, allProducts, selectedCategory, selectedSubCategory, searchQuery, errorMessage];
}
