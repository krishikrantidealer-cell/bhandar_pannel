import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/bhandar_repository.dart';
import 'collection_event.dart';
import 'collection_state.dart';

class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  final BhandarRepository repository;

  CollectionBloc({required this.repository}) : super(const CollectionState()) {
    on<LoadCollections>(_onLoadCollections);
    on<AddCollectionEvent>(_onAddCollection);
    on<UpdateCollectionEvent>(_onUpdateCollection);
    on<DeleteCollectionEvent>(_onDeleteCollection);

    add(const LoadCollections());
  }

  Future<void> _onLoadCollections(LoadCollections event, Emitter<CollectionState> emit) async {
    emit(state.copyWith(status: CollectionStatus.loading));
    try {
      final collections = await repository.getCollections();
      emit(state.copyWith(status: CollectionStatus.success, collections: collections));
    } catch (e) {
      emit(state.copyWith(status: CollectionStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onAddCollection(AddCollectionEvent event, Emitter<CollectionState> emit) async {
    final updatedList = [event.collection, ...state.collections];
    emit(state.copyWith(collections: updatedList));
    try {
      await repository.addCollection(event.collection.toJson());
    } catch (_) {}
  }

  Future<void> _onUpdateCollection(UpdateCollectionEvent event, Emitter<CollectionState> emit) async {
    final updatedList = state.collections.map((c) => c.id == event.collection.id ? event.collection : c).toList();
    emit(state.copyWith(collections: updatedList));
    try {
      await repository.updateCollection(event.collection.id, event.collection.toJson());
    } catch (_) {}
  }

  Future<void> _onDeleteCollection(DeleteCollectionEvent event, Emitter<CollectionState> emit) async {
    final updatedList = state.collections.where((c) => c.id != event.collectionId).toList();
    emit(state.copyWith(collections: updatedList));
    try {
      await repository.deleteCollection(event.collectionId);
    } catch (_) {}
  }
}
