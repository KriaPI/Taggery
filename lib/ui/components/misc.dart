import 'package:material_ui/material_ui.dart';

class DefaultSpacing {
  DefaultSpacing._(); // Prevents instantiation

  static const double none = 0.0;
  /// 2 pts
  static const double xxs = 2.0;
  /// 4 pts
  static const double xs = 4.0;
  /// 8 pts
  static const double small = 8.0;
  /// 16 pts
  static const double medium = 16.0;
  /// 24 pts
  static const double large = 24.0;
  /// 32 pts
  static const double extraLarge = 32.0;
  /// 48 pts
  static const double xxl = 48.0;
}

/// An Icon widget with default weight and optical size.
class IconWithDefaults extends StatelessWidget {
  const IconWithDefaults(
    this.icon, {
    super.key,
    this.filled = false,
    this.color,
    this.size
  });
  final IconData? icon;
  final bool filled;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      weight: 400,
      opticalSize: size ?? 24,
      fill: filled ? 1.0 : 0.0,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }
}