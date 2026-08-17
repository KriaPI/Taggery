import 'package:material_ui/material_ui.dart';

class ContentFilters extends StatelessWidget {
  const ContentFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 24.0,
      children: [
        DropdownMenu(
          initialSelection: 0,
          trailingIcon: Icon(Icons.unfold_more_rounded),
          selectedTrailingIcon: Icon(Icons.unfold_less_rounded),
          dropdownMenuEntries: [
          DropdownMenuEntry(value: 0, label: "Ascending date"),
          DropdownMenuEntry(value: 1, label: "Descending date"),
          DropdownMenuEntry(value: 2, label: "Ascending name"),
          DropdownMenuEntry(value: 3, label: "Descending name"),
        ]),
        Row(
          spacing: 4.0,
          children: [
            FilterChip(label: Text("Images"), onSelected: (_) {}),
            FilterChip(label: Text("Videos"), onSelected: (_) {}),
          ],
        ),
        Row(
          spacing: 4.0,
          children: [
            FilterChip(label: Text("Safe"), onSelected: (_) {}),
            FilterChip(label: Text("Suggestive"), onSelected: (_) {}),
            FilterChip(label: Text("Explicit"), onSelected: (_) {}),
          ],
        ),
      ]
    );
  }
}
