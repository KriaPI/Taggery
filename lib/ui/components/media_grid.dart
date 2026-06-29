import 'package:flutter/material.dart';
import 'package:taggery/ui/components/containers.dart';


// TODO: add an option to preferences to select from a range of sizes instead (or a number of cells that should be displayed at most when the app is in fullscreen and does not have the viewer open).
const int arbitraryMinimumCellSize = 300;

class MediaGrid extends StatelessWidget {
  const MediaGrid({super.key, required this.selectionCallback});
  final void Function(int index) selectionCallback;

  @override
  Widget build(BuildContext context) {
    return Pane(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GridView.count(
              crossAxisCount: (constraints.maxWidth / arbitraryMinimumCellSize)
                  .round(),
              children: List.generate(15, (index) {
                return MediaTile.thumbnailUnavailable(index: index, onTap: selectionCallback);
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class MediaTile extends StatelessWidget {
  const MediaTile({super.key, required this.media, required this.index, required this.onTap});
  MediaTile.thumbnailUnavailable({super.key, required this.index, required this.onTap}): media = Icon(Icons.image); 
  final Widget media;
  final int index;
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: media
      ),
    );
  }
}