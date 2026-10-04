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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        spacing: 24.0,
        children: [
          Expanded(
            child: Row(
              spacing: 8.0,
              children: [
                Expanded(child: TaggerySearchBar(searchController: searchController)),
                SquareTonalTextButton(
                  isSelected: false,
                  label: "Edit tags",
                  selectedIcon: Symbols.edit,
                  icon: Symbols.edit,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          SquareTonalIconButton(
            icon: Icons.settings_outlined,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
