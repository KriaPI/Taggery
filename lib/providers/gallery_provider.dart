import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taggery/data/file_system_interface.dart';
import 'package:taggery/model/gallery_entry.dart';
import 'package:taggery/providers/configuration_provider.dart';

Future<List<GalleryEntry>> loadGalleryFromFolder(String directoryPath) async {
  final images = loadImagesFromDirectory(directoryPath);

  List<GalleryEntry> gallery = [];
  await for (final image in images) {
    gallery.add(GalleryEntry(source: image));
  }

  return gallery;
}

final galleryProvider = FutureProvider((ref) async {
  final configuration = ref.watch(configurationNotifierProvider);
  return await loadGalleryFromFolder(configuration.galleryRootPath);
});
