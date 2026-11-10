import 'package:material_ui/material_ui.dart';

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

  final String name;
  final VoidCallback onTap;
  final ValueChanged<bool> onHover;
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

    return Tooltip(
      message: name,
      child: Material(
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
      ),
    );
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
                widget.onCloseTab(index);
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