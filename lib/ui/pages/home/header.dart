import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taggery/ui/components/buttons.dart';
import 'package:taggery/ui/pages/home/search_bar.dart';

class PageHeader extends StatefulWidget {
  const PageHeader({super.key});

  @override
  State<PageHeader> createState() => _PageHeaderState();
}

class _PageHeaderState extends State<PageHeader> {
  final searchController = SearchController();

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8.0,
      children: [
        Expanded(child: TaggerySearchBar(searchController: searchController)),
        TonalToggleButton(
          isSelected: false,
          label: "Edit tags",
          selectedIcon: Icon(Symbols.edit, fill: 1.0),
          icon: Icon(Symbols.edit),
          onPressed: () {},
        ),

        SquareTonalIconButton(
          icon: Icon(Icons.settings_outlined),
          onPressed: () {},
        ),
      ],
    );
  }
}
