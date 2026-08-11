import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taggery/model/gallery_entry.dart';

class ViewerTabsNotifier extends Notifier<List<GalleryEntry>> {
  @override
  List<GalleryEntry> build() {
    return [];
  }

  /// Add a new tab with [tabContent] to the list of tabs.
  void openTab(GalleryEntry tabContent) {
    state = [tabContent, ...state];
  }

  /// Remove the tab at [index] within the list. Assumes that the index exists.
  void closeTab(int index) {
    state = [... state]..removeAt(index);
  }
}

final viewerTabsNotifierProvider = NotifierProvider(() {
  return ViewerTabsNotifier();
});
