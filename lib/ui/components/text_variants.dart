import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
    const TitleText(this.text, {super.key});
    final String text;

    @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium);
  }
}

class BodyText extends StatelessWidget {
    const BodyText(this.text, {super.key, });
    final String text;

    @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.bodyMedium);
  }
}