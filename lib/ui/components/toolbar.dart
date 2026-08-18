import 'package:material_ui/material_ui.dart';


/// The floating toolbar component of Material Design 3 Expressive.
///
/// This widget has a button that allows the container to be pinned (default) or unpinned.
/// If the widget is unpinned, then it will slide down and out of view when the mouse is
/// not in its region.
class FloatingToolBar extends StatelessWidget {
  const FloatingToolBar({
    super.key,
    required this.children,
    this.height = 64
  });

  /// A toolbar that takes slightly less vertical space (48 pts compared to 64 pts).
  const FloatingToolBar.compact({
    super.key,
    required this.children,
    this.height = 48
  });

  /// The widgets that are placed in the toolbar. 
  final List<Widget> children;
  /// The toolbar's height.
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
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
            children: children,
          ),
        ),
      ),
    );
  }
}