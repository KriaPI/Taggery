import 'package:go_router/go_router.dart';
import 'package:taggery/ui/pages/home_page.dart';
import 'package:taggery/ui/pages/results_page.dart';
import 'package:taggery/ui/pages/setup_page.dart';
import 'package:taggery/ui/pages/viewer_page.dart';

final appRoutes = GoRouter(
  routes: [
    GoRoute(path: "/", builder: (context, state) => SetupPage()),
    GoRoute(path: "/home", builder: (context, state) => HomePage()),
    GoRoute(path: "/home", builder: (context, state) => ResultsPage()),
    GoRoute(path: "/home", builder: (context, state) => ViewerPage()),
  ],
);
