import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taggery/ui/components/containers.dart';
import 'package:taggery/ui/components/more_menu.dart';

// The options list shown to the user when they press the more actions button (icon button with three vertical dots).
final List<MenuOption> moreMenuOptions = [
  MenuOption(
    label: "View Monochromatic",
    leadingIcon: Icon(Icons.filter_b_and_w_rounded),
    optionCallback: () => print("Monochromatic!"),
    shortcut: SingleActivator(LogicalKeyboardKey.keyB, control: true),
  ),
  MenuOption(
    label: "View Fullscreen",
    leadingIcon: Icon(Icons.fullscreen),
    optionCallback: () => print("Yep, it's in fullscreen."),
    shortcut: SingleActivator(LogicalKeyboardKey.f11),
  ),
];

/// The media viewer for the home page. This is not a reusuable component.
class MediaViewer extends StatelessWidget {
  const MediaViewer({
    super.key,
    required this.onClose,
    required this.onPrevious,
    required this.onNext,
  });
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onClose;

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
                MoreMenu(options: moreMenuOptions),
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
