import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taggery/ui/components/misc.dart';
import 'package:taggery/ui/components/text.dart';


enum PageFit { page, height, width }

// TODO: make controls for zoom and rotate do stuff
// TODO: make this widget hidable and animate it becoming just one icon (and then fade it out). 

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
    this.disableOpenInNewTabOption = false,
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
  final bool disableOpenInNewTabOption;
  final bool monochromeToggled;
  final bool isPinned;

  @override
  Widget build(BuildContext context) {
    final children = [
      IconTappable(
        tooltip: "Adjust zoom",
        icon: Symbols.zoom_in,
        label: "100 %",
        onPressed: () {},
      ),
      IconTappable(
        tooltip: "Adjust rotation",
        icon: Symbols.rotate_right,
        label: "0.0 °",
        onPressed: () {},
      ),
      IconTappable(
        tooltip: ["Fit to page", "Fit to height", "Fit to width"][fit.index],
        icon: [
          Symbols.fit_page_rounded,
          Symbols.fit_page_height_rounded,
          Symbols.fit_page_width_rounded,
        ][fit.index],
        label: ["Fit page", "Fit height", "Fit width"][fit.index],
        onPressed: onTapPageFit,
      ),
      VerticalDivider(),
      IconToggle(
        tooltip: "Toggle monochrome filter",
        icon: Symbols.filter_b_and_w_rounded,
        isSelected: monochromeToggled,
        onPressed: onTapBWFilter,
      ),
      IconTappable(
        tooltip: "Color picker",
        icon: Icons.colorize_rounded,
        onPressed: onTapColorPicker,
      ),
      VerticalDivider(),
      if (!disableOpenInNewTabOption)
        IconTappable(
          tooltip: "Open in new tab",
          icon: Symbols.open_in_new_rounded,
          onPressed: onTapOpenInNewTab,
        ),
      IconToggle(
        tooltip: isPinned ? "Hide overlays" : "Show overlays",
        selectedIcon: Symbols.fullscreen_rounded,
        icon: Symbols.fullscreen_exit_rounded,
        isSelected: isPinned,
        onPressed: onTapPinOrUnpin,
      ),
      IconTappable(
        tooltip: isPinned ? "Hide overlays" : "Show overlays",
        icon: Symbols.more_horiz,
        onPressed: onTapPinOrUnpin,
      ),
    ];

    final color = Theme.of(context).colorScheme.surface;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const .symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: .min,
        mainAxisAlignment: .start,
        spacing: DefaultSpacing.xs,
        children: children,
      ),
    );
  }
}

/// A tappable icon that acts as a toggle.
///
/// Changes the icon to be filled when selected or changes it to be [selectedIcon] if it is non-null.
class IconToggle extends StatelessWidget {
  const new({
    super.key,
    required this.icon,
    this.selectedIcon,
    required this.isSelected,
    required this.onPressed,
    this.tooltip,
  });
  final IconData icon;
  final IconData? selectedIcon;
  final bool isSelected;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      width: 48,
      child: GestureDetector(
        onTap: onPressed,
        child: IconWithDefaults(
          isSelected && selectedIcon != null ? selectedIcon : icon,
          filled: isSelected && selectedIcon == null,
        ),
      ),
    );

    return tooltip != null
        ? Tooltip(message: tooltip, child: content)
        : content;
  }
}

/// A tappable icon that acts like a button, but without any visual effects.
class IconTappable extends StatelessWidget {
  const new({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.tooltip,
  });
  final IconData icon;
  final String? label;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final content = ConstrainedBox(
      constraints: BoxConstraints(minWidth: 48),
      child: GestureDetector(
        onTap: onPressed,
        child: label == null
            ? IconWithDefaults(icon)
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DefaultSpacing.xs,
                ),
                child: Row(
                  spacing: DefaultSpacing.small,
                  children: [
                    IconWithDefaults(icon),
                    LabelText(label!, size: .large),
                  ],
                ),
              ),
      ),
    );

    return tooltip != null
        ? Tooltip(message: tooltip, child: content)
        : content;
  }
}