import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taggery/logic/settings.dart';
import 'package:taggery/ui/components/text_variants.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: SetupDialog()));
  }
}

/// The initial setup dialog shown to the user.
class SetupDialog extends StatelessWidget {
  const SetupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PickRootFolderDialog(
      onPressed: () {
        final newRootDirectory = FilePicker.getDirectoryPath();

        newRootDirectory
            .then((value) {
              if (value != null) {
                if (context.mounted) {
                  context
                      .read<SettingsCubit>()
                      .updateSourceRootPath(value)
                      .then((_) {
                        if (context.mounted) {
                          context.go("/");
                        }
                      });
                } else {
                  debugPrint("Context was not mounted.");
                }
              } else {
                // TODO: show an message saying that the action (picking a directory) was aborted.
              }
            })
            .catchError((e) {
              debugPrint("Caught an error.");
              // TODO: show an error message.
            });
      },
      messageTitle: "Set a root folder for the gallery",
      messageBody:
          "The path to a root folder is required to show images and videos.",
    );
  }
}

/// Dialog asking the user to set up the root path to a media gallery.
///
/// [onPressed] should be a callback to open the native file explorer to allow the user to pick a folder.
class PickRootFolderDialog extends StatelessWidget {
  const PickRootFolderDialog({
    super.key,
    required this.onPressed,
    required this.messageTitle,
    required this.messageBody,
  });
  final VoidCallback onPressed;
  final String messageTitle;
  final String messageBody;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TitleText(messageTitle),
        BodyText(messageBody),
        SizedBox(height: 16.0),
        FilledButton.icon(
          onPressed: onPressed,
          label: Text("Set root folder"),
          icon: Icon(Icons.folder_open_rounded),
          iconAlignment: IconAlignment.start,
        ),
      ],
    );
  }
}
