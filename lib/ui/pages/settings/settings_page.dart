import 'package:flutter/material.dart';
import 'package:taggery/ui/components/containers.dart';
import 'package:taggery/ui/pages/home/home_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0, right: 32.0),
        child: Row(
          children: [
            const AppPageNavigator(currentIndex: 2),
            Expanded(child: Pane(child: Column())),
          ],
        ),
      ),
    );
  }
}

class SettingsSection {

}