

/// The model for user preferences and general application configuration.
class UserConfiguration {
  String? databasePath; 
  String galleryRootPath;

  UserConfiguration({this.databasePath, required this.galleryRootPath});
}