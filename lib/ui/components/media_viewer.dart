import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taggery/ui/components/containers.dart';
import 'package:taggery/ui/components/more_button.dart';

/// The media viewer for the home page. This is not a reusuable component.
class MediaViewer extends StatelessWidget {
  const MediaViewer({
    super.key,
    required this.onClose,
    required this.onExpandOrMinimize,
    required this.onPrevious,
    required this.onNext,
    required this.isExpanded,
  });
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final VoidCallback onExpandOrMinimize;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return Pane(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BackButton(onPressed: onClose),
                Row(
                  children: [
                    MoreButton(
                      options: [
                        MenuOption(
                          label: "Show Detailed Information",
                          optionCallback: () => print("Monochromatic!"),
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
                            tooltip: "Minimize Viewer",
                          )
                        : IconButton(
                            onPressed: onExpandOrMinimize,
                            icon: Icon(Icons.open_in_full_rounded),
                            tooltip: "Maximize Viewer",
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
                // TODO: replace with actual image
                Icon(Icons.image),
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
