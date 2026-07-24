import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taggery/ui/components/text_variants.dart';
import 'package:taggery/ui/configuration/default_keybindings.dart';
import 'package:taggery/providers/routes.dart';
import 'package:taggery/ui/configuration/theme.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final router = ref.watch(gorouterProvider);

    if (router.isLoading) {
      return MaterialApp();
    } else if (router.hasError) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: TitleText("Could not load the application.")),
        ),
      );
    }

    return MaterialApp.router(
      shortcuts: keybindings,
      routerConfig: router.requireValue,
      darkTheme: taggeryDarkTheme,
      theme: taggeryLightTheme,
      themeMode: ThemeMode.light,
    );
  }
}
