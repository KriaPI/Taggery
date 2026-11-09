import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

// TODO: add a context menu when right clicking on an imagetile

class ImageTile extends StatefulWidget {
  const new({
    super.key,
    required this.source,
    required this.decodeWidth,
    required this.decodeHeight,
    required this.index,
    required this.onTap,
    required this.onTapShift,
  });

  const ImageTile.thumbnailUnavailable({
    super.key,
    required this.index,
    required this.onTap,
    required this.onTapShift,
    this.decodeHeight = 0,
    this.decodeWidth = 0,
    this.source
  });

  final File? source;
  final int decodeWidth;
  final int decodeHeight;
  final int index;
  final void Function(int index) onTap;
  final void Function(int index) onTapShift;

  @override
  State<ImageTile> createState() => _ImageTileState();
}

class _ImageTileState extends State<ImageTile> {
  bool isHoveredOver = false;

  @override
  Widget build(BuildContext context) {
    final media = widget.source == null
        ? FittedBox(fit: .cover, child: Icon(Icons.image))
        : Image(
            image: ResizeImage(
              FileImage(widget.source!),
              width: widget.decodeWidth,
              height: widget.decodeHeight,
              policy: .fit,
              allowUpscaling: true,
            ),
            fit: .cover,
          );

    final thumbnail = ClipRect(
      child: AspectRatio(
        aspectRatio: 1,
        child: isHoveredOver
            ? ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.2),
                  BlendMode.darken,
                ),
                child: media,
              )
            : media,
      ),
    );

    return GestureDetector(
      onTap: () {
        if (HardwareKeyboard.instance.isShiftPressed) {
          widget.onTapShift(widget.index);
        } else {
          widget.onTap(widget.index);
        }
      },
      child: MouseRegion(
        onEnter: (_) => setState(() {
          isHoveredOver = true;
        }),
        onExit: (_) => setState(() {
          isHoveredOver = false;
        }),
        child: thumbnail,
      ),
    );
  }
}
