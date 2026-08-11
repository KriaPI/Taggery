import 'dart:io';
import 'dart:ui';


enum ContentRating {safe, explicit, missing}

/// An entry in a gallery containing an image or video, 
/// its content rating, and optional tags associated with the entry. 
class GalleryEntry {
    GalleryEntry({required this.source, required this.resolution, required this.name, this.lastModified, this.isVideo = false, this.rating = .missing, this.tags = const []});

    final File source;
    final String name;
    final Size resolution;
    final DateTime? lastModified;
    final bool isVideo;
    final ContentRating rating; 
    final List<String> tags;
}

sealed class GalleryState {
  const GalleryState();
}

final class GalleryInitial extends GalleryState {
  const GalleryInitial();
}

final class GalleryLoadingInProgress extends GalleryState {
  const GalleryLoadingInProgress();
}

/// Stores the media shown in the gallery.
final class GalleryLoadSuccess extends GalleryState {
  const GalleryLoadSuccess({required this.content});

  final List<GalleryEntry> content;
}

final class GalleryLoadFailure extends GalleryState {
  const GalleryLoadFailure({required this.exception});
  final Exception exception;
}