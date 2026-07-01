import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taggery/model/gallery_entry.dart';

// Mock provider data. This should be provided by reading a folder.
List<GalleryEntry> gallery = [
  GalleryEntry(
    source: File(
      "C:/Users/krist/Pictures/Screenshots/Skärmbild 2026-04-18 161358.png",
    ),
    isVideo: false,
    rating: .safe,
    tags: ["deltarune", "kris"],
  ),
];


// TODO: implement a folder loader

final galleryProvider = Provider(((ref) {
  return gallery;
}));
