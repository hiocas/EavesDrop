import 'package:eavesdrop/models/tag_list.dart';
import 'package:flutter/material.dart';
import 'package:eavesdrop/utils/util_functions.dart' show getTagName;

class GwaTag extends StatelessWidget {
  const GwaTag({
    Key key,
    @required this.tag,
    @required this.selected,
    @required this.onSelected,
    this.labelColor = Colors.black,
  }) : super(key: key);

  final Tag tag;
  final bool selected;
  final void Function(bool) onSelected;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    print('building');
    return Container(
      padding: const EdgeInsets.only(right: 4.0),
      child: FilterChip(
        labelPadding: tag.multipleChars
            ? const EdgeInsets.only(left: 2.0, right: 10.0)
            : const EdgeInsets.only(left: 3.0, right: 6.0),
        padding: tag.multipleChars ? const EdgeInsets.only(left: 4.0) : null,
        visualDensity: VisualDensity.compact,
        selected: selected,
        label: Text(getTagName(tag.label), style: TextStyle(color: this.labelColor)),
        backgroundColor: tag.inWarning
            ? Theme.of(context).errorColor
            : Theme.of(context).primaryColor,
        selectedColor: Theme.of(context).colorScheme.secondary,
        side: BorderSide(width: 0.0),
        avatar: tag.avatar,
        onSelected: (bool value) {
          onSelected.call(value);
        },
      ),
    );
  }
}
