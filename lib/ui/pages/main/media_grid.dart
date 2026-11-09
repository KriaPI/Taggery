import 'package:material_ui/material_ui.dart';
import 'package:taggery/state/models/gallery.dart';
import 'package:taggery/ui/components/image_tile.dart';

// TODO: add a button after the tags to edit the tags when the user hovers over an item.
// TODO: add an option to preferences to select from a range of sizes instead (or a number of cells that §ould be displayed at most when the app is in fullscreen and does not have the viewer open).
const int arbitraryMinimumCellSize = 300;

// TODO: load images while scrolling, instead of loading everything at once.
class MediaGrid extends StatefulWidget {
  const MediaGrid({
    super.key,
    required this.onSelect,
    required this.onSelectTab,
    required this.gallery,
    this.mainAxisSpacing = 2,
    this.crossAxisSpacing = 2,
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
  int lastCrossAxisCount = 0;
  double lastItemHeight = 0;

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
        final maxWidth = constraints.maxWidth;
        final crossAxisCount = (maxWidth / arbitraryMinimumCellSize)
            .round()
            .clamp(1, 10);

        final itemWidth = calculateItemWidth(
          maxWidth,
          crossAxisCount,
        );

        final itemHeight = calculateItemHeight(context, itemWidth);

        // TODO: figure out a way of persisting the lastcrossaxiscount and lastitemheight. This widget's state
        // is destroyed once split view is entered. Figure out how to avoid this state from being destroyed!
        // if (constraintsHaveChanged(crossAxisCount) && _scrollController.hasClients) {
        //   final newScrollOffset = calculateNewScrollOffset(crossAxisCount, itemHeight);
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     _scrollController.jumpTo(newScrollOffset);
        //   });
        // }

        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   setLastConstraints(crossAxisCount, itemHeight);  
        // });

        return GridView.builder(
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: widget.crossAxisSpacing,
            mainAxisSpacing: widget.mainAxisSpacing,
            mainAxisExtent: itemHeight,
          ),
          itemCount: widget.gallery.length,
          itemBuilder: (context, index) {
            final GalleryEntry entry = widget.gallery[index];
            final imageWidth = ((itemWidth) * pixelRatio).ceil();
            final imageHeight = imageWidth;

            return !entry.isVideo
                ? ImageTile(
                    source: entry.source,
                    decodeHeight: imageHeight,
                    decodeWidth: imageWidth,
                    index: index,
                    onTap: widget.onSelect,
                    onTapShift: widget.onSelectTab,
                  )
                : ImageTile.thumbnailUnavailable(
                    index: index,
                    onTap: widget.onSelect,
                    onTapShift: widget.onSelectTab,
                  );
          },
        );
      },
    );
  }

  double calculateNewScrollOffset(int crossAxisCount, double itemHeight) {
    final scrollOffset = _scrollController.offset;
    final scrolledPastRows = (scrollOffset / (lastItemHeight + widget.mainAxisSpacing)).round();
    final firstVisibleItemIndex = scrolledPastRows * lastCrossAxisCount + 1;
    
    final scrolledPastRowsInNewLayout = firstVisibleItemIndex ~/ crossAxisCount;
    final newScrollOffset = scrolledPastRowsInNewLayout * (itemHeight + widget.mainAxisSpacing); 
    return newScrollOffset;
  }

  bool constraintsHaveChanged(int crossAxisCount) {
    return crossAxisCount != lastCrossAxisCount; 
  }

  void setLastConstraints(int crossAxisCount, double itemHeight) {
    lastCrossAxisCount = crossAxisCount;
    lastItemHeight = itemHeight; 
  }

  double calculateItemHeight(BuildContext context, double cellWidth) {
    final padding = 8.0;
    final imageHeight = cellWidth;

    return imageHeight + padding;
  }

  double calculateExtendedItemHeight(BuildContext context, double cellWidth) {
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

