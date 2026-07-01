import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taggery/data/file_system_interface.dart';
import 'package:taggery/model/gallery_entry.dart';

// Mock provider data. This should be provided by reading a folder.
List<GalleryEntry> gallery = [
  GalleryEntry(
    source: File(
      "C:/Users/krist/Pictures/Screenshots/Skärmbild 2026-04-18 161358.png",
    ),
    isVideo: false,
    rating: .safe,
    tags: [],
  ),
];


Future<List<GalleryEntry>> loadGalleryFromFolder(String directoryPath) async {
  final images = loadImagesFromDirectory(directoryPath);

  List<GalleryEntry> gallery = [];
  await for (final image in images) {
    gallery.add(GalleryEntry(source: image));
  }

  return gallery;
}

final galleryProvider = FutureProvider(((ref) {
  // TODO: provide path to folder.
  final gallery = loadGalleryFromFolder("");

  return gallery;
}));
