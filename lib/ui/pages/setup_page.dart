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
    return Scaffold(body: 
      Center(
        child: SetupDialog(
          buttonLabel: "Set root folder",
          buttonCallback: () {
            FilePicker.getDirectoryPath();
          },
        )
    ));
  }
}

// TODO: provide documentation

class SetupDialog extends ConsumerStatefulWidget {
  const SetupDialog({
    super.key,
    required this.buttonLabel,
    required this.buttonCallback,
  });

  final String buttonLabel;
  final VoidCallback buttonCallback;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => SetupDialogState();
}

class SetupDialogState extends ConsumerState<SetupDialog> {
  String _rootpath = "";

  void requestRootDirectory() {
    FilePicker.getDirectoryPath()
        .then((String? value) {
          if (value != null) {
            setState(() {
              _rootpath = value;
            });
          }
        })
        .catchError((error) {
          // TODO: do proper error handling if applicable.
        });
  }

  void setRootDirectory() {
    ref.read(configurationNotifierProvider.notifier).setGalleryRootDirectory(_rootpath);
    context.go("/home");
  }

  @override
  Widget build(BuildContext context) {
    

    if (_rootpath == "") {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TitleText(
            "No root folder has been set.",
          ),
          BodyText(
            "The path to a root folder is required to show images and videos.",
          ),
          SizedBox(height: 16.0),
          FilledButton.tonalIcon(
            onPressed: requestRootDirectory,
            label: Text(widget.buttonLabel),
            icon: Icon(Icons.folder_open_rounded),
            iconAlignment: IconAlignment.start,
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TitleText("Root set!"),
          BodyText(
            "The root has been set to $_rootpath. Do you want to accept this as the root folder?",
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8.0,
            children: [
              FilledButton.tonalIcon(
                onPressed: requestRootDirectory,
                label: Text("Change"),
                icon: Icon(Icons.edit_rounded),
                iconAlignment: IconAlignment.start,
              ),
              FilledButton.tonalIcon(
                onPressed: setRootDirectory,
                icon: Icon(Icons.check_rounded),
                label: Text("Accept"),
              ),
            ],
          ),
        ],
      );
    }
  }
}
