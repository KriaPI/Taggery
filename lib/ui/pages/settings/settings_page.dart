import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taggery/state/settings.dart';
import 'package:taggery/ui/components/containers.dart';
import 'package:taggery/ui/components/text.dart';
import 'package:taggery/ui/pages/main/main_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0, right: 32.0),
        child: Row(
          mainAxisAlignment: .center,
          children: [
            const AppPageNavigator(currentIndex: 2),
            Flexible(child: Pane(child: GeneralSection())),
          ],
        ),
      ),
    );
  }
}

// TODO: make it look pretty and actually do stuff.

class GeneralSection extends StatelessWidget {
  const GeneralSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          TitleText("General", size: .large),
          Flexible(
            child: ListView(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.all(0),
                  title: TitleText("Source directory", size: .small),
                  subtitle: BodyText("fsfnsl"),
                  trailing: OutlinedButton(
                    onPressed: () {
                      final newRootDirectory = FilePicker.getDirectoryPath();

                      newRootDirectory
                          .then((value) {
                            if (value != null) {
                              if (context.mounted) {
                                context
                                    .read<SettingsCubit>()
                                    .updateSourceRootPath(value);
                              } else {
                                debugPrint("Context was not mounted.");
                              }
                            }
                          })
                          .catchError((e) {
                            debugPrint("Caught an error.");
                          });
                    },
                    child: Text("Change"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
