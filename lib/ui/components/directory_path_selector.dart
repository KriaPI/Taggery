import 'package:flutter/material.dart';

class DirectoryPathSelector extends StatelessWidget {
  const DirectoryPathSelector({super.key, required this.buttonLabel, required this.buttonCallback});

  final String buttonLabel;
  final VoidCallback buttonCallback;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("No root folder has been set.",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text("The path to a root folder is required to show images and videos in the library. Without this, the program will not work properly.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: 16.0),
        FilledButton.tonalIcon(
          onPressed: buttonCallback,
          label: Text(buttonLabel),
          icon: Icon(Icons.folder_open_rounded),
          iconAlignment: IconAlignment.start,
        ),
      ],
    );
  }
}
