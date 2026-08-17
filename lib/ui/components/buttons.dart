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
    return IconButton.filledTonal(
      style: ButtonStyle(
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
