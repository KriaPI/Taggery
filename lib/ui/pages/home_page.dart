import 'package:flutter/material.dart';
import 'package:taggery/ui/components/media_grid.dart';
import 'package:taggery/ui/components/media_viewer.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppHeader(),
          Expanded(
            child: Row(
              children: [
                const AppPageNavigator(),
                Expanded(child: const ContentArea())
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget composed of two child widgets, a grid of photo tiles and a media "viewer", arranged in a row. The state of the two
/// child widgets are dependent on each other and handled by this widget.
class ContentArea extends StatefulWidget {
  const ContentArea({super.key});

  @override
  State<StatefulWidget> createState() => _ContentAreaState();
}

class _ContentAreaState extends State<ContentArea> {
  bool isViewerOpen = false;
  int openedMediaIndex = 0;
  List<int> selectedMediaIndices = [];
  
  void closeViewer() {
    setState(() {
      isViewerOpen = false;
    });
  }

  void openMedia(int index) {
    setState(() {
      openedMediaIndex = index;
      isViewerOpen = true;
    });
  }

  // TODO: do bounds checking.
  void previousMedia() {
    setState(() {
      openedMediaIndex = --openedMediaIndex;  
    });
  }

  void nextMedia() {
    setState(() {
      openedMediaIndex = ++openedMediaIndex;  
    });
  }

  @override
  Widget build(BuildContext context) {
    return isViewerOpen 
      ? Row(
      children: [
        Expanded(child: MediaGrid(selectionCallback: openMedia)),
        Expanded(child: MediaViewer(onClose: closeViewer, onPrevious: previousMedia, onNext: nextMedia)),
      ],
    )
    : MediaGrid(selectionCallback: openMedia);
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: DoNothingAction.new,
            icon: Icon(Icons.menu_rounded),
          ),
          SearchAnchor.bar(
            barHintText: "Search Library",
            barElevation: WidgetStatePropertyAll(0.0),
            suggestionsBuilder: (context, controller) {
              return [
                ListTile(title: Text("Placeholder 1")),
                ListTile(title: Text("Placeholder 2")),
              ];
            },
          ),
          IconButton(
            onPressed: DoNothingAction.new,
            icon: Icon(Icons.check_box_outlined),
          ),
        ],
      ),
    );
  }
}

class AppPageNavigator extends StatelessWidget {
  const AppPageNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
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