import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taggery/models/gallery.dart';

/// Manages the viewer's tabs' state.
class TabCubit extends Cubit<List<GalleryEntry>> {
  TabCubit() : super([]);

  /// Add a new tab with [tabContent] to the list of tabs.
  void openTab(GalleryEntry tabContent) {
    emit([tabContent, ...state]);
  }

  /// Remove the tab at [index] within the list. Assumes that the index exists.
  void closeTab(int index) {
    emit([...state]..removeAt(index));
  }
}
