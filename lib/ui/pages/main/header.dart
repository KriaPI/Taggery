import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taggery/ui/components/buttons.dart';
import 'package:taggery/ui/components/misc.dart';
import 'package:taggery/ui/components/search_bar.dart';

class PageHeader extends StatefulWidget {
  const PageHeader({super.key, required this.searchController, required this.onSearchClosed, required this.searchFocus});
  final FocusNode searchFocus;
  final SearchController searchController;
  final VoidCallback onSearchClosed;

  @override
  State<PageHeader> createState() => _PageHeaderState();
}

class _PageHeaderState extends State<PageHeader> {
  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      spacing: DefaultSpacing.xs,
      children: [
        // TODO: make search bar right aligned and make the sizedbox disappear when there is little horizontal space. 
        Expanded(flex: 1, child: SizedBox(height: 10, width: .infinity)),
        Expanded(flex: 2, child: TaggerySearchBar(searchController: widget.searchController, onSearchClosed: widget.onSearchClosed, searchFocus: widget.searchFocus,)),
        Expanded(
          flex: 1,
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
                      foregroundColor: onSurfaceVariant,
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
