import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taggery/providers/gallery_provider.dart';
import 'package:taggery/ui/pages/home/content_filters.dart';
import 'package:taggery/ui/pages/home/media_grid.dart';
import 'package:taggery/ui/pages/home/image_viewer.dart';

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

enum ContentAreaViewMode { gridExpanded, splitView, viewerExpanded }

/// A widget composed of two child widgets, a grid of photo tiles and a media "viewer", arranged in a row. The state of the two
/// child widgets are dependent on each other and handled by this widget.
class ContentArea extends ConsumerStatefulWidget {
  const ContentArea({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContentAreaState();
}

class _ContentAreaState extends ConsumerState<ContentArea> {
  ContentAreaViewMode _viewMode = .gridExpanded;
  int _openedMediaIndex = 0;

  @override
  Widget build(BuildContext context) {
    final gallery = ref.watch(galleryProvider);

    final viewer = Container(
      decoration: BoxDecoration(
        borderRadius: .circular(8.0),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      padding: EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0.0),
      child: ImageViewer(
        media: gallery.when(
          data: (data) =>
              data.isNotEmpty ? data[_openedMediaIndex].source : null,
          error: (error, stackTrace) => null,
          loading: () => null,
        ),
        isExpanded: _viewMode == .viewerExpanded,
        onClose: closeViewer,
        onPrevious: previousMedia,
        onNext: nextMedia,
        onExpandOrMinimize: toggleExpandedView,
      ),
    );

    final gridWithFilters = Container(
      decoration: BoxDecoration(
        borderRadius: .circular(8.0),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      padding: EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0.0),
      child: Column(
        spacing: 48.0,
        children: [
          const ContentFilters(),
          Expanded(child: MediaGrid(selectionCallback: openMedia)),
        ],
      ),
    );

    return switch (_viewMode) {
      .gridExpanded => gridWithFilters,
      .splitView => Row(
        spacing: 8.0,
        children: [
          Expanded(child: gridWithFilters),
          Expanded(child: viewer),
        ],
      ),
      .viewerExpanded => viewer,
    };
  }

  void closeViewer() {
    setState(() {
      _viewMode = .gridExpanded;
    });
  }

  void toggleExpandedView() {
    if (_viewMode == .splitView) {
      setState(() {
        _viewMode = .viewerExpanded;
      });
    } else if (_viewMode == .viewerExpanded) {
      setState(() {
        _viewMode = .splitView;
      });
    } else {
      // This should never happen!
      assert(false);
    }
  }

  void openMedia(int index) {
    setState(() {
      _openedMediaIndex = index;
      _viewMode = .splitView;
    });
  }

  // TODO: do bounds checking.
  void previousMedia() {
    setState(() {
      _openedMediaIndex = --_openedMediaIndex;
    });
  }

  void nextMedia() {
    setState(() {
      _openedMediaIndex = ++_openedMediaIndex;
    });
  }
}

/// The header containing the gallery searchbar.
class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      barHintText: "Search in gallery",
      barElevation: WidgetStatePropertyAll(0.0),
      suggestionsBuilder: (context, controller) {
        return [
          ListTile(title: Text("Placeholder 1")),
          ListTile(title: Text("Placeholder 2")),
        ];
      },
    );
  }
}
