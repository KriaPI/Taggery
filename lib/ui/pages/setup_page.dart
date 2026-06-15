import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:taggery/ui/components/directory_path_selector.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: 
      Center(
        child: DirectoryPathSelector(
          buttonLabel: "Set root folder",
          buttonCallback: () {
            // TODO: implement logic to persist a folder path, and actually set it.
            FilePicker.getDirectoryPath();
          },
        )
    ));
  }
}
