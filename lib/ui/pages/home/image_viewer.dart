import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taggery/ui/components/more_button.dart';

class ImageViewer extends ConsumerStatefulWidget {
  const ImageViewer({
    super.key,
    required this.image,
    required this.onPrevious,
    required this.onNext,
    required this.onClose,
    required this.onExpandOrMinimize,
    required this.isExpanded,
  });
  final File image;
  final bool isExpanded;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final VoidCallback onExpandOrMinimize;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ImageViewerState();
}

class ImageViewerState extends ConsumerState<ImageViewer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.close_rounded),
              onPressed: widget.onClose,
              tooltip: "Close",
            ),
            Row(
              children: [
                widget.isExpanded
                    ? IconButton(
                        onPressed: widget.onExpandOrMinimize,
                        icon: Icon(Icons.close_fullscreen_rounded),
                        tooltip: "Minimize",
                      )
                    : IconButton(
                        onPressed: widget.onExpandOrMinimize,
                        icon: Icon(Icons.open_in_full_rounded),
                        tooltip: "Maximize",
                      ),
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
              ],
            ),
          ],
        ),
        Expanded(
          child: Stack(
            alignment: AlignmentGeometry.center,
            children: [
              // TODO: make it zoomable and pannable
              ClipRRect(
                borderRadius: BorderRadiusGeometry.all(.circular(8.0)),
                clipBehavior: .antiAlias,
                child: Image.file(widget.image),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton.filledTonal(
                      onPressed: widget.onPrevious,
                      icon: Icon(Icons.chevron_left_rounded),
                    ),
                    IconButton.filledTonal(
                      onPressed: widget.onNext,
                      icon: Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
