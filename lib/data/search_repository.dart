import 'dart:io';
import 'package:taggery/data/io_helpers.dart';

/// Repository for search options.
/// 
/// Currently only supports providing subdirectories of the source root directory.
class SearchRepository {
  List<Directory> _subdirectories = [];
  String? rootSearchPath;

  /// Get the subdirectories of the directory at [path].
  /// 
  /// The result of this is cached.
  Future<List<Directory>> getRootSubDirectories(String path) async {
    if (rootSearchPath == path) {
      return _subdirectories;
    } else {
      _subdirectories = await getSubdirectories(path).toList();
      return _subdirectories;
    }
  }
}
