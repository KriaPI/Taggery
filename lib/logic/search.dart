import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:taggery/data/search_repository.dart';
import 'package:taggery/data/settings_repository.dart';

/// Provides the search suggestions for the search bar's view.
class SearchSuggestionCubit extends Cubit<SearchState> {
  SearchSuggestionCubit({
    required this.searchRepository,
    required this.settingsRepository,
  }) : super(SearchState(status: .initial)) {
    loadSearchOptions("");
  }

  final SearchRepository searchRepository;
  final SettingsRepository settingsRepository;
  
  Future<void> loadSearchOptions(String query) async {
    emit(state.copyWith(status: SearchStatus.loading));

    final sourceRootPath = await settingsRepository.sourceRootDirectory;

    if (sourceRootPath != null) {
      final options = await searchRepository.getRootSubDirectories(
        sourceRootPath,
      );
      var transformedOptions = options.map(
        (directory) => (basename(directory.path), directory),
      );

      transformedOptions = query == ""
          ? transformedOptions
          : transformedOptions.where(
              (suggestion) => suggestion.$1.startsWith(query.trim()),
            );

      transformedOptions.isEmpty
          ? emit(SearchState(status: SearchStatus.empty, items: []))
          : emit(state.copyWith(status: SearchStatus.loading, items: transformedOptions));
    } else {
      emit(state.copyWith(status: SearchStatus.empty));
    }
  }
}

enum SearchStatus { initial, loading, success, empty }

class SearchState {
  final SearchStatus status;
  final Iterable<(String, Directory)> items;

  SearchState({required this.status, this.items = const []});

  SearchState copyWith({
    SearchStatus? status,
    Iterable<(String, Directory)>? items,
  }) {
    return SearchState(
      status: status ?? this.status,
      items: items ?? this.items,
    );
  }
}
