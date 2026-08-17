import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:taggery/data/gallery_repository.dart';
import 'package:taggery/data/search_repository.dart';
import 'package:taggery/data/settings_repository.dart';
import 'package:taggery/logic/gallery.dart';
import 'package:taggery/logic/search.dart';
import 'package:taggery/logic/settings.dart';
import 'package:taggery/logic/tabs.dart';
import 'package:taggery/models/settings.dart';
import 'package:taggery/ui/configuration/default_keybindings.dart';
import 'package:taggery/ui/configuration/theme.dart';
import 'package:taggery/ui/pages/home/home_page.dart';
import 'package:taggery/ui/pages/settings/settings_page.dart';
import 'package:taggery/ui/pages/setup_page.dart';

void main() {
  final settingsRepository = SettingsRepository();
  final galleryRepository = GalleryRepository();
  final searchRepository = SearchRepository();
  final settingsCubit = SettingsCubit(settingsRepository);
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final routes = GoRouter(
    routes: [
      GoRoute(
        path: "/",
        pageBuilder: (context, state) {
          final fromSetup = state.extra as bool? ?? false;

          if (fromSetup) {
            return MaterialPage(key: state.pageKey, child: const HomePage());
          }

          return NoTransitionPage(
            key: state.pageKey,
            child: const HomePage(),
          );
        },
        redirect: (context, state) {
          final settingsState = context.read<SettingsCubit>().state;
          return settingsState is SettingsNeedsSetup ? "/setup" : null;
        },
      ),
      GoRoute(
        path: "/settings",
        pageBuilder: (context, state) =>
            NoTransitionPage(child: SettingsPage()),
      ),
      GoRoute(path: "/setup", builder: (context, state) => SetupPage()),
    ],
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: settingsCubit),
        BlocProvider(create: (context) => GalleryCubit(galleryRepository)),
        BlocProvider(
          create: (context) => SearchSuggestionCubit(
            searchRepository: searchRepository,
            settingsRepository: settingsRepository,
          ),
        ),
        BlocProvider(create: (context) => TabCubit()),
      ],
      child: MainApp(routes: routes),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.routes});
  final GoRouter routes;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      shortcuts: keybindings,
      routerConfig: routes,
      darkTheme: taggeryDarkTheme,
      theme: taggeryLightTheme,
      themeMode: ThemeMode.light,
    );
  }
}
