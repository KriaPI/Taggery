import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:taggery/data/file_system_interface.dart';
import 'package:taggery/model/gallery_entry.dart';
import 'package:taggery/providers/configuration_provider.dart';

Future<List<GalleryEntry>> loadGalleryFromFolder(String directoryPath) async {
  final images = loadImagesFromDirectory(directoryPath);

  List<GalleryEntry> gallery = [];
  await for (final image in images) {
    final lastModified = await image.lastModified();

    gallery.add(
      GalleryEntry(
        name: basename(image.path),
        source: image,
        // TODO: use something to get the size of an image.
        resolution: Size(400, 400),
        lastModified: lastModified,
        tags: ["cat", "animal", "creature adsdsadadadmaldmalkdamdlamdlamdlamd"],
      ),
    );
  }

  return gallery;
}

final galleryProvider = FutureProvider((ref) async {
  final configuration = await ref.watch(configurationNotifierProvider.future);

  return configuration.galleryRootPath != null
      ? await loadGalleryFromFolder(configuration.galleryRootPath!)
      : [];
});
