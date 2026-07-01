import 'dart:convert';
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

/// Load the application configuration file.
/// 
/// [configurationPath] is the path to the json file containing the application configuration.  
Future<Map<String, dynamic>?> loadConfiguration(String configurationPath) async {
  final configurationFile = File(configurationPath);
  if (await configurationFile.exists() == false) {
    return null;
  }

  final content = await configurationFile.readAsString();
  return jsonDecode(content);
}

/// Save changes to the application configuration file or create it.
void saveConfiguration(String configurationPath, String jsonSource) async {
  final configurationFile = File(configurationPath);
  if (await configurationFile.exists() == false) {
    configurationFile.create();
  }
  
  configurationFile.writeAsString(jsonSource);
}