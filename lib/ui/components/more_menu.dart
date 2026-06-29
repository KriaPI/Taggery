import 'package:flutter/material.dart';

/// Describes an option with an optional shortcut.
class MenuOption {
  const MenuOption({required this.label, this.leadingIcon, this.optionCallback = DoNothingAction.new, this.shortcut});

  final Icon? leadingIcon;
  final String label;
  final VoidCallback optionCallback;
  final SingleActivator? shortcut;
}

/// A button that opens a drop-down menu without submenus.
class MoreMenu extends StatefulWidget {
  const MoreMenu({super.key, required this.options});
  final List<MenuOption> options;

  @override
  State<StatefulWidget> createState() => _MoreMenuState();
}

class _MoreMenuState extends State<MoreMenu> {
  final FocusNode _menuButtonFocusNode = FocusNode(
    debugLabel: "More Menu Button",
  );

  @override
  void dispose() {
    _menuButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      childFocusNode: _menuButtonFocusNode,
      menuChildren: widget.options
          .map((MenuOption element) => MenuItemButton(
            leadingIcon: element.leadingIcon,
            onPressed: element.optionCallback,
            shortcut: element.shortcut,
            child: Text(element.label),
          ))
          .toList(),
      builder: (context, controller, child) => IconButton(
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
        icon: Icon(Icons.more_vert_rounded),
        tooltip: "More Actions",
      ),
    );
  }
}
