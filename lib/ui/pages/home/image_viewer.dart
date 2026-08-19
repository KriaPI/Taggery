import 'dart:io';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:taggery/logic/tabs.dart';
import 'package:taggery/ui/components/containers.dart';
import 'package:taggery/ui/components/toolbar.dart';
import 'package:taggery/ui/configuration/default_keybindings.dart';

// TODO: add indicators/controls for zoom and rotation.

// dart format off
const ColorFilter grayscaleFilter = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0, 
  0.2126, 0.7152, 0.0722, 0, 0, 
  0, 0, 0, 1, 0,
]);
// dart format on

/// This widget contains the header for the viewer and the viewer itself as a child.
///
/// The header includes the close button, the tab bar, and the maximize/minimize button. This widget manages
/// the state of the tabs and shortcuts map.
///
class ImageViewerContainer extends StatefulWidget {
  const ImageViewerContainer({
    super.key,
    required this.focusNode,
    required this.isInFullview,
    required this.primaryIndex,
    required this.onPrevious,
    required this.onNext,
    required this.onClose,
    required this.onToggleFullview,
  });

  final FocusNode focusNode;
  final bool isInFullview;

  /// The index of the gallery entry shown in the first tab. This is used to compare in didWidgetUpdate().
  final int primaryIndex;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onClose;

  /// The callback that should be called to turn on full view of the viewer and turn of split view between the viewer and gallery grid, and vice versa.
  final VoidCallback onToggleFullview;

  @override
  State<StatefulWidget> createState() => ImageViewerContainerState();
}

class ImageViewerContainerState extends State<ImageViewerContainer>
    with TickerProviderStateMixin {
  late TabController _tabController;

  /// The map of callbacks called to execute keyboard shortcuts.
  late Map<Type, Action<Intent>> viewerActions;

  /// Whether or not the controls for the viewer should be shown at all times, or only shown when the user hovers over
  /// the space they normally occupy.
  bool _pinControls = true;

  /// True if the viewer's media content should be should in black-and-white.
  bool _isMonochrome = false;

  @override
  Widget build(BuildContext context) {
    // TODO: figure out how to add pause/play as a keyboard shortcut.
    return Actions(
      actions: viewerActions,
      child: GestureDetector(
        onTap: () {
          widget.focusNode.requestFocus();
        },
        child: Focus(
          autofocus: true,
          focusNode: widget.focusNode,
          child: Column(
            spacing: 4.0,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 16.0,
                children: [
                  IconButton(
                    icon: Icon(Icons.close_rounded),
                    onPressed: widget.onClose,
                    tooltip: "Close",
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: BlocConsumer<TabCubit, List<TabState>>(
                        listener: (context, state) {
                          // Update the length of the tab controller to match the cubit.
                          // The length is +1 because there is always an additional tab open
                          // that allows the user to navigate between gallery items (images/videos).
                          _updateTabController(state.length);
                        },
                        builder: (context, tabs) => ViewerTabBar(
                          tabController: _tabController,
                          tabTitles: tabs
                              .map((entry) => entry.content.name)
                              .toList(),
                          onCloseTab: (index) {
                            context.read<TabCubit>().closeTab(index);
                          },
                        ),
                      ),
                    ),
                  ),
                  widget.isInFullview
                      ? IconButton(
                          onPressed: widget.onToggleFullview,
                          icon: Icon(Icons.close_fullscreen_rounded),
                          tooltip: "Minimize",
                        )
                      : IconButton(
                          onPressed: widget.onToggleFullview,
                          icon: Icon(Icons.open_in_full_rounded),
                          tooltip: "Maximize",
                        ),
                ],
              ),
              Expanded(
                child: BlocBuilder<TabCubit, List<TabState>>(
                  builder: (context, tabs) => ImageViewer(
                    tabController: _tabController,
                    onPrevious: widget.onPrevious,
                    onNext: widget.onNext,
                    onClose: widget.onClose,
                    onTogglePinControls: togglePinControls,
                    onToggleMonochrome: toggleMonochrome,
                    areControlsPinned: _pinControls,
                    showMonochrome: _isMonochrome,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    int tabCount = context.read<TabCubit>().state.length;
    _tabController = TabController(
      length: tabCount,
      vsync: this,
      animationDuration: Duration.zero,
    );

    viewerActions = {
      if (_tabController.index == 0) ...{
        PreviousIntent: CallbackAction<PreviousIntent>(
          onInvoke: (intent) => widget.onPrevious(),
        ),
        NextIntent: CallbackAction<NextIntent>(
          onInvoke: (intent) => widget.onNext(),
        ),
      },
      CloseIntent: CallbackAction<CloseIntent>(
        onInvoke: (intent) => widget.onClose(),
      ),
    };

    _tabController.addListener(_updateShortCuts);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.removeListener(_updateShortCuts);
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

  /// Update the map of shortcut actions. Disables the left and right arrow actions
  /// if the any other tab than the first is being viewed.
  void _updateShortCuts() {
    final newViewerActions = {
      if (_tabController.index == 0) ...{
        PreviousIntent: CallbackAction<PreviousIntent>(
          onInvoke: (intent) => widget.onPrevious(),
        ),
        NextIntent: CallbackAction<NextIntent>(
          onInvoke: (intent) => widget.onNext(),
        ),
      },
      CloseIntent: CallbackAction<CloseIntent>(
        onInvoke: (intent) => widget.onClose(),
      ),
    };

    setState(() {
      viewerActions = newViewerActions;
    });
  }

  /// Get the index of the tab that was opened.
  int _getNewTabIndex(int newLength) {
    return newLength >= 2 ? 1 : 0;
  }

  /// Update the length and currently viewed index of the tab controller.
  void _updateTabController(int newLength) {
    if (_tabController.length == newLength) return;

    final newCurrentIndex = _getNewTabIndex(newLength);
    _tabController.removeListener(_updateShortCuts);
    _tabController.dispose();

    setState(() {
      _tabController = TabController(
        length: newLength,
        vsync: this,
        animationDuration: Duration.zero,
        initialIndex: newCurrentIndex,
      );
    });

    _tabController.addListener(_updateShortCuts);
  }

  void toggleMonochrome() {
    setState(() {
      _isMonochrome = !_isMonochrome;
    });
  }

  void togglePinControls() {
    setState(() {
      _pinControls = !_pinControls;
    });
  }
}

/// A scrollable tab bar with separators between tabs.
///
/// The separators dissappear whenever the user hovers over or selects a tab where there would normally be
/// separators next to it.
class ViewerTabBar extends StatefulWidget {
  const ViewerTabBar({
    super.key,
    required this.tabController,
    required this.tabTitles,
    required this.onCloseTab,
  });
  final TabController tabController;
  final List<String> tabTitles;

  /// A callback to call when a tab is closed. This should update the list that [tabTitles] is derived from.
  final void Function(int index) onCloseTab;

  @override
  State<ViewerTabBar> createState() => _ViewerTabBarState();
}

class _ViewerTabBarState extends State<ViewerTabBar> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.tabController,
      builder: (context, _) {
        final selectedIndex = widget.tabController.index;

        return ListView.separated(
          scrollDirection: .horizontal,
          itemBuilder: (context, index) {
            return ViewerTab(
              name: widget.tabTitles[index],
              onTap: () {
                widget.tabController.index = index;
              },
              onHover: (isHovered) {
                setState(() {
                  _hoveredIndex = isHovered ? index : null;
                });
              },
              onClose: () {
                widget.onCloseTab(index - 1);
              },
              isClosable: index != 0,
              isSelected: index == selectedIndex,
              isHovered: index == _hoveredIndex,
            );
          },
          separatorBuilder: (context, index) {
            final isAdjacentToSelected =
                index == selectedIndex || index + 1 == selectedIndex;
            final isAdjacentToHovered =
                index == _hoveredIndex || index + 1 == _hoveredIndex;

            final isHidden = isAdjacentToSelected || isAdjacentToHovered;

            final separatorColor = Theme.of(context).colorScheme.outlineVariant;

            return SizedBox(
              width: 18,
              child: Center(
                child: AnimatedOpacity(
                  duration: Durations.short3,
                  curve: Curves.easeOut,
                  opacity: isHidden ? 0.0 : 1.0,
                  child: Container(
                    width: 2,
                    height: 16,
                    decoration: BoxDecoration(
                      color: separatorColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            );
          },
          itemCount: widget.tabTitles.length,
        );
      },
    );
  }
}

/// A tab in the viewer's tab bar.
///
/// The tab changes color when the user hovers over it or when it is selected.
class ViewerTab extends StatelessWidget {
  const ViewerTab({
    super.key,
    required this.name,
    required this.onTap,
    required this.onHover,
    required this.onClose,
    required this.isClosable,
    this.isSelected = false,
    this.isHovered = false,
  });

  /// The text that will appear in the tab.
  final String name;

  /// The function to call when this tab is pressed. This should update the tab bar's currently selected tab.
  final VoidCallback onTap;

  final ValueChanged<bool> onHover;

  /// The function to call when the tab's close button is pressed.
  final VoidCallback onClose;

  final bool isClosable;
  final bool isSelected;
  final bool isHovered;

  @override
  Widget build(BuildContext context) {
    Widget content = Text(name, overflow: .fade, maxLines: 1, softWrap: false);
    content = isClosable
        ? Row(
            mainAxisAlignment: .spaceBetween,
            crossAxisAlignment: .center,
            mainAxisSize: .min,
            spacing: 8,
            children: [
              Expanded(child: content),
              SizedBox(
                width: 20,
                height: 20,
                child: IconButton(
                  iconSize: 14,
                  padding: .zero,
                  onPressed: onClose,
                  icon: Icon(Icons.close),
                ),
              ),
            ],
          )
        : content;

    final colorScheme = Theme.of(context).colorScheme;

    final backgroundColor = isSelected
        ? colorScheme.surfaceContainer
        : (isHovered
              ? colorScheme.surfaceContainer.withValues(alpha: 0.7)
              : Colors.transparent);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onHover: onHover,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 160),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: content,
        ),
      ),
    );
  }
}

/// The widget containing the image and the media controls.
class ImageViewer extends StatefulWidget {
  const ImageViewer({
    super.key,
    required this.tabController,
    required this.onPrevious,
    required this.onNext,
    required this.onClose,
    required this.onTogglePinControls,
    required this.onToggleMonochrome,
    required this.areControlsPinned,
    required this.showMonochrome,
  });
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
          onTapPageFit: () {},
          onTapBWFilter: widget.onToggleMonochrome,
          onTapColorPicker: () {},
          onTapDetails: () {},
          onTapOpenInNewTab: () {},
          onTapPinOrUnpin: () {
            widget.onTogglePinControls();
            setState(() {});
          },
          monochromeToggled: widget.showMonochrome,
          isPinned: widget.areControlsPinned,
          disableFitOption: isCurrentlyVideo,
          compact: isCurrentlyVideo,
        );
        final videoControls = VideoControls(
          player: player,
          compact: isCurrentlyVideo,
        );
        final videoTimeline = VideoTimeline(player: player);

        final controls = isCurrentlyVideo
            ? Column(
                mainAxisAlignment: .end,
                children: [
                  videoTimeline,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [videoControls, imageControls],
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: imageControls,
              );

        return Stack(
          alignment: .bottomCenter,
          children: [
            TabBarView(
              controller: widget.tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: mediaAreas,
            ),
            Column(
              mainAxisSize: .min,
              children: [
                Pinnable(isPinned: widget.areControlsPinned, child: controls),
              ],
            ),
          ],
        );
      },
    );
  }

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
  void didUpdateWidget(covariant ImageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle tabController replacements when length changes in parent.
    // We check for equality since the tabController is replaced when the length changes.
    if (oldWidget.tabController != widget.tabController) {
      oldWidget.tabController.removeListener(_handleTabSelection);
      widget.tabController.addListener(_handleTabSelection);
    }

    // This must be called in order for videos to get loaded properly.
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_handleTabSelection);
    player.dispose();
    super.dispose();
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

      await player.open(playable, play: playImmediately);
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
        previousTab.copyWith(player.state.position, player.state.volume),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      player.setPlaylistMode(.loop);
      conditionallyPlayVideo(playImmediately: true);
    });
    setState(() {});
  }
}

enum PageFit { page, height, width }

/// A toolbar containing controls for image viewing.
class ImageControls extends StatelessWidget {
  const ImageControls({
    super.key,
    required this.onTapPageFit,
    required this.onTapBWFilter,
    required this.onTapColorPicker,
    required this.onTapDetails,
    required this.onTapOpenInNewTab,
    required this.onTapPinOrUnpin,
    required this.monochromeToggled,
    required this.isPinned,
    this.fit = PageFit.page,
    this.disableFitOption = false,
    this.compact = false,
  });
  final bool compact;
  final VoidCallback onTapPageFit;
  final VoidCallback onTapBWFilter;
  final VoidCallback onTapColorPicker;
  final VoidCallback onTapDetails;
  final VoidCallback onTapOpenInNewTab;
  final VoidCallback onTapPinOrUnpin;

  final PageFit fit;
  final bool disableFitOption;
  final bool monochromeToggled;
  final bool isPinned;

  @override
  Widget build(BuildContext context) {
    final children = [
      if (!disableFitOption) ...[
        IconButton(
          tooltip: ["Fit to page", "Fit to height", "Fit to width"][fit.index],
          icon: Icon(
            [
              Symbols.fit_page_rounded,
              Symbols.fit_page_height_rounded,
              Symbols.fit_page_width_rounded,
            ][fit.index],
          ),
          onPressed: onTapPageFit,
        ),
      ],
      IconButton(
        tooltip: "Toggle monochrome filter",
        icon: Icon(Icons.filter_b_and_w_outlined),
        selectedIcon: Icon(Icons.filter_b_and_w_rounded),
        isSelected: monochromeToggled,
        onPressed: onTapBWFilter,
      ),
      IconButton(
        tooltip: "Color picker",
        icon: Icon(Icons.colorize_rounded),
        onPressed: onTapColorPicker,
      ),
      IconButton(
        tooltip: "Details",
        icon: Icon(Symbols.info_i_rounded),
        onPressed: onTapDetails,
      ),
      IconButton(
        tooltip: "Open in new tab",
        icon: Icon(Icons.open_in_new_rounded),
        onPressed: onTapOpenInNewTab,
      ),
      IconButton(
        tooltip: isPinned ? "Unpin" : "Pin",
        selectedIcon: Icon(Icons.arrow_drop_down_rounded),
        icon: Icon(Icons.arrow_drop_up_rounded),
        isSelected: isPinned,
        onPressed: onTapPinOrUnpin,
      ),
    ];

    return compact
        ? FloatingToolBar.compact(children: children)
        : FloatingToolBar(children: children);
  }
}

/// A toolbar containing controls for video playback.
class VideoControls extends StatelessWidget {
  const VideoControls({super.key, required this.player, this.compact = false});
  final bool compact;
  final Player player;

  @override
  Widget build(BuildContext context) {
    final children = [
      StreamBuilder(
        stream: player.stream.playing,
        builder: (context, snapshot) {
          final isPlaying = snapshot.hasData ? snapshot.data! : false;

          return IconButton(
            tooltip: !isPlaying ? "Resume" : "Pause",
            icon: Icon(
              !isPlaying ? Icons.play_arrow_rounded : Icons.pause_rounded,
            ),
            onPressed: player.playOrPause,
          );
        },
      ),
      StreamBuilder(
        stream: player.stream.volume,
        builder: (context, snapshot) {
          final isMuted = snapshot.hasData ? snapshot.data! == 0 : false;

          return IconButton(
            tooltip: isMuted ? "Unmute" : "Mute",
            icon: Icon(
              isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            ),
            onPressed: () {
              isMuted ? player.setVolume(100.0) : player.setVolume(0);
            },
          );
        },
      ),
    ];

    return compact
        ? FloatingToolBar.compact(children: children)
        : FloatingToolBar(children: children);
  }
}

///
class VideoTimeline extends StatefulWidget {
  const VideoTimeline({super.key, required this.player});
  final Player player;

  @override
  State<VideoTimeline> createState() => _VideoTimelineState();
}

class _VideoTimelineState extends State<VideoTimeline> {
  bool wasPausedBeforeChange = false;

  // TODO: fix issue where timeline is set to zero initially and then jumps to correct 
  // position when switching tabs.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.player.stream.position,
      builder: (context, snapshot) {
        final value = snapshot.data == null
            ? 0.0
            : snapshot.data!.inMilliseconds / 1000.0;
        final videoDuration = widget.player.state.duration;
        final maxValue = videoDuration == Duration.zero
            ? 1.0
            : videoDuration.inMilliseconds / 1000.0;

        return SizedBox(
          height: 24,
          width: null,
          child: Slider(
            value: value,
            max: maxValue,
            onChangeStart: (value) {
              wasPausedBeforeChange = widget.player.state.playing;
              widget.player.pause();
            },
            onChangeEnd: (value) {
              if (wasPausedBeforeChange) {
                widget.player.play();
              }
            },
            onChanged: (value) {
              final duration = Duration(milliseconds: (value * 1000).round());
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.player.seek(duration);
              });
            },
          ),
        );
      },
    );
  }
}

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
                      gaplessPlayback: false,
                      fit: .contain,
                    ),
                  )
                : Image.file(
                    widget.source,
                    gaplessPlayback: false,
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
