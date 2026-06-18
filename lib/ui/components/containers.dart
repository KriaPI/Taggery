import 'package:flutter/material.dart';

// TODO: document

// Pane is the container for other widgets with the lowest elevation. This means that it sits directly on
// the background and should be used for larger collections of widgets.
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

