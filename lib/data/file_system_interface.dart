import 'dart:io';
import 'package:mime/mime.dart';

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
    yield* directory.list(recursive: true).where((entity) => entity is File && isImage(entity)).map((entity) => entity as File);
}