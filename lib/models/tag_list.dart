import 'package:eavesdrop/utils/gwa_functions.dart';
import 'package:flutter/material.dart';

class TagList {
  final List<bool> selectedTags = [];
  final List<String> tagLabels = [];
  List<Tag> tags = [];
  List<String> warningTags;

  /// Constructs a [TagList] object.
  /// [tagLabels] are the tag labels from which the [Tag] list will be
  /// constructed.
  /// [sort] determines whether the list should be sorted (currently based on
  /// warning tags) or not.
  TagList(List<String> tagLabels,
      {bool sort = false, List<String> warningTags = const []}) {
    assert(tagLabels != null);

    this.warningTags = warningTags;

    for (String label in tagLabels) {
      add(label);
    }
    if (sort) {
      this.tags.sort((Tag a, Tag b) => a.compareTo(b));
    }
    print(GwaFunctions.isTagSpecial('f4m'));
  }

  add(String label, {bool selected = false}) {
    this.tagLabels.add(label);
    this.selectedTags.add(false);

    bool inWarning = false;
    for (String warningTag in warningTags) {
      if (label.contains(RegExp(warningTag, caseSensitive: false))) {
        inWarning = true;
        break;
      }
    }

    final List<dynamic> avatarCreator = tagChipAvatar(label, inWarning);

    this.tags.add(Tag(
        label: label,
        avatar: avatarCreator[0],
        multipleChars: avatarCreator[1] == 2,
        inWarning: inWarning,
        isSpecial: GwaFunctions.isTagSpecial(label)));
  }

  addAll(List<String> labels, {bool Function(String) when}) =>
      labels.forEach((label) {
        if (when != null && when.call(label)) {
          this.add(label);
        }
      });

  remove(int index) {
    this.tagLabels.removeAt(index);
    this.selectedTags.removeAt(index);
    this.tags.removeAt(index);
  }

  //Use the live templates "tagt" and tagt2.
  static List tagChipAvatar(String tag, bool inWarning) {
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
        Image.asset('lib/assets/images/GwaMaleAvatar.png',
            width: 18, height: 18),
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
    else if (tag.contains(
        RegExp('hypnosis|((mind)(.*)(control))', caseSensitive: false)))
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
      return [Icon(inWarning ? Icons.error : Icons.info), 1];
  }
}

class Tag implements Comparable<Tag> {
  final String label;
  final Widget avatar;
  final bool multipleChars;
  final bool inWarning;
  final bool isSpecial;

  const Tag({
    @required this.label,
    @required this.avatar,
    @required this.multipleChars,
    @required this.inWarning,
    this.isSpecial = false,
  });

  Tag copyWith({
    String label,
    Widget avatar,
    bool multipleChars,
    bool inWarning,
    bool isSpecial,
  }) =>
      Tag(
          label: label ?? this.label,
          avatar: avatar ?? this.avatar,
          multipleChars: multipleChars ?? this.multipleChars,
          inWarning: inWarning ?? this.inWarning,
          isSpecial: isSpecial ?? this.isSpecial);

  @override
  int compareTo(Tag other) {
    if (this.isSpecial) {
      if (other.isSpecial)
        return 0;
      else
        return -1;
    } else if (other.isSpecial) {
      return 1;
    } else if (this.inWarning) {
      if (other.inWarning)
        return 0;
      else
        return -1;
    } else if (other.inWarning) {
      return 1;
    }
    return 0;
  }
}
