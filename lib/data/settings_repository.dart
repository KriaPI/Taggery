import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  SettingsRepository();
  final SharedPreferencesAsync _asyncPreferences = SharedPreferencesAsync();
  static const String _sourceRootDirectoryKey = "sourceRootPath";

  /// Retreive the root of the source directory. A return value of Null indicates that
  /// the root has not been set. Call [setSourceDirectory] to set the root.
  Future<String?> get sourceRootDirectory async {
    return await _asyncPreferences.getString(_sourceRootDirectoryKey);
  }
  
  /// Set the root of the source directory. This is persisted to disk.
  Future<void> setSourceRootDirectory(String path) async {
    return _asyncPreferences.setString(_sourceRootDirectoryKey, path);
  }
}