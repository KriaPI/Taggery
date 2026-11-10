import 'package:material_ui/material_ui.dart';

enum TextSize { small, medium, large }

class TitleText extends StatelessWidget {
  const new(this.text, {super.key, this.size = .medium});
  final String text;
  final TextSize size;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final styles = [textTheme.titleSmall, textTheme.titleMedium, textTheme.titleLarge]; 

    return Text(text, style: styles[size.index]);
  }
}

class TitleTextOnPrimary extends StatelessWidget {
  const new(this.text, {super.key, this.size = .medium});
  final String text;
  final TextSize size;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final styles = [textTheme.titleSmall, textTheme.titleMedium, textTheme.titleLarge]; 

    return Text(text, style: styles[size.index]!.copyWith(
      color: Theme.of(context).colorScheme.onPrimary
    ));
  }
}


class LabelText extends StatelessWidget {
  const new(this.text, {super.key, this.size = .medium, this.color});
  final String text;
  final TextSize size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final styles = [textTheme.labelSmall, textTheme.labelMedium, textTheme.labelLarge]; 



    return Text(text, style: styles[size.index]!.copyWith(
      color: color ?? Theme.of(context).colorScheme.onSurface
    ));
  }
}

class LabelTextPrimary extends StatelessWidget {
  const new(this.text, {super.key, this.size = .medium});
  final String text;
  final TextSize size;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final styles = [textTheme.labelSmall, textTheme.labelMedium, textTheme.labelLarge]; 

    return Text(text, style: styles[size.index]!.copyWith(
      color: Theme.of(context).colorScheme.primary
    ));
  }
}

class BodyText extends StatelessWidget {
  const new(this.text, {super.key, this.size = .medium, this.color});
  final String text;
  final TextSize size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final styles = [textTheme.bodySmall, textTheme.bodyMedium, textTheme.bodyLarge]; 

    return Text(text, style: styles[size.index]!.copyWith(
      color: color ?? Theme.of(context).colorScheme.onSurface
    ));
  }
}

class DisplayText extends StatelessWidget {
  const new(this.text, {super.key, this.size = .medium, this.color});
  final String text;
  final TextSize size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final styles = [textTheme.displaySmall, textTheme.displayMedium, textTheme.displayLarge]; 

    return Text(text, style: styles[size.index]!.copyWith(
      color: color ?? Theme.of(context).colorScheme.onSurface
    ));
  }
}

class HeadlineText extends StatelessWidget {
  const new(this.text, {super.key, this.size = .medium, this.color});
  final String text;
  final TextSize size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final styles = [textTheme.headlineSmall, textTheme.headlineMedium, textTheme.headlineLarge]; 

    return Text(text, style: styles[size.index]!.copyWith(
      color: color ?? Theme.of(context).colorScheme.onSurface
    ));
  }
}

class TimeStampText extends StatelessWidget {
  const TimeStampText(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }
}