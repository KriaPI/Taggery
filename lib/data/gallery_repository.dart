import 'dart:ui';

import 'package:path/path.dart';
import 'package:taggery/data/file_system_interface.dart';
import 'package:taggery/models/gallery.dart';

// TODO: make this load in a stream instead.
class GalleryRepository {
  List<GalleryEntry> content = [];
  String previousDirectoryPath = "";

  /// Loads the content in the directory at [path] if it has not already been loaded.
  Future<void> loadGalleryFromDirectory(String path) async {
    // TODO: check if this makes sense.
    if (path == previousDirectoryPath) {
      return;
    }

    final images = loadImagesFromDirectory(path);

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
          tags: [
            "cat",
            "animal",
            "creature adsdsadadadmaldmalkdamdlamdlamdlamd",
          ],
        ),
      );
    }
    content = gallery;
    previousDirectoryPath = path;
  }
}
