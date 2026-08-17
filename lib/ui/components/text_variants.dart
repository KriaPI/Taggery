import 'package:flutter/material.dart';

class TitleTextSmall extends StatelessWidget {
  const TitleTextSmall(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleSmall);
  }
}

class TitleTextMedium extends StatelessWidget {
  const TitleTextMedium(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium);
  }
}

class TitleTextLarge extends StatelessWidget {
  const TitleTextLarge(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleLarge);
  }
}



class BodyText extends StatelessWidget {
  const BodyText(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.bodyMedium);
  }
}
