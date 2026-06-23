import 'package:flutter/material.dart';
import 'package:taggery/ui/components/containers.dart';
import 'package:taggery/ui/components/media_tile.dart';

// TODO: add an option to preferences to select from a range of sizes instead (or a number of cells that should be displayed at most when the app is in fullscreen and does not have the viewer open).
const int arbitraryMinimumCellSize = 300;

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
                const Expanded(child: MediaGrid()),
                const Expanded(child: MediaViewer()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SearchAnchor.bar(
          barElevation: WidgetStatePropertyAll(0.0),
          suggestionsBuilder: (context, controller) {
            return [
              ListTile(title: Text("Placeholder 1")),
              ListTile(title: Text("Placeholder 2")),
            ];
          },
        ),
      ],
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
        NavigationRailDestination(icon: Icon(Icons.photo_library_rounded), label: Text("Library")),
        NavigationRailDestination(icon: Icon(Icons.sell_rounded), label: Text("Tags")),
        NavigationRailDestination(icon: Icon(Icons.settings_rounded), label: Text("Settings"))
      ], 
    );
  }
} 

class MediaGrid extends StatelessWidget {
  const MediaGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Pane(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GridView.count(
              crossAxisCount: (constraints.maxWidth / arbitraryMinimumCellSize)
                  .round(),
              children: List.generate(15, (index) {
                return MediaTile.thumbnailUnavailable();
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class MediaViewer extends StatelessWidget {
  const MediaViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Pane(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BackButton(),
                IconButton(
                  onPressed: DoNothingAction.new,
                  icon: Icon(Icons.more_vert_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              alignment: AlignmentGeometry.center,
              children: [
                MediaTile.thumbnailUnavailable(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filledTonal(
                        onPressed: DoNothingAction.new,
                        icon: Icon(Icons.chevron_left_rounded),
                      ),
                      IconButton.filledTonal(
                        onPressed: DoNothingAction.new,
                        icon: Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
