import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taggery/providers/configuration_provider.dart';
import 'package:taggery/ui/components/text_variants.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: SetupDialog()));
  }
}

/// Widget to manage the state of the application setup dialog.
class SetupDialog extends ConsumerStatefulWidget {
  const SetupDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => SetupDialogState();
}

class SetupDialogState extends ConsumerState<SetupDialog> {
  bool hasFailed = false;

  void requestRootDirectory() {
    FilePicker.getDirectoryPath()
        .then((String? value) {
          if (value != null) {
            setRootDirectory(value);
          }
        })
        .catchError((error) {
          setState(() {
            hasFailed = true;
          });
        });
  }

  void setRootDirectory(String root) {
    ref
        .read(configurationNotifierProvider.notifier)
        .setGalleryRootDirectory(root);
    context.go("/home");
  }

  @override
  Widget build(BuildContext context) {
    return PickRootFolderDialog(
      onPressed: requestRootDirectory,
      messageTitle: "Set a root folder for the gallery",
      messageBody: !hasFailed
          ? "The path to a root folder is required to show images and videos."
          : "The path could not be set.",
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
