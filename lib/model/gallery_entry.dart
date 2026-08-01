
import 'dart:io';

enum ContentRating {safe, explicit, missing}

/// An entry in a gallery containing an image or video, 
/// its content rating, and optional tags associated with the entry. 
class GalleryEntry {
    GalleryEntry({required this.source, required this.name, this.lastModified, this.isVideo = false, this.rating = .missing, this.tags = const []});

    final File source;
    final String name;
    final DateTime? lastModified;
    final bool isVideo;
    final ContentRating rating; 
    final List<String> tags;
}