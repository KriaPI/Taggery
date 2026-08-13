import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  SettingsRepository();
  final SharedPreferencesAsync _asyncPreferences = SharedPreferencesAsync();
  static const String _sourceRootDirectoryKey = "sourceRootPath";

  String? _sourceRootDirectory;

  /// Retreive the root of the source directory. 
  /// 
  /// A return value of Null indicates that the root has not been set. Call [setSourceDirectory] to set the root.
  /// The result of this getter is cached.
  Future<String?> get sourceRootDirectory async {
    if (_sourceRootDirectory == null) {
      _sourceRootDirectory = await _asyncPreferences.getString(_sourceRootDirectoryKey);
      return _sourceRootDirectory;
    } else {
      return _sourceRootDirectory;
    }
  }
  
  /// Set the root of the source directory. This is persisted to disk.
  Future<void> setSourceRootDirectory(String path) async {
    _asyncPreferences.setString(_sourceRootDirectoryKey, path);
    _sourceRootDirectory = await _asyncPreferences.getString(_sourceRootDirectoryKey);
  }
}