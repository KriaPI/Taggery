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
            return ImageTile(
              media: Image(
                image: ResizeImage(
                  FileImage(entry.source),
                  width: (arbitraryMinimumCellSize * pixelRatio).round(),
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

class ImageTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        crossAxisAlignment: .stretch,
        spacing: 8.0,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.all(.circular(8.0)),
              clipBehavior: .antiAlias,
              child: media,
            ),
          ),
          Text(
            tags.take(4).map((element) => "#$element ").join(),
            overflow: .ellipsis,
          ),
        ],
      ),
    );
  }
}
