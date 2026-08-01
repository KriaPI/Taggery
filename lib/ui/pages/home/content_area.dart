import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taggery/model/gallery_entry.dart';
import 'package:taggery/providers/gallery_provider.dart';
import 'package:taggery/ui/components/text_variants.dart';
import 'package:taggery/ui/pages/home/content_filters.dart';
import 'package:taggery/ui/pages/home/media_grid.dart';
import 'package:taggery/ui/pages/home/image_viewer.dart';

enum ContentAreaViewMode { gridExpanded, splitView, viewerExpanded }

/// A widget that manages the state of, and contains, the gallery grid and viewer.
///
/// This widget manages the state of the gallery grid and the state of the media viewer that is
/// opened when a tile of the gallery grid is clicked on. This state includes the list of image shown
/// in the grid (and viewer) and the index of the list that is currently shown in the viewer.
class ContentArea extends ConsumerStatefulWidget {
  const ContentArea({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContentAreaState();
}

class _ContentAreaState extends ConsumerState<ContentArea> {
  ContentAreaViewMode _viewMode = .gridExpanded;
  final GlobalKey _viewerKey = GlobalKey(debugLabel: "Image viewer");
  int viewedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final gallery = ref.watch(galleryProvider);

    final viewer = gallery.when(
      data: (data) {
        final entry = data[viewedIndex] as GalleryEntry;
        return ImageViewer(
          key: _viewerKey,
          image: entry.source,
          name: entry.name,
          onPrevious: () => previous(data.length - 1),
          onNext: () => next(data.length - 1),
          onClose: closeViewer,
          onExpandOrMinimize: expandOrMinimizeViewer,
          isExpanded: _viewMode == .viewerExpanded,
        );
      },
      error: (_, _) => null,
      loading: () => null,
    );

    final viewerArea = Container(
      decoration: BoxDecoration(
        borderRadius: .circular(8.0),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: viewer,
    );

    final gridWithFilters = Container(
      decoration: BoxDecoration(
        borderRadius: .circular(8.0),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      padding: EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0.0),
      child: Column(
        spacing: 48.0,
        children: [
          const ContentFilters(),
          Expanded(
            child: gallery.when(
              data: (data) => MediaGrid(
                key: PageStorageKey("Gallery grid scroll extent"),
                onSelect: openViewer,
                data: data as List<GalleryEntry>,
              ),
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Column(
                crossAxisAlignment: .center,
                children: [
                  TitleText("Could not load images."),
                  BodyText("$error"),
                  BodyText("$stackTrace"),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return switch (_viewMode) {
      .gridExpanded => gridWithFilters,
      .splitView => Row(
        spacing: 8.0,
        children: [
          Expanded(child: gridWithFilters),
          Expanded(child: viewerArea),
        ],
      ),
      .viewerExpanded => viewerArea,
    };
  }

  void closeViewer() {
    setState(() {
      _viewMode = .gridExpanded;
    });
  }

  void openViewer(int index) {
    setState(() {
      viewedIndex = index;
      _viewMode = .splitView;
    });
  }

  void expandOrMinimizeViewer() {
    if (_viewMode == .splitView) {
      setState(() {
        _viewMode = .viewerExpanded;
      });
    } else if (_viewMode == .viewerExpanded) {
      setState(() {
        _viewMode = .splitView;
      });
    } else {
      // This should never happen!
      assert(false);
    }
  }

  void previous(int lastIndex) {
    int newIndex = viewedIndex != 0 ? viewedIndex - 1 : lastIndex;

    setState(() {
      viewedIndex = newIndex;
    });
  }

  void next(int lastIndex) {
    int newIndex = viewedIndex != lastIndex ? viewedIndex + 1 : 0;

    setState(() {
      viewedIndex = newIndex;
    });
  }
}
