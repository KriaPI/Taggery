import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taggery/models/gallery.dart';
import 'package:taggery/logic/tabs.dart';
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
    required this.primaryTab,
    required this.onPrevious,
    required this.onNext,
    required this.onClose,
    required this.onToggleFullview,
  });

  final FocusNode focusNode;
  final bool isInFullview;

  /// The tab shown when first opening the viewer.
  final GalleryEntry primaryTab;
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
                      child: BlocConsumer<TabCubit, List<GalleryEntry>>(
                        listener: (context, state) {
                          // Update the length of the tab controller to match the cubit.
                          // The length is +1 because there is always an additional tab open
                          // that allows the user to navigate between gallery items (images/videos).
                          _updateTabController(state.length + 1);
                        },
                        builder: (context, tabs) => ViewerTabBar(
                          tabController: _tabController,
                          tabTitles: [
                            widget.primaryTab.name,
                            ...tabs.map((entry) => entry.name),
                          ],
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
                child: BlocBuilder<TabCubit, List<GalleryEntry>>(
                  builder: (context, tabs) => ImageViewer(
                    primaryTab: widget.primaryTab,
                    otherTabs: tabs,
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
    viewerActions = {
      PreviousIntent: CallbackAction<PreviousIntent>(
        onInvoke: (intent) => widget.onPrevious(),
      ),
      NextIntent: CallbackAction<NextIntent>(
        onInvoke: (intent) => widget.onNext(),
      ),
      CloseIntent: CallbackAction<CloseIntent>(
        onInvoke: (intent) => widget.onClose(),
      ),
    };

    int tabCount = context.read<TabCubit>().state.length;
    _tabController = TabController(
      length: tabCount + 1,
      vsync: this,
      animationDuration: Duration.zero,
    );
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
    if (oldWidget.primaryTab != widget.primaryTab) {
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
    required this.primaryTab,
    required this.otherTabs,
    required this.tabController,
    required this.onPrevious,
    required this.onNext,
    required this.onClose,
    required this.onTogglePinControls,
    required this.onToggleMonochrome,
    required this.areControlsPinned,
    required this.showMonochrome,
  });
  final GalleryEntry primaryTab;
  final List<GalleryEntry> otherTabs;
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
  @override
  Widget build(BuildContext context) {
    final tabs = [widget.primaryTab, ...widget.otherTabs];
    final mediaAreas = tabs.map((tab) {
      return tab.isVideo 
        ? SizedBox()
        : ImageArea(source: tab.source, isMonochrome: widget.showMonochrome);
    }).toList();

    return Stack(
      alignment: .bottomCenter,
      children: [
        TabBarView(
          controller: widget.tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: mediaAreas
        ),
        PinnableFloatingToolbar(
          isPinned: widget.areControlsPinned,
          onTogglePin: widget.onTogglePinControls,
          children: [
            if (widget.tabController.index == 0) ...[
              IconButton(
                tooltip: "previous (Left arrow)",
                onPressed: widget.onPrevious,
                icon: Icon(Icons.chevron_left_rounded),
              ),
              IconButton(
                tooltip: "next (Right arrow)",
                onPressed: widget.onNext,
                icon: Icon(Icons.chevron_right_rounded),
              ),
            ],
            IconButton(
              tooltip: "Details",
              icon: Icon(Icons.info_outline_rounded),
              onPressed: () {},
            ),
            IconButton(
              tooltip: widget.showMonochrome
                  ? "View in color"
                  : "View in monochrome",
              isSelected: widget.showMonochrome,
              onPressed: widget.onToggleMonochrome,
              icon: Icon(Icons.filter_b_and_w_outlined),
              selectedIcon: Icon(Icons.filter_b_and_w),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    // Listen to tab selection changes to rebuild the toolbar immediately.
    widget.tabController.addListener(_handleTabSelection);
  }

  @override
  void didUpdateWidget(covariant ImageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle tabController replacements when length changes in parent.
    if (oldWidget.tabController != widget.tabController) {
      oldWidget.tabController.removeListener(_handleTabSelection);
      widget.tabController.addListener(_handleTabSelection);
    }
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_handleTabSelection);
    super.dispose();
  }

  void _handleTabSelection() {
    if (mounted) {
      setState(() {});
    }
  }
}

/// A pinnable/unpinnable version of the floating toolbar component of Material Design 3 Expressive.
///
/// This widget has a button that allows the container to be pinned (default) or unpinned.
/// If the widget is unpinned, then it will slide down and out of view when the mouse is
/// not in its region.
class PinnableFloatingToolbar extends StatefulWidget {
  const PinnableFloatingToolbar({
    super.key,
    required this.isPinned,
    required this.onTogglePin,
    required this.children,
  });

  /// Decides whether or not this widget should be pinned. This state should be stored in an attribute belonging to a parent widget.
  final bool isPinned;

  /// The callback to call when the assigning a new value to the parent's attribute that [isPinned] derives its value from.
  final VoidCallback onTogglePin;

  /// Widgets that should be placed to either side of the pin button. The widgets of the first half of the list will be
  /// placed to the left of the pin button, and those of the second half will be placed to the right.
  final List<Widget> children;

  @override
  State<StatefulWidget> createState() => PinnableFloatingToolbarState();
}

class PinnableFloatingToolbarState extends State<PinnableFloatingToolbar> {
  bool _isShown = true;

  @override
  Widget build(BuildContext context) {
    final hideButton = IconButton(
      isSelected: widget.isPinned,
      tooltip: widget.isPinned ? "Unpin" : "Pin",
      onPressed: widget.onTogglePin,
      icon: Icon(Icons.push_pin_outlined),
      selectedIcon: Icon(Icons.push_pin),
    );

    final int middle = widget.children.length ~/ 2;

    final buttons = [
      ...widget.children.sublist(0, middle),
      hideButton,
      ...widget.children.sublist(middle),
    ];

    final controls = SizedBox(
      height: 64,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisSize: .min,
            mainAxisAlignment: .center,
            spacing: 4.0,
            children: buttons,
          ),
        ),
      ),
    );

    return widget.isPinned
        ? controls
        : MouseRegion(
            onEnter: (event) {
              setState(() {
                _isShown = true;
              });
            },
            onExit: (event) {
              setState(() {
                _isShown = false;
              });
            },
            child: ClipRect(
              child: AnimatedSlide(
                offset: _isShown ? Offset.zero : const Offset(0, 1.0),
                curve: Curves.easeInOut,
                duration: Durations.short3,
                child: AnimatedOpacity(
                  duration: Durations.short3,
                  curve: Curves.easeInOut,
                  opacity: _isShown ? 1.0 : 0.0,
                  child: controls,
                ),
              ),
            ),
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
