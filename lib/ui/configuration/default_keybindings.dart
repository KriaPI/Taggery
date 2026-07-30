import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

class PreviousIntent extends Intent {
  const PreviousIntent();
}

class NextIntent extends Intent {
  const NextIntent();
}

class CloseIntent extends Intent {
  const CloseIntent();
}

class ToggleMonochromeFilterIntent extends Intent {
  const ToggleMonochromeFilterIntent();
}

class PauseOrResumeIntent extends Intent {
  const PauseOrResumeIntent();
}

const Map<ShortcutActivator, Intent> keybindings = {
  SingleActivator(LogicalKeyboardKey.arrowLeft): PreviousIntent(),
  SingleActivator(LogicalKeyboardKey.arrowRight): NextIntent(),
  SingleActivator(LogicalKeyboardKey.escape): CloseIntent(),
  SingleActivator(LogicalKeyboardKey.keyB): ToggleMonochromeFilterIntent(),
  SingleActivator(LogicalKeyboardKey.space): PauseOrResumeIntent(),
};
