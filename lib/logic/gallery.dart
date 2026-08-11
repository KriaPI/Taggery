import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taggery/data/gallery_repository.dart';
import 'package:taggery/models/gallery.dart';

class GalleryCubit extends Cubit<GalleryState> {
  GalleryCubit(this._repository) : super(GalleryInitial());

  final GalleryRepository _repository;

  Future<void> loadDirectory(String path) async {
    emit(GalleryLoadingInProgress());

    await _repository.loadGalleryFromDirectory(path);
    emit(GalleryLoadSuccess(content: _repository.content));
  }
}
