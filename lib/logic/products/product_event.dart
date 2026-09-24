import 'package:equatable/equatable.dart';
import '../../models/product_model.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  const LoadProducts();
}

class SearchProducts extends ProductEvent {
  final String query;
  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterProductsByCategory extends ProductEvent {
  final String? category;
  const FilterProductsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class FilterProductsBySubCategory extends ProductEvent {
  final String? subCategory;
  const FilterProductsBySubCategory(this.subCategory);

  @override
  List<Object?> get props => [subCategory];
}

class AddProductEvent extends ProductEvent {
  final ProductModel product;
  const AddProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProductEvent extends ProductEvent {
  final ProductModel product;
  const UpdateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProductEvent extends ProductEvent {
  final String productId;
  const DeleteProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}
