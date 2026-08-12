import 'dart:io';
import 'package:taggery/data/io_helpers.dart';

/// Repository for search suggestions.
/// 
/// Currently only supports providing subdirectories of the source root directory.
class SearchRepository {
  List<Directory> subdirectories = [];

  /// TODO: Consider calling this in the constructor
  /// Load the subdirectories of the directory at [path].
  Future<void> loadRootSubDirectories(String path) async {

    subdirectories = await getSubdirectories(path).toList();
  }
}
