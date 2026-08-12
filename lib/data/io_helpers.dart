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

/// Load all images from the directory, and its subdirectories, at path [directoryPath].
Stream<File> loadImagesFromDirectory(String directoryPath) async* {
  final directory = Directory(directoryPath);
  yield* directory.list(recursive: true).whereType<File>().where(isImage);
}

/// Retrieve all subdirectories of the directory at [path].
Stream<Directory> getSubdirectories(String path) async* {
  final directory = Directory(path);
  yield* directory.list(recursive: true).whereType<Directory>();
}