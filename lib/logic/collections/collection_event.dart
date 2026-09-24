import 'package:equatable/equatable.dart';
import '../../models/collection_model.dart';

abstract class CollectionEvent extends Equatable {
  const CollectionEvent();

  @override
  List<Object?> get props => [];
}

class LoadCollections extends CollectionEvent {
  const LoadCollections();
}

class AddCollectionEvent extends CollectionEvent {
  final CollectionModel collection;
  const AddCollectionEvent(this.collection);

  @override
  List<Object?> get props => [collection];
}

class UpdateCollectionEvent extends CollectionEvent {
  final CollectionModel collection;
  const UpdateCollectionEvent(this.collection);

  @override
  List<Object?> get props => [collection];
}

class DeleteCollectionEvent extends CollectionEvent {
  final String collectionId;
  const DeleteCollectionEvent(this.collectionId);

  @override
  List<Object?> get props => [collectionId];
}
