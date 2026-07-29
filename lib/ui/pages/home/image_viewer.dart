import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taggery/ui/components/buttons.dart';

// TODO: add keyboard shortcuts.

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
  bool _pinControls = true;

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
              ImageArea(source: widget.image, isMonochrome: _isMonochrome),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PinnableSlidingContainer(
                  isPinned: _pinControls,
                  onTogglePin: () {
                    setState(() {
                      _pinControls = !_pinControls;
                    });
                  },
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
                    TonalToggleIconButton(
                      selectedTooltip: "View in color",
                      tooltip: "View in monochrome",
                      isSelected: _isMonochrome,
                      onPressed: () {
                        setState(() {
                          _isMonochrome = !_isMonochrome;
                        });
                      },
                      icon: Icon(Icons.filter_b_and_w_outlined),
                      selectedIcon: Icon(Icons.filter_b_and_w)
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
/// [isPinned] decides whether or not this widget should be pinned. This state should be stored in an attribute
/// belonging to the parent.
/// [onTogglePin] should be a callback to a function that assigns a new value to the parent's attribute that [isPinned] derives its value from.
/// [children] are arranged to the sides of the pin button.
class PinnableSlidingContainer extends StatefulWidget {
  const PinnableSlidingContainer({
    super.key,
    required this.isPinned,
    required this.onTogglePin,
    required this.children,
  });
  final bool isPinned;
  final VoidCallback onTogglePin;
  final List<Widget> children;

  @override
  State<StatefulWidget> createState() => PinnableSlidingContainerState();
}

class PinnableSlidingContainerState extends State<PinnableSlidingContainer> {
  bool _isShown = true;

  @override
  Widget build(BuildContext context) {
    final hideButton = TonalToggleIconButton.narrow(
      isSelected: widget.isPinned,
      tooltip: widget.isPinned ? "Unpin" : "Pin",
      onPressed: widget.onTogglePin,
      icon: Icon(Icons.push_pin_outlined),
      selectedIcon: Icon(Icons.push_pin),
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

    return widget.isPinned
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

/// A widget that allows for panning, zooming, and applying a monochrome filter on an image.
///
/// [source] is the image's file.
class ImageArea extends StatefulWidget {
  const ImageArea({
    super.key,
    required this.source,
    required this.isMonochrome,
  });
  final File source;
  final bool isMonochrome;

  @override
  State<ImageArea> createState() => _ImageAreaState();
}

class _ImageAreaState extends State<ImageArea> {
  late final TransformationController _transformationController;
  bool _isZoomedIn = false;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformationChanged);
  }

  void _onTransformationChanged() {
    final double scale = _transformationController.value.getMaxScaleOnAxis();
    final bool zoomedIn = scale > 1.05;

    if (zoomedIn != _isZoomedIn) {
      setState(() {
        _isZoomedIn = zoomedIn;
      });
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _isZoomedIn
          ? SystemMouseCursors.allScroll
          : SystemMouseCursors.basic,
      child: ClipRRect(
        borderRadius: .circular(8.0),
        child: InteractiveViewer(
          transformationController: _transformationController,
          clipBehavior: Clip.antiAlias,
          minScale: 1.0,
          maxScale: 10.0,
          child: SizedBox.expand(
            child: widget.isMonochrome
                ? ColorFiltered(
                    colorFilter: grayscaleFilter,
                    child: Image.file(widget.source, fit: .contain),
                  )
                : Image.file(widget.source, fit: .contain),
          ),
        ),
      ),
    );
  }
}
