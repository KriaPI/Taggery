import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taggery/ui/components/buttons.dart';

const ColorFilter grayscaleFilter = ColorFilter.matrix(<double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);

/// This widget allows the user to view an image.
///
/// It additionally allows the user to show the previous and next image, view information about the image,
/// and show it in black-and-white (monochrome).
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
  bool _isMonochrome = false;

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
          ],
        ),
        Expanded(
          child: Stack(
            alignment: .bottomCenter,
            children: [
              // TODO: only change the mouse cursor when the image is zoomed into, otherwise use the default mouse cursor.
              MouseRegion(
                cursor: SystemMouseCursors.allScroll,
                child: ClipRRect(
                  borderRadius: .circular(8.0),
                  child: InteractiveViewer(
                    clipBehavior: Clip.antiAlias,
                    minScale: 1.0,
                    maxScale: 10.0,
                    child: SizedBox.expand(
                      child: _isMonochrome
                          ? ColorFiltered(
                              colorFilter: grayscaleFilter,
                              child: Image.file(widget.image, fit: .contain),
                            )
                          : Image.file(widget.image, fit: .contain),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                // TODO: figure out how to keep the state so that it is not unpinned when the widget is rebuilt. 
                child: PinnableSlidingContainer(
                  children: [
                    SquareTonalIconButton(
                      tooltip: "previous",
                      onPressed: widget.onPrevious,
                      icon: Icon(Icons.chevron_left_rounded),
                    ),
                    SquareTonalIconButton(
                      tooltip: "Details",
                      icon: Icon(Icons.info_outline_rounded),
                      onPressed: () {},
                    ),
                    SquareTonalIconButton(
                      tooltip: _isMonochrome
                          ? "View in color"
                          : "View in monochrome",
                      onPressed: () {
                        _isMonochrome = !_isMonochrome;
                      },
                      icon: Icon(Icons.filter_b_and_w_rounded),
                    ),
                    SquareTonalIconButton(
                      tooltip: "next",
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

/// A container arranging its children in a row that can be automatically hidden.
///
/// This widget has a button that allows the container to be pinned (default) or unpinned.
/// If the widget is unpinned, then it will slide down and out of view when the mouse is
/// not in its region.
///
/// [children] are arranged to the sides of the pin button.
class PinnableSlidingContainer extends StatefulWidget {
  const PinnableSlidingContainer({super.key, required this.children});
  final List<Widget> children;

  @override
  State<StatefulWidget> createState() => PinnableSlidingContainerState();
}

class PinnableSlidingContainerState extends State<PinnableSlidingContainer> {
  bool _isPinned = true;
  bool _isShown = true;

  @override
  Widget build(BuildContext context) {
    final hideButton = SquareTonalIconButton(
      tooltip: _isPinned ? "Unpin" : "Pin",
      onPressed: () {
        setState(() {
          _isPinned = !_isPinned;
        });
      },
      icon: _isPinned
          ? Icon(Icons.arrow_drop_down_rounded)
          : Icon(Icons.arrow_drop_up_rounded),
    );

    final int middle = widget.children.length ~/ 2;

    final buttons = [
      ...widget.children.sublist(0, middle),
      hideButton,
      ...widget.children.sublist(middle),
    ];

    final controls = Row(
      mainAxisAlignment: .center,
      spacing: 4.0,
      children: buttons,
    );

    return _isPinned
        ? controls
        : MouseRegion(
            onEnter: (event) {
              setState(() {
                _isShown = true;
              });
            },
            onExit: (event) {
              setState(() {
                _isShown = false;
              });
            },
            child: ClipRect(
              child: AnimatedSlide(
                offset: _isShown ? Offset.zero : const Offset(0, 1.0),
                curve: Curves.easeInOut,
                duration: Durations.short3,
                child: AnimatedOpacity(
                  duration: Durations.short3,
                  curve: Curves.easeInOut,
                  opacity: _isShown ? 1.0 : 0.0,
                  child: controls,
                ),
              ),
            ),
          );
  }
}
