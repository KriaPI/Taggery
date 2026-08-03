import 'package:flutter/material.dart';
import 'package:taggery/model/gallery_entry.dart';

// TODO: add an option to preferences to select from a range of sizes instead (or a number of cells that §ould be displayed at most when the app is in fullscreen and does not have the viewer open).
const int arbitraryMinimumCellSize = 300;

// TODO: keep scrolling even if the widget changes dimensions.
class MediaGrid extends StatelessWidget {
  const MediaGrid({super.key, required this.onSelect, required this.data});
  final void Function(int index) onSelect;
  final List<GalleryEntry> data;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / arbitraryMinimumCellSize)
            .round()
            .clamp(1, 10);

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 32.0,
            // TODO: dynamically calculate the childaspectratio.
            childAspectRatio: 0.9,
          ),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final GalleryEntry entry = data[index];
            final resolution = entry.resolution;
            final itemResolution =
                ((arbitraryMinimumCellSize / resolution.aspectRatio) *
                        pixelRatio)
                    .ceil();

            return ImageTile(
              media: Image(
                image: ResizeImage(
                  FileImage(entry.source),
                  width: resolution.width <= resolution.height
                      ? itemResolution
                      : null,
                  height: resolution.width <= resolution.height
                      ? null
                      : itemResolution,
                  policy: .fit,
                  allowUpscaling: true,
                ),
                fit: .cover,
              ),
              index: index,
              onTap: onSelect,
              tags: entry.tags,
            );
          },
        );
      },
    );
  }
}

class ImageTile extends StatefulWidget {
  const ImageTile({
    super.key,
    required this.media,
    required this.index,
    required this.onTap,
    this.tags = const [],
  });

  ImageTile.thumbnailUnavailable({
    super.key,
    required this.index,
    required this.onTap,
    this.tags = const [],
  }) : media = Icon(Icons.image);

  final Widget media;
  final int index;
  final void Function(int index) onTap;
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

    return GestureDetector(
      onTap: () => widget.onTap(widget.index),
      child: MouseRegion(
        onEnter: (_) => setState(() {
          isHoveredOver = true;
        }),
        onExit: (_) => setState(() {
          isHoveredOver = false;
        }),
        child: Column(
          crossAxisAlignment: .stretch,
          spacing: 8.0,
          children: [
            thumbnail,
            Text(
              widget.tags.take(4).map((element) => "#$element ").join(),
              overflow: .ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
