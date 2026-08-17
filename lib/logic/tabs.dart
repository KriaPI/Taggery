import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taggery/models/gallery.dart';

/// Stores the state of a tab and its content.
class TabState {
  TabState({required this.content});
  final GalleryEntry content;

  File get source {
    return content.source;
  }
}

class VideoTabState extends TabState {
  VideoTabState({
    required super.content,
    this.passedDuration = const Duration(seconds: 0),
    this.volume = 0.0,
    this.loop = false,
  });

  /// Retrieve the duration of time that has passed since the source started playing.
  Duration passedDuration;

  /// A volume of 0 (muted) to 100.
  double volume;
  bool loop;
}

/// Manages the viewer's tabs' state.
class TabCubit extends Cubit<List<TabState>> {
  TabCubit() : super([]);

  /// Add a new tab with [tabContent] to the list of tabs.
  void openTab(GalleryEntry tabContent) {
    if (tabContent.isVideo) {
      emit([VideoTabState(content: tabContent), ...state]);
    } else {
      emit([TabState(content: tabContent), ...state]);
    }
  }

  /// Remove the tab at [index] within the list. Assumes that the index exists.
  void closeTab(int index) {
    emit([...state]..removeAt(index));
  }
}
