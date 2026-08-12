import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:taggery/data/search_repository.dart';

/// Provides the search suggestions for the search bar's view.
class SearchSuggestionCubit extends Cubit<TaggerySearchState> {
  SearchSuggestionCubit(this._repository) : super(SearchStateEmpty());

  final SearchRepository _repository;

  Future<void> loadSearchSuggestions(String input) async {
    emit(SearchStateLoading());

    final trimmedInput = input.trim();
    final suggestions = _repository.subdirectories.map(
      (directory) => (basename(directory.path), directory),
    );
    final filteredSuggestions = suggestions
        .where((suggestion) => suggestion.$1.startsWith(trimmedInput))
        .toList();

    if (filteredSuggestions.isEmpty) {
      emit(SearchStateEmpty());
    } else {
      emit(SearchStateSuccess(filteredSuggestions));
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

  final List<(String, Directory)> items;

  @override
  List<Object> get props => [items];

  @override
  String toString() => 'SearchStateSuccess { items: ${items.length} }';
}
