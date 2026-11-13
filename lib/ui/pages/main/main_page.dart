import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:taggery/ui/components/misc.dart';
import 'package:taggery/ui/pages/main/content_area.dart';
import 'package:taggery/ui/pages/main/header.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ContentAreaViewMode _viewMode = .gridExpanded;
  final searchController = SearchController();
  late final FocusNode _viewerFocus = FocusNode(debugLabel: "Image Viewer");
  late final FocusNode _searchFocus = FocusNode(debugLabel: "Search bar");

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(_restoreFocusToImageViewer);
  }

  @override
  void dispose() {
    _viewerFocus.dispose();
    _searchFocus.dispose();
    searchController.dispose();
    super.dispose();
  }

  // TODO: figure out why this doesn't work.
  void _restoreFocusToImageViewer() {
    _searchFocus.unfocus();
    _viewerFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          top: _viewMode == .viewerExpanded ? 0 : DefaultSpacing.large,
        ),
        child: Column(
          spacing: DefaultSpacing.large,
          children: [
            if (_viewMode != .viewerExpanded)
              Padding(
                padding: const .symmetric(
                  horizontal: DefaultSpacing.extraLarge,
                ),
                child: PageHeader(
                  searchController: searchController,
                  onSearchClosed: _restoreFocusToImageViewer,
                  searchFocus: _searchFocus,
                ),
              ),
            Expanded(
              child: ContentArea(
                viewerFocus: _viewerFocus,
                viewMode: _viewMode,
                changeViewMode: (newViewMode) {
                  setState(() {
                    _viewMode = newViewMode;
                  });
                },
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
  const AppPageNavigator({super.key, required this.currentIndex});

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
