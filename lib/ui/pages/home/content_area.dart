import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taggery/logic/settings.dart';
import 'package:taggery/models/gallery.dart';
import 'package:taggery/logic/gallery.dart';
import 'package:taggery/logic/tabs.dart';
import 'package:taggery/models/settings.dart';
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
class ContentArea extends StatefulWidget {
  const ContentArea({super.key});

  @override
  State<StatefulWidget> createState() => _ContentAreaState();
}

class _ContentAreaState extends State<ContentArea> {
  final GlobalKey _viewerKey = GlobalKey(debugLabel: "Image viewer");
  ContentAreaViewMode _viewMode = .gridExpanded;

  /// The index of the gallery entry that the primary tab is showing.
  int primaryTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final viewerArea = Container(
      decoration: BoxDecoration(
        borderRadius: .circular(8.0),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: BlocBuilder<GalleryCubit, GalleryState>(
        builder: (context, state) {
          return switch (state) {
            GalleryLoadSuccess() => ImageViewerContainer(
              key: _viewerKey,
              isInFullview: _viewMode == .viewerExpanded,
              primaryTab: state.content[primaryTabIndex],
              onPrevious: () => previous(),
              onNext: () => next(),
              onClose: closeViewer,
              onToggleFullview: expandOrMinimizeViewer,
            ),
            // Return the equivalent of nothing if the gallery has not loaded yet.
            _ => const SizedBox(),
          };
        },
      ),
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
            child: BlocBuilder<GalleryCubit, GalleryState>(
              builder: (context, state) {
                return switch (state) {
                  GalleryInitial() => const SizedBox(),
                  GalleryLoadSuccess() => MediaGrid(
                    key: PageStorageKey("Gallery grid scroll extent"),
                    onSelect: open,
                    onSelectTab: openInTab,
                    gallery: state.content,
                  ),
                  GalleryLoadingInProgress() => Center(
                    child: CircularProgressIndicator(),
                  ),
                  GalleryLoadFailure() => Column(
                    crossAxisAlignment: .center,
                    children: [
                      TitleText("Could not load images."),
                      BodyText("Error"),
                      BodyText("Could not load images."),
                    ],
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );

    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) =>
          current is SettingsLoadSuccess && previous != current,
      listener: (context, state) {
        if (state is SettingsLoadSuccess) {
          context.read<GalleryCubit>().loadDirectory(state.sourceRootPath);
        }
      },
      child: switch (_viewMode) {
        .gridExpanded => gridWithFilters,
        .splitView => Row(
          spacing: 8.0,
          children: [
            Expanded(child: gridWithFilters),
            Expanded(child: viewerArea),
          ],
        ),
        .viewerExpanded => viewerArea,
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // 1. Check if settings are ALREADY loaded when this widget mounts
    final settingsState = context.read<SettingsCubit>().state;
    if (settingsState is SettingsLoadSuccess) {
      context.read<GalleryCubit>().loadDirectory(settingsState.sourceRootPath);
    }
  }

  void closeViewer() {
    setState(() {
      _viewMode = .gridExpanded;
    });
  }

  /// Open the image at [index] in the viewer.
  void open(int index) {
    final gallery = context.read<GalleryCubit>().state;
    if (gallery is GalleryLoadSuccess) {
      final File toOpen = gallery.content[index].source;
      precacheImage(FileImage(toOpen), context);
    }

    setState(() {
      primaryTabIndex = index;
      _viewMode = .splitView;
    });
  }

  /// Open the image at [index] as a tab in the viewer.
  void openInTab(int index) {
    final gallery = context.read<GalleryCubit>().state;
    if (gallery is GalleryLoadSuccess) {
      final newTab = gallery.content[index];
      precacheImage(FileImage(newTab.source), context);
      context.read<TabCubit>().openTab(newTab);
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
    final gallery = context.read<GalleryCubit>().state;

    // Precache the image before the image at newIndex.
    if (gallery is GalleryLoadSuccess) {
      final galleryLength = gallery.content.length;
      int newIndex = getPreviousIndex(primaryTabIndex, galleryLength);
      final int previousIndex = getPreviousIndex(newIndex, galleryLength);
      final File next = gallery.content[previousIndex].source;
      precacheImage(FileImage(next), context);

      setState(() {
        primaryTabIndex = newIndex;
      });
    }
  }

  void next() {
    final gallery = context.read<GalleryCubit>().state;

    // Precache the image after the image at newIndex.
    if (gallery is GalleryLoadSuccess) {
      final galleryLength = gallery.content.length;
      int newIndex = getNextIndex(primaryTabIndex, galleryLength);
      final int nextIndex = getNextIndex(newIndex, galleryLength);
      final File next = gallery.content[nextIndex].source;
      precacheImage(FileImage(next), context);

      setState(() {
        primaryTabIndex = newIndex;
      });
    }
  }
}
