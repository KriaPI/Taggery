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
  });

  /// Retrieve the duration of time that has passed since the source started playing.
  Duration passedDuration;

  /// A volume of 0 (muted) to 100.
  double volume;

  VideoTabState copyWith(Duration? passedDuration, double? volume) {
    return VideoTabState(
      content: content,
      passedDuration: passedDuration ?? this.passedDuration,
      volume: volume ?? this.volume,
    );
  }
}

/// Manages the viewer's tabs' state.
class TabCubit extends Cubit<List<TabState>> {
  TabCubit() : super([]);

  /// Open [tabContent]. Replaces the value of the first tab.
  void open(GalleryEntry tabContent) {
    final tab = tabContent.isVideo
        ? VideoTabState(content: tabContent)
        : TabState(content: tabContent);

    if (state.isEmpty) {
      emit([tab]);
    } else {
      state[0] = tab;
      emit(state);
    }
  }

  /// Add a new tab with [tabContent] to the list of tabs.
  void openTab(GalleryEntry tabContent) {
    final tab = tabContent.isVideo
        ? VideoTabState(content: tabContent)
        : TabState(content: tabContent);

    switch (state.length) {
      case 0:
        emit([tab, tab]);
        break;
      case 1:
        emit([...state, tab]);
        break;
      default:
        {
          // We need to make a copy since the state is only compared through shallow equality.
          final copy = [...state];
          copy.insert(1, tab);
          emit(copy);
        }
    }
  }

  /// Assign the tab state at [index] in the list of tabs with [newstate] as its value.
  void saveTabState(int index, TabState newState) {
    final copy = [...state];
    copy[index] = newState;
    emit(copy);
  }

  /// Remove the tab at [index] within the list. Assumes that the index exists.
  void closeTab(int index) {
    emit([...state]..removeAt(index));
  }
}
