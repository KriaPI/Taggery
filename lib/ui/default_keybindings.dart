import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

class MoveToPreviousIntent extends Intent {
  const MoveToPreviousIntent();
}

class MoveToNextIntent extends Intent {
  const MoveToNextIntent();
}

class CloseIntent extends Intent {
  const CloseIntent();
}

class PauseOrResumeIntent extends Intent {
  const PauseOrResumeIntent();
}

const Map<ShortcutActivator, Intent> keybindings = {
  SingleActivator(LogicalKeyboardKey.arrowLeft): MoveToPreviousIntent(),
  SingleActivator(LogicalKeyboardKey.arrowRight): MoveToNextIntent(),
  SingleActivator(LogicalKeyboardKey.escape): CloseIntent(),
  SingleActivator(LogicalKeyboardKey.space): PauseOrResumeIntent(),
};
