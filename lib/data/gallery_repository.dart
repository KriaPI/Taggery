import 'dart:ui';

import 'package:path/path.dart';
import 'package:taggery/data/io_helpers.dart';
import 'package:taggery/models/gallery.dart';

// TODO: make this load in a stream instead.
class GalleryRepository {
  List<GalleryEntry> content = [];
  String previousDirectoryPath = "";

  /// Loads the content in the directory at [path] if it has not already been loaded.
  Future<void> loadGalleryFromDirectory(String path) async {
    if (path == previousDirectoryPath) {
      return;
    }

    final medias = loadMediaFromDirectory(path);

    List<GalleryEntry> gallery = [];
    await for (final media in medias) {
      final lastModified = await media.lastModified();

      gallery.add(
        GalleryEntry(
          name: basename(media.path),
          source: media,
          isVideo: isVideo(media),
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
