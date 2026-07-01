import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taggery/model/user_configuration.dart';


class ConfigurationNotifier extends Notifier<UserConfiguration> {
  
  @override
  UserConfiguration build() {
    // TODO: use sharedpreferences to load this. 
    return UserConfiguration(galleryRootPath: "");
  }

  void setGalleryRootDirectory(String path) {
    // TODO: use sharedpreferences to store the configuration (maybe instead on program exit). 
    state = UserConfiguration(galleryRootPath: path);
  }
}

final configurationNotifierProvider = NotifierProvider<ConfigurationNotifier, UserConfiguration>(() {
  return ConfigurationNotifier();
});