import 'package:flutter/material.dart';
import 'package:taggery/ui/components/containers.dart';

class MediaViewer extends StatelessWidget {
  const MediaViewer({super.key, required this.onClose, required this.onPrevious, required this.onNext});
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Pane(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BackButton(onPressed: onClose),
                IconButton(
                  onPressed: DoNothingAction.new,
                  icon: Icon(Icons.more_vert_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              alignment: AlignmentGeometry.center,
              children: [
                // TODO: replace with actual image
                Icon(Icons.image),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filledTonal(
                        onPressed: onPrevious,
                        icon: Icon(Icons.chevron_left_rounded),
                      ),
                      IconButton.filledTonal(
                        onPressed: onNext,
                        icon: Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}