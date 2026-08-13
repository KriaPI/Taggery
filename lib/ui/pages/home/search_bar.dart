import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taggery/logic/gallery.dart';
import 'package:taggery/logic/search.dart';


class TaggerySearchBar extends StatefulWidget {
  const TaggerySearchBar({super.key});

  @override
  State<TaggerySearchBar> createState() => _TaggerySearchBarState();
}

class _TaggerySearchBarState extends State<TaggerySearchBar> {
  final _searchController = SearchController();
  final FocusNode _focusNode = FocusNode(debugLabel: "Search bar focus");

  @override
  void initState() {
    super.initState();

    _searchController.addListener(refreshResults);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.removeListener(refreshResults);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      searchController: _searchController,
      shrinkWrap: true,
      builder: (context, controller) {
        return SearchBar(
          autoFocus: false,
          focusNode: _focusNode,
          controller: controller,
          hintText: "Search in gallery",
          elevation: WidgetStatePropertyAll(0.0),
          overlayColor: .all(Colors.transparent),
          leading: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Closes the view and submits the current text input
              _searchController.closeView(_searchController.text);
            },
          ),
          onTap: () {
            controller.openView();
          },
          onTapOutside: (event) {
            _focusNode.unfocus();
          },
          onChanged: (value) {
            context.read<SearchSuggestionCubit>().loadSearchOptions(value);
          },
          onSubmitted: (value) {
            _searchController.closeView(value);
            final result = context
                .read<SearchSuggestionCubit>()
                .state
                .items
                .firstWhere((option) => option.$1 == value);
            showResults(result.$2);
          },
        );
      },
      dividerColor: Colors.transparent,
      viewLeading: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          // Closes the view and submits the current text input
          _searchController.closeView(_searchController.text);
        },
      ),
      suggestionsBuilder: (context, controller) {
        return [
          BlocBuilder<SearchSuggestionCubit, SearchState>(
            builder: (context, state) {
              if (state.status != SearchStatus.initial) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: state.items.map((suggestion) {
                    final (name, directory) = suggestion;
                    return ListTile(
                      onTap: () {
                        controller.closeView(name);
                        showResults(directory);
                      },
                      title: Text(name),
                      subtitle: Text(directory.path),
                    );
                  }).toList(),
                );
              }

              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Empty"),
              );
            },
          ),
        ];
      },
    );
  }

  void showResults(Directory toShow) {
    context.read<GalleryCubit>().loadDirectory(toShow.path);
  }

  void refreshResults() {
    if (_searchController.isOpen) {
      context.read<SearchSuggestionCubit>().loadSearchOptions(
        _searchController.text,
      );
    }
  }
}
