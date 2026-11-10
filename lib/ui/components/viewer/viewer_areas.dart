import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:media_kit_video/media_kit_video.dart';

// TODO: fix zooming with trackpad. Should zoom to where the mouse is at, but instead zooms into the nearest corner.


/// A widget that allows for panning, zooming, and applying a monochrome filter on an image.
class ImageArea extends StatefulWidget {
  const ImageArea({
    super.key,
    required this.source,
    required this.isMonochrome,
  });
  final File source;
  final bool isMonochrome;

  @override
  State<ImageArea> createState() => _ImageAreaState();
}

class _ImageAreaState extends State<ImageArea> {
  late final TransformationController _transformationController;
  bool _isZoomedIn = false;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformationChanged);
  }

  void _onTransformationChanged() {
    final double scale = _transformationController.value.getMaxScaleOnAxis();
    final bool zoomedIn = scale > 1.05;

    if (zoomedIn != _isZoomedIn) {
      setState(() {
        _isZoomedIn = zoomedIn;
      });
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _isZoomedIn
          ? SystemMouseCursors.allScroll
          : SystemMouseCursors.basic,
      child: ClipRRect(
        borderRadius: .circular(8.0),
        child: InteractiveViewer(
          constrained: true,
          transformationController: _transformationController,
          clipBehavior: Clip.antiAlias,
          minScale: 1.0,
          maxScale: 10.0,
          child: SizedBox.expand(
            child: widget.isMonochrome
                ? ColorFiltered(
                    colorFilter: grayscaleFilter,
                    child: Image.file(
                      widget.source,
                      gaplessPlayback: true,
                      fit: .contain,
                    ),
                  )
                : Image.file(
                    widget.source,
                    gaplessPlayback: true,
                    fit: .contain,
                  ),
          ),
        ),
      ),
    );
  }
}

/// A widget that allows for panning, zooming, and applying a monochrome filter on a video.
class VideoArea extends StatefulWidget {
  const VideoArea({
    super.key,
    required this.source,
    required this.isMonochrome,
    required this.videoController,
    required this.onTap,
  });
  final File source;
  final bool isMonochrome;
  final VideoController videoController;
  final VoidCallback onTap;

  @override
  State<VideoArea> createState() => _VideoAreaState();
}

class _VideoAreaState extends State<VideoArea> {
  late final TransformationController _transformationController;
  bool _isZoomedIn = false;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformationChanged);
  }

  void _onTransformationChanged() {
    final double scale = _transformationController.value.getMaxScaleOnAxis();
    final bool zoomedIn = scale > 1.05;

    if (zoomedIn != _isZoomedIn) {
      setState(() {
        _isZoomedIn = zoomedIn;
      });
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = Video(
      controller: widget.videoController,
      fit: .contain,
      controls: NoVideoControls,
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: _isZoomedIn
            ? SystemMouseCursors.allScroll
            : SystemMouseCursors.basic,
        child: ClipRRect(
          borderRadius: .circular(8.0),
          child: InteractiveViewer(
            transformationController: _transformationController,
            clipBehavior: Clip.antiAlias,
            minScale: 1.0,
            maxScale: 10.0,
            child: SizedBox.expand(
              child: widget.isMonochrome
                  ? ColorFiltered(colorFilter: grayscaleFilter, child: video)
                  : video,
            ),
          ),
        ),
      ),
    );
  }
}

// dart format off
const ColorFilter grayscaleFilter = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0, 
  0.2126, 0.7152, 0.0722, 0, 0, 
  0, 0, 0, 1, 0,
]);
// dart format on