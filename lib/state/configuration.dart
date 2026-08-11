import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taggery/models/user_configuration.dart';


class ConfigurationNotifier extends AsyncNotifier<UserConfiguration> {
  final locallyStoredPreferences = SharedPreferencesAsync();

  @override
  FutureOr<UserConfiguration> build() async {
    final galleryRootPath = await locallyStoredPreferences.getString("galleryRootPath");
    return UserConfiguration(galleryRootPath: galleryRootPath);
  }

  void setGalleryRootDirectory(String path) async {
    state = AsyncData(UserConfiguration(galleryRootPath: path));
    locallyStoredPreferences.setString("galleryRootPath", path);
  }
}

/// Provides application configuration loaded from local storage.
/// 
/// Values of the provider may be null if they have not been set yet by the user of the application.
final configurationNotifierProvider = AsyncNotifierProvider<ConfigurationNotifier, UserConfiguration>(() {
  return ConfigurationNotifier();
});