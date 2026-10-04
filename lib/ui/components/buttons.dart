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
    return IconButton.filledTonal(
      tooltip: tooltip,
      style: ButtonStyle(
        backgroundColor: .all(Theme.of(context).colorScheme.surfaceContainer),
        minimumSize: .all(Size(56.0, 56.0)),
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
      onPressed: onPressed,
      icon: icon,
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

/// Allows for a label and an icon.
class TonalToggleButton extends StatelessWidget {
  const TonalToggleButton({
    super.key,
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.selectedIcon,
    required this.onPressed,
    this.tooltip,
    this.selectedTooltip,
    this.isNarrow = false,
  });

  const TonalToggleButton.narrow({
    super.key,
    required this.isSelected,
    required this.icon,
    required this.label,
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
  final String label;
  final Widget selectedIcon;
  final String? tooltip;
  final String? selectedTooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton.tonalIcon(
      icon: isSelected ? selectedIcon : icon,
      label: Text(label),
      style: ButtonStyle(
        padding: .all(const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0)),
        foregroundColor: .all(colorScheme.onSurfaceVariant),
        backgroundColor: .all(colorScheme.surfaceContainer),
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
      onPressed: onPressed,
    );
  }
}
