import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taggery/providers/configuration_provider.dart';
import 'package:taggery/ui/pages/home/home_page.dart';
import 'package:taggery/ui/pages/setup_page.dart';

final gorouterProvider = FutureProvider((ref) async {
  final configuration = await ref.watch(configurationNotifierProvider.future);

  return GoRouter(
    routes: [
      GoRoute(
        path: "/",
        builder: (context, state) => HomePage(),
        redirect: (context, state) {
          
          return configuration.galleryRootPath != null
            ? null
            : "/setup";
        },
      ),
      GoRoute(path: "/setup", builder: (context, state) => SetupPage()),
    ],
  );
});
