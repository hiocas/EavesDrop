import 'package:flutter/material.dart';
import 'package:gwa_app/utils/util_functions.dart' show getTagName;

class GwaTag extends StatelessWidget {
  const GwaTag({
    Key key,
    @required this.tag,
    @required this.selected,
    @required this.onSelected,
  }) : super(key: key);

  final String tag;
  final bool selected;
  final void Function(bool) onSelected;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> avatarCreator = _tagChipAvatar(tag);
    final Widget avatar = avatarCreator[0];
    final bool multipleChars = avatarCreator[1] == 2;
    return Container(
      padding: const EdgeInsets.only(right: 4.0),
      child: FilterChip(
        labelPadding: multipleChars
            ? const EdgeInsets.only(left: 2.0, right: 10.0)
            : const EdgeInsets.only(left: 3.0, right: 6.0),
        padding: multipleChars ? const EdgeInsets.only(left: 4.0) : null,
        visualDensity: VisualDensity.compact,
        selected: selected,
        label: Text(getTagName(tag)),
        backgroundColor: Theme.of(context).primaryColor,
        selectedColor: Theme.of(context).accentColor,
        side: BorderSide(width: 0.0),
        avatar: avatar,
        onSelected: (bool value) {
          print(tag);
          onSelected.call(value);
        },
      ),
    );
  }
}

//Use the live templates "tagt" and tagt2.
List _tagChipAvatar(String tag) {
  if (tag.contains(RegExp(r'^tf4|^(tf)$', caseSensitive: false)))
    return [
      Image.asset('lib/assets/images/GwaTransFemaleAvatar.png',
          width: 18, height: 18),
      1
    ];
  else if (tag.contains(RegExp(r'^tm4|^(tm)$', caseSensitive: false)))
    return [
      Image.asset('lib/assets/images/GwaTransMaleAvatar.png',
          width: 18, height: 18),
      1
    ];
  else if (tag.contains(RegExp(r'^nb4|^(nb)$', caseSensitive: false)))
    return [
      Image.asset('lib/assets/images/GwaNonBinaryAvatar.png',
          width: 18, height: 18),
      1
    ];
  else if (tag.contains(RegExp(r'^f+4|^(f)$', caseSensitive: false)))
    return [
      Image.asset('lib/assets/images/GwaFemaleAvatar.png',
          width: 18, height: 18),
      1
    ];
  else if (tag.contains(RegExp(r'^m+4|^(m)$', caseSensitive: false)))
    return [
      Image.asset('lib/assets/images/GwaMaleAvatar.png', width: 18, height: 18),
      1
    ];
  else if (tag.contains(RegExp('{author:}', caseSensitive: false)))
    return [Text('\u{1f4e3}'), 1];
  else if (tag.contains(RegExp('fingering', caseSensitive: false)))
    return [Text('\u{1f595}'), 1];
  else if (tag.contains(
      RegExp('neko|catgirl|cat girl|purr|nyaa', caseSensitive: false)))
    return [
      Image.asset('lib/assets/images/headband.png', width: 18, height: 18),
      1
    ];
  else if (tag.contains(RegExp('kiss', caseSensitive: false)))
    return [Text('\u{1f48b}'), 1];
  else if (tag.contains(RegExp('script', caseSensitive: false)))
    return [Text('\u{1f4c3}'), 1];
  else if (tag.contains(RegExp('(ft)([^a-z])', caseSensitive: false)))
    return [Text('\u{1f31f}'), 1];
  else if (tag
      .contains(RegExp('hypnosis|((mind)(.*)(control))', caseSensitive: false)))
    return [Text('\u{1f441}\u{fe0f}\u{200d}\u{1f5e8}\u{fe0f}'), 1];
  else if (tag.contains(RegExp('asmr', caseSensitive: false)))
    return [Text('\u{1f399}'), 1];
  else if (tag.contains(RegExp('((l)(-| )(bombs))', caseSensitive: false)))
    return [Text('\u{1f496}'), 1];
  else if (tag.contains(RegExp('blowjob', caseSensitive: false)))
    return [
      Row(children: [
        Text('\u{1f346}', style: TextStyle(fontSize: 12)),
        Text('\u{1f445}', style: TextStyle(fontSize: 12))
      ]),
      2
    ];
  else if (tag.contains(
      RegExp('(?<=cum)(.*)(in|on)(.*)(?=mouth)', caseSensitive: false)))
    return [
      Row(children: [
        Text('\u{1f4a6}', style: TextStyle(fontSize: 12)),
        Text('\u{1f444}', style: TextStyle(fontSize: 12))
      ]),
      2
    ];
//TODO(Design): Maybe rethink this one.
  else if (tag
      .contains(RegExp('(?<=enemies)(.*)(?=lovers)', caseSensitive: false)))
    return [
      Row(children: [
        Text('\u{2764}', style: TextStyle(fontSize: 12)),
        Text('\u{1fa79}', style: TextStyle(fontSize: 12))
      ]),
      2
    ];
  else if (tag.contains(RegExp('creampie', caseSensitive: false)))
    return [
      Row(children: [
        Text('\u{1f4a6}', style: TextStyle(fontSize: 12)),
        Text('\u{270c}', style: TextStyle(fontSize: 12))
      ]),
      2
    ];
  else
    return [Icon(Icons.info), 1];
}
