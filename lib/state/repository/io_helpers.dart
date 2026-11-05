import 'dart:io';
import 'package:mime/mime.dart';
import 'package:stream_transform/stream_transform.dart';

/// Check if a file is an image according to its MIME type.
bool isImage(File file) {
    final mimeType = lookupMimeType(file.path);
    return mimeType != null
        ? mimeType.startsWith("image")
        : false;
}

/// Check if a file is an image according to its MIME type.
bool isVideo(File file) {
    final mimeType = lookupMimeType(file.path);
    return mimeType != null
        ? mimeType.startsWith("video")
        : false;
}

/// Load all images and videos from the directory, and its subdirectories, at path [directoryPath].
Stream<File> loadMediaFromDirectory(String directoryPath) async* {
  final directory = Directory(directoryPath);
  yield* directory.list(recursive: true).whereType<File>().where((file) => isImage(file) || isVideo(file));
}

/// Retrieve all subdirectories of the directory at [path].
Stream<Directory> getSubdirectories(String path) async* {
  final directory = Directory(path);
  yield* directory.list(recursive: true).whereType<Directory>();
}