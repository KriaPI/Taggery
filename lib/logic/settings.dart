import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taggery/data/settings_repository.dart';
import 'package:taggery/models/settings.dart';

/// Manages the state of the user's settings
/// 
/// This includes things such as loading settings and updating settings.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository): super(const SettingsInitial()) {
    loadSettings();
  }

  final SettingsRepository _repository;

  Future<void> loadSettings() async {
    emit (const SettingsLoadingInProgress());

    try {
      final path = await _repository.sourceRootDirectory; 
      if (path != null) {
        emit (SettingsLoadSuccess(sourceRootPath: path));
      } else {
        emit (const SettingsNeedsSetup());
      }
    } on Exception catch (e) {
      emit(SettingsLoadFailure(exception: e));
    }
  }

  Future<void> updateSourceRootPath(String path) async {
    if (state is SettingsLoadSuccess || state is SettingsNeedsSetup) {
      await _repository.setSourceRootDirectory(path);
      emit (SettingsLoadSuccess(sourceRootPath: path));
    } 
  }
}