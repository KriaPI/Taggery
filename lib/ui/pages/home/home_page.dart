import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
            const AppPageNavigator(currentIndex: 0),
            Expanded(
              child: const ContentArea(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Navigation rail
class AppPageNavigator extends StatelessWidget {
  const AppPageNavigator({
    super.key, 
    required this.currentIndex,
  });

  final int currentIndex;

  void _onItemTapped(int index, BuildContext context) {
    // Map each index to your go_router paths
    switch (index) {
      case 0:
        context.go("/"); // Replace with your actual route name
        break;
      case 1:
        throw UnimplementedError();
        //break;
      case 2:
        context.go('/settings');
        break;
    }
  }

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
      selectedIndex: currentIndex,
      onDestinationSelected: (value) => _onItemTapped(value, context),
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

