import 'package:go_router/go_router.dart';
import 'package:taggery/ui/pages/home_page.dart';
import 'package:taggery/ui/pages/results_page.dart';
import 'package:taggery/ui/pages/setup_page.dart';
import 'package:taggery/ui/pages/viewer_page.dart';

final appRoutes = GoRouter(
  routes: [
    GoRoute(path: "/", builder: (context, state) => HomePage()),
    GoRoute(path: "/setup", builder: (context, state) => SetupPage()),
    GoRoute(path: "/results", builder: (context, state) => ResultsPage()),
    GoRoute(path: "/viewer", builder: (context, state) => ViewerPage()),
  ],
);
