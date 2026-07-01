import 'package:go_router/go_router.dart';
import 'package:taggery/ui/pages/home_page.dart';
import 'package:taggery/ui/pages/setup_page.dart';

final appRoutes = GoRouter(
  routes: [
    GoRoute(path: "/home", builder: (context, state) => HomePage()),
    GoRoute(path: "/", builder: (context, state) => SetupPage()),
  ],
);
