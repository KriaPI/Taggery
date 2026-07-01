import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return gallery.when(
      loading: () => Pane(child: BodyText("Loading Images...")),
      error: (error, stackTrace) => Pane(child: Column(
        crossAxisAlignment: .center,
        children: [
          TitleText("An error occurred while loading."),
          BodyText("$error"),
          BodyText("$stackTrace")
        ],
      )),
      data: (data) => Pane(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GridView.count(
              crossAxisCount: (constraints.maxWidth / arbitraryMinimumCellSize)
                  .round(),
              children: List.generate(data.length, (index) {
                return ImageTile(
                  media: Image(
                    image: ResizeImage(FileImage(data[index].source),
                      width: arbitraryMinimumCellSize
                    ),
                    fit: .contain,
                  ),
                  index: index,
                  onTap: selectionCallback,
                );
              }).toList(),
            );
          },
        ),
      ),
    ));
  }
}

class ImageTile extends StatelessWidget {
  const ImageTile({
    super.key,
    required this.media,
    required this.index,
    required this.onTap,
  });
  ImageTile.thumbnailUnavailable({
    super.key,
    required this.index,
    required this.onTap,
  }) : media = Icon(Icons.image);
  final Widget media;
  final int index;
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: media,
      ),
    );
  }
}
