import 'package:equatable/equatable.dart';
import '../../models/collection_model.dart';

enum CollectionStatus { initial, loading, success, failure }

class CollectionState extends Equatable {
  final CollectionStatus status;
  final List<CollectionModel> collections;
  final String? errorMessage;

  const CollectionState({
    this.status = CollectionStatus.initial,
    this.collections = const [],
    this.errorMessage,
  });

  CollectionState copyWith({
    CollectionStatus? status,
    List<CollectionModel>? collections,
    String? errorMessage,
  }) {
    return CollectionState(
      status: status ?? this.status,
      collections: collections ?? this.collections,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, collections, errorMessage];
}
