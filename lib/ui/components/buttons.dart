import 'package:flutter/material.dart';

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



class ToggleIconButton extends StatelessWidget {
  const ToggleIconButton({
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
      isSelected: true,
      onPressed: onPressed,
      icon: icon,
    );
  }
}