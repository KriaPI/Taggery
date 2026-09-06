import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:taggery/models/gallery.dart';

// TODO: add a button after the tags to edit the tags when the user hovers over an item.
// TODO: add an option to preferences to select from a range of sizes instead (or a number of cells that §ould be displayed at most when the app is in fullscreen and does not have the viewer open).
const int arbitraryMinimumCellSize = 300;

// TODO: keep scrolling even if the widget changes dimensions.

// TODO: load images while scrolling, instead of loading everything at once.
class MediaGrid extends StatefulWidget {
  const MediaGrid({
    super.key,
    required this.onSelect,
    required this.onSelectTab,
    required this.gallery,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 8.0,
  });
  final void Function(int index) onSelect;
  final void Function(int index) onSelectTab;
  final List<GalleryEntry> gallery;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  @override
  State<MediaGrid> createState() => _MediaGridState();
}

class _MediaGridState extends State<MediaGrid> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / arbitraryMinimumCellSize)
            .round()
            .clamp(1, 10);

        final itemWidth = calculateItemWidth(
          constraints.maxWidth,
          crossAxisCount,
        );

        final itemHeight = calculateItemHeight(context, itemWidth);

        return GridView.builder(
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: widget.crossAxisSpacing,
            mainAxisSpacing: widget.crossAxisSpacing,
            mainAxisExtent: itemHeight,
          ),
          itemCount: widget.gallery.length,
          itemBuilder: (context, index) {
            final GalleryEntry entry = widget.gallery[index];
            final imageWidth = ((itemWidth) * pixelRatio).ceil();
            final imageHeight = imageWidth;

            return !entry.isVideo
                ? ImageTile(
                    media: Image(
                      image: ResizeImage(
                        FileImage(entry.source),
                        width: imageWidth,
                        height: imageHeight,
                        policy: .fit,
                        allowUpscaling: true,
                      ),
                      fit: .cover,
                    ),
                    index: index,
                    onTap: widget.onSelect,
                    onTapShift: widget.onSelectTab,
                    tags: entry.tags,
                  )
                : ImageTile.thumbnailUnavailable(
                    index: index,
                    onTap: widget.onSelect,
                    onTapShift: widget.onSelectTab,
                    tags: entry.tags,
                  );
          },
        );
      },
    );
  }

  double calculateItemHeight(BuildContext context, double cellWidth) {
    final textHeight = getTextHeight(style: DefaultTextStyle.of(context).style);
    final padding = 8.0;
    final imageHeight = cellWidth;

    return imageHeight + padding + textHeight;
  }

  double calculateItemWidth(double width, int crossAxisCount) {
    return (width - (widget.crossAxisSpacing * (crossAxisCount - 1))) /
        crossAxisCount;
  }

  double getTextHeight({
    required TextStyle style,
    double maxWidth = double.infinity,
    int maxLines = 1,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: "Hello", style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return textPainter.size.height;
  }
}

// TODO: add a context menu when right clicking on an imagetile

class ImageTile extends StatefulWidget {
  const ImageTile({
    super.key,
    required this.media,
    required this.index,
    required this.onTap,
    required this.onTapShift,
    this.tags = const [],
  });

  ImageTile.thumbnailUnavailable({
    super.key,
    required this.index,
    required this.onTap,
    required this.onTapShift,
    this.tags = const [],
  }) : media = FittedBox(fit: .cover, child: Icon(Icons.image));

  final Widget media;
  final int index;
  final void Function(int index) onTap;
  final void Function(int index) onTapShift;
  final List<String> tags;

  @override
  State<ImageTile> createState() => _ImageTileState();
}

class _ImageTileState extends State<ImageTile> {
  bool isHoveredOver = false;

  @override
  Widget build(BuildContext context) {
    final thumbnail = AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.all(.circular(8.0)),
        clipBehavior: .antiAlias,
        child: isHoveredOver
            ? ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.2),
                  BlendMode.darken,
                ),
                child: widget.media,
              )
            : widget.media,
      ),
    );

    final tile = Column(
      crossAxisAlignment: .stretch,
      spacing: 8.0,
      children: [
        thumbnail,
        Text(
          widget.tags.take(4).map((element) => "#$element ").join(),
          overflow: .ellipsis,
        ),
      ],
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
        child: tile,
      ),
    );
  }
}
