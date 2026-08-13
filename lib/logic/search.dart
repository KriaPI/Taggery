import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:taggery/data/search_repository.dart';
import 'package:taggery/data/settings_repository.dart';

/// Provides the search suggestions for the search bar's view.
class SearchSuggestionCubit extends Cubit<TaggerySearchState> {
  SearchSuggestionCubit({
    required this.searchRepository,
    required this.settingsRepository,
  }) : super(SearchStateEmpty()) {
    loadSearchOptions("");
  }

  final SearchRepository searchRepository;
  final SettingsRepository settingsRepository;

  Future<void> loadSearchOptions(String query) async {
    emit(SearchStateLoading());

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
          ? emit(SearchStateEmpty())
          : emit(SearchStateSuccess(transformedOptions));
    } else {
      emit(SearchStateEmpty());
    }
  }
}

sealed class TaggerySearchState extends Equatable {
  const TaggerySearchState();

  @override
  List<Object> get props => [];
}

final class SearchStateEmpty extends TaggerySearchState {}

final class SearchStateLoading extends TaggerySearchState {}

final class SearchStateSuccess extends TaggerySearchState {
  const SearchStateSuccess(this.items);

  final Iterable<(String, Directory)> items;

  @override
  List<Object> get props => [items];

  @override
  String toString() => 'SearchStateSuccess { items: ${items.length} }';
}
