import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taggery/ui/components/buttons.dart';

/// This widget allows the user to view an image.
/// 
/// It additionally allows the user to show the previous and next image, view information about the image,
/// and show it in black-and-white.
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
  bool showInBlackAndWhite = false;

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
              // TODO: make it zoomable and pannable
              ClipRRect(
                borderRadius: BorderRadiusGeometry.all(.circular(8.0)),
                clipBehavior: .antiAlias,
                child: Image.file(widget.image),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                      tooltip: "View in monochrome",
                      onPressed: () {},
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
  bool isPinned = true;
  bool isShown = true;

  @override
  Widget build(BuildContext context) {
    final hideButton = SquareTonalIconButton(
      tooltip: isPinned ? "Unpin" : "Pin",
      onPressed: () {
        setState(() {
          isPinned = !isPinned;
        });
      },
      icon: isPinned
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

    return isPinned
        ? controls
        : MouseRegion(
            onEnter: (event) {
              setState(() {
                isShown = true;
              });
            },
            onExit: (event) {
              setState(() {
                isShown = false;
              });
            },
            child: ClipRect(
              child: AnimatedSlide(
                offset: isShown ? Offset.zero : const Offset(0, 1.0),
                curve: Curves.easeInOut,
                duration: Durations.short3,
                child: AnimatedOpacity(
                  duration: Durations.short3,
                  curve: Curves.easeInOut,
                  opacity: isShown ? 1.0 : 0.0,
                  child: controls,
                ),
              ),
            ),
          );
  }
}