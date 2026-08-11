sealed class SettingsState {
  const SettingsState();
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

final class SettingsLoadingInProgress extends SettingsState {
  const SettingsLoadingInProgress();
}

final class SettingsNeedsSetup extends SettingsState {
  const SettingsNeedsSetup();
}

/// Stores all user settings.
final class SettingsLoadSuccess extends SettingsState {
  const SettingsLoadSuccess({required this.sourceRootPath});
  
  /// The file system path to the directory that is supposed to be the root of the gallery's source directory.
  final String sourceRootPath;
  //final ThemeMode themeMode;

  SettingsLoadSuccess copyWith({String? sourceRootPath}) {
    return SettingsLoadSuccess(sourceRootPath: sourceRootPath ?? this.sourceRootPath);
  }
}

final class SettingsLoadFailure extends SettingsState {
  const SettingsLoadFailure({required this.exception});
  final Exception exception;
}
