import 'package:flutter/material.dart';
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
