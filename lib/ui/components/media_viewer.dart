import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taggery/ui/components/containers.dart';
import 'package:taggery/ui/components/more_button.dart';
import 'package:taggery/ui/components/text_variants.dart';

/// The media viewer for the home page. This is not a reusuable component.
class MediaViewer extends ConsumerWidget {
  const MediaViewer({
    super.key,
    required this.media,
    required this.onClose,
    required this.onExpandOrMinimize,
    required this.onPrevious,
    required this.onNext,
    required this.isExpanded,
  });
  final File? media;
  final bool isExpanded;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final VoidCallback onExpandOrMinimize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Pane(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: Icon(Icons.close_rounded), onPressed: onClose, tooltip: "Close"),
                Row(
                  children: [
                    MoreButton(
                      options: [
                        MenuOption(
                          label: "Details",
                          optionCallback: () => print("Details!"),
                        ),
                        MenuOption(
                          label: "View in Black and White",
                          optionCallback: () => print("Monochromatic!"),
                          shortcut: SingleActivator(
                            LogicalKeyboardKey.keyA,
                            control: true,
                          ),
                        ),
                      ],
                    ),
                    isExpanded
                        ? IconButton(
                            onPressed: onExpandOrMinimize,
                            icon: Icon(Icons.close_fullscreen_rounded),
                            tooltip: "Minimize",
                          )
                        : IconButton(
                            onPressed: onExpandOrMinimize,
                            icon: Icon(Icons.open_in_full_rounded),
                            tooltip: "Maximize",
                          ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              alignment: AlignmentGeometry.center,
              children: [
                // TODO: make it zoomable and pannable
                media != null 
                  ? Image.file(media!)
                  : BodyText("The Image could not be loaded."),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filledTonal(
                        onPressed: onPrevious,
                        icon: Icon(Icons.chevron_left_rounded),
                      ),
                      IconButton.filledTonal(
                        onPressed: onNext,
                        icon: Icon(Icons.chevron_right_rounded),
                      ),
                    ],
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
