import 'package:material_ui/material_ui.dart';

/// Pane is the container for other widgets with the lowest elevation. 
/// 
/// This means that it sits directly on the background and should be used for larger collections of widgets.
class Pane extends StatelessWidget {
  const Pane({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: child,
    );
  }
}

/// A widget that can be unpinned and hidden when not hovered over.
///
/// This widget builds [child] regularly when [isPinned] is true, but otherwise
/// shows [child] only when the widget is hovered over.
class Pinnable extends StatefulWidget {
  const Pinnable({
    super.key,
    required this.isPinned,
    required this.child,
  });

  /// Decides whether or not this widget should be pinned. This state should be stored in an attribute belonging to a parent widget.
  final bool isPinned;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _PinnableState();
}

class _PinnableState extends State<Pinnable> {
  bool _isShown = true;

  @override
  Widget build(BuildContext context) {
    return widget.isPinned
        ? widget.child
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
                  child: widget.child,
                ),
              ),
            ),
          );
  }
}