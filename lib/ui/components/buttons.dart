import 'package:material_ui/material_ui.dart';

/// A square tonal icon button following the Material design 3 expressive design system.
///
/// The default size is M.
class SquareTonalIconButton extends StatelessWidget {
  const SquareTonalIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });
  final VoidCallback onPressed;
  final Widget icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: tooltip,
      style: IconButton.styleFrom(
        foregroundColor: (colorScheme.onSurfaceVariant),
        backgroundColor: (colorScheme.surfaceContainer),
        minimumSize: Size(56.0, 56.0),
        shape: RoundedRectangleBorder(borderRadius: .all(.circular(16.0))),
      ),
      onPressed: onPressed,
      icon: icon,
    );
  }
}

/// Allows for a label and an icon.
class SquareTonalTextButton extends StatelessWidget {
  const SquareTonalTextButton({
    super.key,
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.selectedIcon,
    required this.onPressed,
    this.tooltip,
    this.selectedTooltip,
  });

  final bool isSelected;
  final VoidCallback onPressed;
  final Widget icon;
  final String label;
  final Widget selectedIcon;
  final String? tooltip;
  final String? selectedTooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.titleMedium;

    return SizedBox(
      height: 56,
      child: TextButton.icon(
        icon: isSelected ? selectedIcon : icon,
        label: Text(label),
        style: TextButton.styleFrom(
          iconSize: 24,
          textStyle: textStyle,
          padding: .symmetric(horizontal: 24),
          foregroundColor: (colorScheme.onSurfaceVariant),
          backgroundColor: (colorScheme.surfaceContainer),
          minimumSize: Size(56.0, 56.0),
          shape: RoundedRectangleBorder(borderRadius: .all(.circular(16.0))),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class TonalToggleIconButton extends StatelessWidget {
  const TonalToggleIconButton({
    super.key,
    required this.isSelected,
    required this.icon,
    required this.selectedIcon,
    required this.onPressed,
    this.tooltip,
    this.selectedTooltip,
    this.isNarrow = false,
  });

  const TonalToggleIconButton.narrow({
    super.key,
    required this.isSelected,
    required this.icon,
    required this.selectedIcon,
    required this.onPressed,
    this.tooltip,
    this.selectedTooltip,
    this.isNarrow = true,
  });

  final bool isNarrow;
  final bool isSelected;
  final VoidCallback onPressed;
  final Widget icon;
  final Widget selectedIcon;
  final String? tooltip;
  final String? selectedTooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: ButtonStyle(
        backgroundColor: .all(Theme.of(context).colorScheme.surfaceContainer),
        minimumSize: WidgetStatePropertyAll(Size(isNarrow ? 48.0 : 56.0, 56.0)),
        shape: WidgetStateProperty.fromMap(
          <WidgetStatesConstraint, OutlinedBorder>{
            WidgetState.pressed: RoundedRectangleBorder(
              borderRadius: .all(.circular(12.0)),
            ),
            WidgetState.any: RoundedRectangleBorder(
              borderRadius: .all(.circular(16.0)),
            ),
          },
        ),
      ),
      isSelected: isSelected,
      tooltip: isSelected ? selectedTooltip : tooltip,
      onPressed: onPressed,
      icon: icon,
      selectedIcon: selectedIcon,
    );
  }
}
