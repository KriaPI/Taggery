import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:taggery/ui/components/setup_dialog.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: 
      Center(
        child: SetupDialog(
          buttonLabel: "Set root folder",
          buttonCallback: () {
            // TODO: implement logic to persist a folder path, and actually set it.
            FilePicker.getDirectoryPath();
          },
        )
    ));
  }
}
