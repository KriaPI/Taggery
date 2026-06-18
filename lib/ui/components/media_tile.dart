import 'package:flutter/material.dart';

class MediaTile extends StatelessWidget {
  const MediaTile({super.key, required this.media});
  MediaTile.thumbnailUnavailable({super.key}): media = Icon(Icons.image); 
  final Widget media;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: media
    );
  }
}