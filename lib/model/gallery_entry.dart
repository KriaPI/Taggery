
import 'dart:io';

enum ContentRating {safe, explicit, missing}

/// An entry in a gallery containing an image or video, 
/// its content rating, and optional tags associated with the entry. 
class GalleryEntry {
    const GalleryEntry({required this.source, this.isVideo = false, this.rating = .missing, this.tags = const []});

    final File source;
    final bool isVideo;
    final ContentRating rating; 
    final List<String> tags;
}