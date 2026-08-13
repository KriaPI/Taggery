import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taggery/logic/gallery.dart';
import 'package:taggery/logic/search.dart';
import 'package:taggery/ui/pages/home/content_area.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0, right: 32.0),
        child: Row(
          children: [
            const AppPageNavigator(),
            Expanded(
              child: Column(
                spacing: 8.0,
                children: [
                  const SearchBar(),
                  Expanded(child: ContentArea()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Navigation rail
class AppPageNavigator extends StatelessWidget {
  const AppPageNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      leading: FloatingActionButton(
        elevation: 0.0,
        onPressed: () {},
        tooltip: "Tag photos",
        child: Icon(Icons.edit_rounded),
      ),
      labelType: .all,
      selectedIndex: 0,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.photo_library_rounded),
          label: Text("Library"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.label_rounded),
          label: Text("Tags"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_rounded),
          label: Text("Settings"),
        ),
      ],
    );
  }
}

// TODO: hide searchbar when image viewer is in fullscreen. Hide viewer when 
// a new search is made.
// TODO: make the focus not stay on the search bar.
// The searchbar currently hogs the focus so that if the searchbar is opened once, the 
// viewer's shortcuts do not work (because the viewer does not have focus).
class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final _searchController = SearchController();

  @override
  void initState() {
    super.initState();

    _searchController.addListener(refreshResults);
  }

  @override
  void dispose() {
    _searchController.removeListener(refreshResults);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      searchController: _searchController,
      shrinkWrap: true,
      barHintText: "Search in gallery",
      barElevation: WidgetStatePropertyAll(0.0),
      barOverlayColor: .all(Colors.transparent),
      dividerColor: Colors.transparent,
      viewLeading: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          // Closes the view and submits the current text input
          _searchController.closeView(_searchController.text);
        },
      ),
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
