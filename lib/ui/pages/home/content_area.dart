import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taggery/model/gallery_entry.dart';
import 'package:taggery/providers/gallery.dart';
import 'package:taggery/providers/viewer_tabs.dart';
import 'package:taggery/ui/components/text_variants.dart';
import 'package:taggery/ui/pages/home/content_filters.dart';
import 'package:taggery/ui/pages/home/media_grid.dart';
import 'package:taggery/ui/pages/home/image_viewer.dart';

enum ContentAreaViewMode { gridExpanded, splitView, viewerExpanded }

// TODO: show a pop-up message in the bottom right corner that tells the user that a tab has been opened
// TODO: provide a way of showing the viewer without clicking on an image if the user has already opened a tab.

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
  final GlobalKey _viewerKey = GlobalKey(debugLabel: "Image viewer");
  ContentAreaViewMode _viewMode = .gridExpanded;
  int primaryTabIndex = 0;
  List<GalleryEntry>? galleryContents;
  int galleryEntryCount = 0;

  @override
  Widget build(BuildContext context) {
    final gallery = ref.watch(galleryProvider);

    final viewer = gallery.when(
      data: (data) {
        return ImageViewerContainer(
          key: _viewerKey,
          isInFullview: _viewMode == .viewerExpanded,
          primaryTab: data[primaryTabIndex],
          onPrevious: () => previous(),
          onNext: () => next(),
          onClose: closeViewer,
          onToggleFullview: expandOrMinimizeViewer,
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
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
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
              data: (data) {
                // This update is required for the viewer to work.
                galleryContents = data as List<GalleryEntry>;
                galleryEntryCount = data.length;
                return MediaGrid(
                  key: PageStorageKey("Gallery grid scroll extent"),
                  onSelect: open,
                  onSelectTab: openInTab,
                  gallery: data,
                );
              },
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

  /// Open the image at [index] in the viewer.
  void open(int index) {
    if (galleryContents != null) {
      final File toOpen = galleryContents![index].source;
      precacheImage(FileImage(toOpen), context);
    }

    setState(() {
      primaryTabIndex = index;
      _viewMode = .splitView;
    });
  }

  /// Open the image at [index] as a tab in the viewer.
  void openInTab(int index) {
    if (galleryContents != null) {
      final newTab = galleryContents![index];
      precacheImage(FileImage(newTab.source), context);
      ref.read(viewerTabsNotifierProvider.notifier).openTab(newTab);
    }

    if (_viewMode != ContentAreaViewMode.splitView) {
      setState(() {
        primaryTabIndex = index;
        _viewMode = .splitView;
      });
    }
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

  /// Assumes the boundaries are [0, length - 1].
  int getPreviousIndex(int current, int length) {
    return current != 0 ? current - 1 : length - 1;
  }

  /// Assumes the boundaries are [0, length].
  int getNextIndex(int current, int length) {
    return current != length - 1 ? current + 1 : 0;
  }

  void previous() {
    int newIndex = getPreviousIndex(primaryTabIndex, galleryEntryCount);

    // Precache the image before the image at newIndex.
    if (galleryContents != null) {
      final int previousIndex = getPreviousIndex(newIndex, galleryEntryCount);
      final File next = galleryContents![previousIndex].source;
      precacheImage(FileImage(next), context);
    }

    setState(() {
      primaryTabIndex = newIndex;
    });
  }

  void next() {
    int newIndex = getNextIndex(primaryTabIndex, galleryEntryCount);

    // Precache the image after the image at newIndex.
    if (galleryContents != null) {
      final int nextIndex = getNextIndex(newIndex, galleryEntryCount);
      final File next = galleryContents![nextIndex].source;
      precacheImage(FileImage(next), context);
    }

    setState(() {
      primaryTabIndex = newIndex;
    });
  }
}
