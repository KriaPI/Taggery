import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taggery/ui/components/buttons.dart';
import 'package:taggery/ui/components/misc.dart';
import 'package:taggery/ui/components/search_bar.dart';

class PageHeader extends StatefulWidget {
  const PageHeader({super.key});

  @override
  State<PageHeader> createState() => _PageHeaderState();
}

class _PageHeaderState extends State<PageHeader> {
  final searchController = SearchController();

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      spacing: DefaultSpacing.xs,
      children: [
        Expanded(child: SizedBox(height: 10, width: .infinity)),
        TaggerySearchBar(searchController: searchController),
        Expanded(
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              SquareTonalIconButton(
                icon: Symbols.filter_alt,
                onPressed: () {},
              ),
              Row(
                spacing: DefaultSpacing.small,
                children: [
                  SquareTonalTextButton(
                    isSelected: false,
                    label: "Edit tags",
                    selectedIcon: Symbols.edit,
                    icon: Symbols.edit,
                    onPressed: () {},
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: IconWithDefaults(
                      Icons.settings_outlined,
                      color: onSurfaceVariant,
                    ),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: .all(.circular(12.0)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
