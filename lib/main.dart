import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:taggery/state/repository/gallery_repository.dart';
import 'package:taggery/state/repository/search_repository.dart';
import 'package:taggery/state/repository/settings_repository.dart';
import 'package:taggery/state/gallery.dart';
import 'package:taggery/state/search.dart';
import 'package:taggery/state/settings.dart';
import 'package:taggery/state/tabs.dart';
import 'package:taggery/state/models/settings.dart';
import 'package:taggery/ui/configuration/default_keybindings.dart';
import 'package:taggery/ui/configuration/theme.dart';
import 'package:taggery/ui/pages/main/main_page.dart';
import 'package:taggery/ui/pages/settings/settings_page.dart';
import 'package:taggery/ui/pages/setup_page.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final window = WindowManager.instance.getCurrent()!;

  window.title = "Taggery";
  window.minimumSize = const Size(900, 500).toNative();
  window.center();
  window.maximize();

  final settingsRepository = SettingsRepository();
  final galleryRepository = GalleryRepository();
  final searchRepository = SearchRepository();
  final settingsCubit = SettingsCubit(settingsRepository);

  final routes = GoRouter(
    routes: [
      GoRoute(
        path: "/",
        pageBuilder: (context, state) {
          final fromSetup = state.extra as bool? ?? false;

          if (fromSetup) {
            return MaterialPage(key: state.pageKey, child: const MainPage());
          }

          return NoTransitionPage(key: state.pageKey, child: const MainPage());
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
