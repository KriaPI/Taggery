import 'dart:async';

import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:taggery/state/tabs.dart';
import 'package:taggery/ui/components/containers.dart';
import 'package:taggery/ui/components/misc.dart';
import 'package:taggery/ui/components/viewer/controls.dart';
import 'package:taggery/ui/components/viewer/tab_components.dart';
import 'package:taggery/ui/components/viewer/video_controls.dart';
import 'package:taggery/ui/components/viewer/viewer_areas.dart';
import 'package:taggery/ui/configuration/default_keybindings.dart';

/// This widget contains the header for the viewer and the viewer itself as a child.
///
/// The header includes the close button, the tab bar, and the maximize/minimize button. This widget manages
/// the state of the tabs and shortcuts map.
class ImageViewerContainer extends StatefulWidget {
  const ImageViewerContainer({
    super.key,
    required this.focusNode,
    required this.primaryIndex,
    required this.onPrevious,
    required this.onNext,
    required this.onClose,
    this.viewModeControls,
  });

  /// The index of the gallery entry shown in the first tab. This is used to compare in didWidgetUpdate().
  final FocusNode focusNode;
  final int primaryIndex;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final Widget? viewModeControls;

  @override
  State<StatefulWidget> createState() => ImageViewerContainerState();
}

class ImageViewerContainerState extends State<ImageViewerContainer>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _alwaysShowControls = true;
  bool _isMonochrome = false;

  @override
  void initState() {
    int tabCount = context.read<TabCubit>().state.length;
    _tabController = TabController(
      length: tabCount,
      vsync: this,
      animationDuration: Duration.zero,
    );

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ImageViewerContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Show the primary tab if the user opens a new image while
    // having a different tab open.
    if (oldWidget.primaryIndex != widget.primaryIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tabController.index = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: DefaultSpacing.small,
      children: [
        SizedBox(
          height: 24,
          child: Row(
            children: [
              Expanded(
                child: BlocConsumer<TabCubit, List<TabState>>(
                  listener: (context, state) {
                    // Update the length of the tab controller to match the cubit.
                    // The length is +1 because there is always an additional tab open
                    // that allows the user to navigate between gallery items (images/videos).
                    _updateTabController(state.length);
                  },
                  builder: (context, tabs) => ViewerTabBar(
                    tabController: _tabController,
                    tabTitles: tabs.map((entry) => entry.content.name).toList(),
                    onCloseTab: (index) {
                      context.read<TabCubit>().closeTab(index);
                    },
                  ),
                ),
              ),
              if (widget.viewModeControls != null) ...[
                widget.viewModeControls!,
              ],
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<TabCubit, List<TabState>>(
            builder: (context, tabs) => ImageViewer(
              key: ValueKey(widget.primaryIndex),
              focusNode: widget.focusNode,
              tabController: _tabController,
              onPrevious: widget.onPrevious,
              onNext: widget.onNext,
              onClose: widget.onClose,
              onTogglePinControls: togglePinControls,
              onToggleMonochrome: toggleMonochrome,
              areControlsPinned: _alwaysShowControls,
              showMonochrome: _isMonochrome,
            ),
          ),
        ),
      ],
    );
  }

  /// Get the index of the tab that was opened.
  int _getNewTabIndex(int newLength, int previousIndex) {
    return newLength >= 2 && previousIndex != 0 ? 1 : 0;
  }

  /// Update the length and currently viewed index of the tab controller.
  void _updateTabController(int newLength) {
    if (_tabController.length == newLength) return;

    final newCurrentIndex = _getNewTabIndex(newLength, _tabController.index);
    _tabController.dispose();

    setState(() {
      _tabController = TabController(
        length: newLength,
        vsync: this,
        animationDuration: Duration.zero,
        initialIndex: newCurrentIndex,
      );
    });
  }

  void toggleMonochrome() {
    setState(() {
      _isMonochrome = !_isMonochrome;
    });
  }

  void togglePinControls() {
    setState(() {
      _alwaysShowControls = !_alwaysShowControls;
    });
  }
}

// TODO: fix bug where video playback state is not saved when the viewer is closed.

/// The widget containing the image and the media controls.
class ImageViewer extends StatefulWidget {
  const ImageViewer({
    super.key,
    required this.focusNode,
    required this.tabController,
    required this.onPrevious,
    required this.onNext,
    required this.onClose,
    required this.onTogglePinControls,
    required this.onToggleMonochrome,
    required this.areControlsPinned,
    required this.showMonochrome,
  });
  final FocusNode focusNode;
  final TabController tabController;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final VoidCallback onTogglePinControls;
  final VoidCallback onToggleMonochrome;
  final bool areControlsPinned;
  final bool showMonochrome;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late final player = Player(
    configuration: PlayerConfiguration(logLevel: MPVLogLevel.error),
  );
  late final videoController = VideoController(player);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      player.setPlaylistMode(.loop);
      conditionallyPlayVideo(playImmediately: true);
    });

    // Listen to tab selection changes to rebuild the toolbar and load videos.
    widget.tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_handleTabSelection);
    player.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ImageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle tabController replacements when length changes in parent.
    // We check for equality since the tabController is replaced when the length changes.
    if (oldWidget.tabController != widget.tabController) {
      oldWidget.tabController.removeListener(_handleTabSelection);
      widget.tabController.addListener(_handleTabSelection);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        conditionallyPlayVideo();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabCubit, List<TabState>>(
      builder: (context, state) {
        final tabs = state;
        final mediaAreas = tabs.map((tab) {
          return tab is VideoTabState
              ? VideoArea(
                  source: tab.source,
                  isMonochrome: widget.showMonochrome,
                  videoController: videoController,
                  onTap: () => player.playOrPause(),
                )
              : ImageArea(
                  source: tab.source,
                  isMonochrome: widget.showMonochrome,
                );
        }).toList();

        final isCurrentlyVideo = _currentTabShowsVideo();

        final imageControls = ImageControls(
          // TODO: implement the rest of these callbacks.
          onTapPageFit: () {},
          onTapBWFilter: widget.onToggleMonochrome,
          onTapColorPicker: () {},
          onTapDetails: () {},
          onTapOpenInNewTab: () {
            final tabCubit = context.read<TabCubit>();
            final currentTab = tabCubit.state[widget.tabController.index];
            tabCubit.addTab(currentTab);
            setState(() {});
          },
          onTapPinOrUnpin: widget.onTogglePinControls,
          monochromeToggled: widget.showMonochrome,
          isPinned: widget.areControlsPinned,
          disableOpenInNewTabOption: widget.tabController.index != 0,
        );

        final playbackControls = VideoControls(player: player, compact: true);
        final videoTimeline = Padding(
          padding: const EdgeInsets.symmetric(horizontal: DefaultSpacing.small),
          child: VideoTimeline(player: player),
        );

        final videoControls = Column(
          mainAxisAlignment: .end,
          crossAxisAlignment: .start,
          children: [
            videoTimeline,
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: playbackControls,
            ),
          ],
        );

        final backAndNext = Row(
          mainAxisAlignment: .spaceBetween,
          crossAxisAlignment: .stretch,
          children: [
            IconButton(
              onPressed: widget.onPrevious,
              icon: IconWithDefaults(
                Symbols.chevron_backward_rounded,
                color: Colors.white,
              ),
              iconSize: 40,
            ),
            IconButton(
              onPressed: widget.onNext,
              icon: IconWithDefaults(
                Symbols.chevron_forward_rounded,
                color: Colors.white,
              ),
              iconSize: 40,
            ),
          ],
        );

        final isPrimaryWidget = widget.tabController.index == 0;

        final actions = <Type, Action<Intent>>{
          if (isPrimaryWidget) PreviousIntent: CallbackAction(onInvoke: (_) => widget.onPrevious()),
          if (isPrimaryWidget) NextIntent: CallbackAction(onInvoke: (_) => widget.onNext()),
          CloseIntent: CallbackAction(onInvoke: (_) => widget.onClose()),
          ToggleMonochromeFilterIntent: CallbackAction(onInvoke: (_) => widget.onToggleMonochrome()),
          PauseOrResumeIntent: CallbackAction(onInvoke: (_) {
            player.playOrPause();
            return;
          },)
        };

        return Actions(
          actions: actions,
          // TODO: figure out how to cleanly restore focus to this widget.
          child: Focus(
            focusNode: widget.focusNode,
            autofocus: true,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: .bottomCenter,
                children: [
                  TabBarView(
                    controller: widget.tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: mediaAreas,
                  ),
                  if (isPrimaryWidget)
                    Center(
                      child: Padding(
                        padding: .symmetric(horizontal: DefaultSpacing.small),
                        child: backAndNext,
                      ),
                    ),
                  Positioned.fill(
                    child: Padding(
                      padding: const .all(8.0),
                      child: Column(
                        mainAxisAlignment: isCurrentlyVideo
                            ? .spaceBetween
                            : .start,
                        crossAxisAlignment: .start,
                        children: [
                          imageControls,
                          if (isCurrentlyVideo)
                            Pinnable(
                              isPinned: widget.areControlsPinned,
                              child: videoControls,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// True if the currently shown tab has a video as its source.
  bool _currentTabShowsVideo() {
    final currentTabIndex = widget.tabController.index;
    return _tabShowsVideo(currentTabIndex);
  }

  /// True if the tab with index [index] has a video as its source.
  bool _tabShowsVideo(int index) {
    final tabs = context.read<TabCubit>().state;
    return tabs[index] is VideoTabState;
  }

  void _saveVideoState(int index, TabState state) {
    context.read<TabCubit>().saveTabState(index, state);
  }

  /// If the currently opened tab's source is a video, make the neccessary setup to play the video.
  Future<void> conditionallyPlayVideo({bool playImmediately = false}) async {
    final currentTabIndex = widget.tabController.index;

    if (_tabShowsVideo(currentTabIndex)) {
      final tabs = context.read<TabCubit>().state;
      final tab = tabs[currentTabIndex] as VideoTabState;
      final playable = Media(
        tab.source.uri.toString(),
        start: tab.passedDuration,
      );

      await player.open(playable, play: tab.isPlaying || playImmediately);
      await player.setVolume(tab.volume);
    }
  }

  void _handleTabSelection() {
    if (!mounted) return;
    if (widget.tabController.indexIsChanging) return;

    final previousIndex = widget.tabController.previousIndex;
    final tabs = context.read<TabCubit>().state;
    final previousTab = tabs[previousIndex];

    if (previousTab is VideoTabState) {
      _saveVideoState(
        previousIndex,
        previousTab.copyWith(
          player.state.position,
          player.state.volume,
          player.state.playing,
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      conditionallyPlayVideo();
    });
    setState(() {});
  }
}
