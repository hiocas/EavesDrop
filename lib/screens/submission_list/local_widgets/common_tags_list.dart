import 'package:eavesdrop/models/tag_list.dart';
import 'package:flutter/material.dart';
import 'package:eavesdrop/models/search_details.dart';
import 'gender_tag.dart';
import 'package:eavesdrop/screens/submission_page/local_widgets/gwa_tag.dart';

class CommonTagsList extends StatefulWidget {
  const CommonTagsList({
    Key key,
    @required this.tags,
    @required this.initialText,
    @required this.onSelected,
  }) : super(key: key);

  final List<String> tags;
  final String initialText;
  final void Function(bool, String) onSelected;

  @override
  _CommonTagsListState createState() => _CommonTagsListState();
}

class _CommonTagsListState extends State<CommonTagsList> {
  TagList tagList;
  final List<Widget> tagWidgets = [];
  final List<String> initialGenders = [];

  @override
  void initState() {
    this.tagList = TagList(widget.tags);
    this
        .initialGenders
        .addAll(List.generate(widget.tags.length, (index) => ''));

    final SearchDetails _queryDetails =
        SearchDetails.fromQuery(widget.initialText);
    var exp = RegExp(r'(?<=\")(.*?)(?=\")');
    var matches = exp.allMatches(_queryDetails.includedTags);
    final List<String> _tags = [];
    if (matches.length > 0) {
      for (RegExpMatch match in matches) {
        if (match.group(0).trim().isNotEmpty) {
          _tags.add(match.group(0));
        }
      }
    }

    for (var i = 0; i < _tags.length; i++) {
      for (var j = 0; j < this.length; j++) {
        if (this.regExp(tagList.tags[j]).hasMatch(_tags[i])) {
          // TODO: Change gender tags to the tag if found.
          int _found = -1;
          for (var t = 0; t < widget.tags.length; t++) {
            if (widget.tags[t] == _tags[i]) {
              _found = t;
              break;
            }
          }
          if (_found != -1) {
            this.tagList.selectedTags[_found] = true;
          } else {
            this.tagList.selectedTags[j] = true;
            this.initialGenders[j] = _tags[i];
          }
          _tags[i] = '';
          break;
        }
      }
    }

    for (var i = 0; i < widget.tags.length; i++) {
      if (isGenderTag(tagList.tags[i])) {
        addGenderTag(
          getGenderTag(tagList.tags[i]),
          genderTemplate: getGenderTemplate(tagList.tags[i]),
          initialGender: initialGenders[i],
        );
      } else {
        addTag(tagList.tags[i]);
      }
    }

    this.addAll(_tags, when: (tag) => tag.isNotEmpty);

    super.initState();
  }

  Tag getGenderTag(Tag tag) => Tag(
        label: tag.label.replaceFirst('[gender]', ''),
        avatar: tag.avatar,
        inWarning: tag.inWarning,
        multipleChars: tag.multipleChars,
      );

  int get length => widget.tags.length;

  bool isGenderTag(Tag tag) {
    return tag.label.contains(RegExp(r'\[gender\]'));
  }

  String getGenderTemplate(Tag tag) =>
      tag.label.indexOf('[') == 0 ? '{gender}{tag}' : '{tag}{gender}';

  RegExp regExp(Tag tag) {
    print(tag);
    if (this.isGenderTag(tag)) {
      final GenderTag tagWidget = GenderTag(
        onSelected: (value, chosenTag) {},
        tag: getGenderTag(tag),
        selected: false,
        genderTemplate: getGenderTemplate(tag),
      );
      return tagWidget.regexp;
    } else {
      return RegExp(tag.label, caseSensitive: false);
    }
  }

  addGenderTag(Tag tag, {String genderTemplate, String initialGender}) {
    final int index = tagWidgets.length;
    print('initial gender: $initialGender');
    tagWidgets.add(GenderTag(
      tag: tag,
      selected: tagList.selectedTags[index],
      onSelected: (value, chosenTag) {
        tagList.selectedTags[index] = value;
        widget.onSelected.call(value, chosenTag);
      },
      genderTemplate: genderTemplate,
      initialGender: initialGender,
    ));
  }

  addTag(Tag tag) {
    final int index = tagWidgets.length;
    tagWidgets.add(StatefulGwaTag(
        tag: tag,
        selected: tagList.selectedTags[index],
        onSelected: (value) {
          tagList.selectedTags[index] = value;
          widget.onSelected.call(value, tag.label);
        }));
  }

  addAll(List<String> tags, {bool Function(String) when}) =>
      tags.forEach((tag) {
        if (when != null && when.call(tag)) {
          this.tagList.add(tag);
          this.addTag(this.tagList.tags.last);
        }
      });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: tagWidgets,
    );
  }
}

//FIXME: This is really scuffed but for now it works.
class StatefulGwaTag extends StatefulWidget {
  const StatefulGwaTag({
    Key key,
    @required this.tag,
    @required this.selected,
    @required this.onSelected,
  }) : super(key: key);

  final Tag tag;
  final bool selected;
  final void Function(bool) onSelected;

  @override
  _StatefulGwaTagState createState() => _StatefulGwaTagState();
}

class _StatefulGwaTagState extends State<StatefulGwaTag> {
  bool _selected;

  @override
  void initState() {
    _selected = widget.selected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          print('tapped');
          _selected = !_selected;
          widget.onSelected.call(_selected);
        });
      },
      child: IgnorePointer(
        child: GwaTag(tag: widget.tag, selected: _selected, onSelected: null),
      ),
    );
  }
}
