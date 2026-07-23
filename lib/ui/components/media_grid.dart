import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taggery/model/gallery_entry.dart';
import 'package:taggery/providers/gallery_provider.dart';
import 'package:taggery/ui/components/containers.dart';
import 'package:taggery/ui/components/text_variants.dart';

// TODO: add an option to preferences to select from a range of sizes instead (or a number of cells that should be displayed at most when the app is in fullscreen and does not have the viewer open).
const int arbitraryMinimumCellSize = 300;

class MediaGrid extends ConsumerWidget {
  const MediaGrid({super.key, required this.selectionCallback});
  final void Function(int index) selectionCallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gallery = ref.watch(galleryProvider);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);

    return gallery.when(
      loading: () => Pane(child: BodyText("Loading Images...")),
      error: (error, stackTrace) => Pane(
        child: Column(
          crossAxisAlignment: .center,
          children: [
            TitleText("An error occurred while loading."),
            BodyText("$error"),
            BodyText("$stackTrace"),
          ],
        ),
      ),
      data: (data) => Pane(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GridView.count(
              crossAxisCount: (constraints.maxWidth / arbitraryMinimumCellSize)
                  .round(),
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.9,
              children: List.generate(data.length, (index) {
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
                  onTap: selectionCallback,
                  tags: entry.tags,
                );
              }).toList(),
            );
          },
        ),
      ),
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
