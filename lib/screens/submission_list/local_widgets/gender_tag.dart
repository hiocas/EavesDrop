import 'package:eavesdrop/models/tag_list.dart';
import 'package:eavesdrop/screens/submission_page/local_widgets/gwa_tag.dart';
import 'package:eavesdrop/widgets/gwa_author_flair.dart';
import 'package:flutter/material.dart';

enum Gender { Female, Male, TransFemale, TransMale, NonBinary, All }

extension ParseToString on Gender {
  String nameToString() {
    return this.toString().split('.').last;
  }

  String genderLetter() {
    switch (this) {
      case Gender.Female:
        return 'f';
      case Gender.Male:
        return 'm';
      case Gender.TransFemale:
        return 'tf';
      case Gender.TransMale:
        return 'tm';
      case Gender.NonBinary:
        return 'nb';
      case Gender.All:
        return 'a';
    }
    return 'a';
  }

  String forTagTemplate(String template, String tag) => template
      .replaceFirst('{gender}', this.genderLetter())
      .replaceFirst('{tag}', tag);
}

Gender genderFromGenderLetter(String letter) {
  switch (letter.toLowerCase()) {
    case 'f':
      return Gender.Female;
    case 'm':
      return Gender.Male;
    case 'tf':
      return Gender.TransFemale;
    case 'tm':
      return Gender.TransMale;
    case 'nb':
      return Gender.NonBinary;
    case 'a':
      return Gender.All;
    default:
      return null;
  }
}

class GenderTag extends StatefulWidget {
  final Tag tag;
  final String genderTemplate;
  final String initialGender;
  final bool selected;
  final void Function(bool, String) onSelected;

  const GenderTag({
    Key key,
    @required this.tag,
    @required this.selected,
    @required this.onSelected,
    this.genderTemplate = '{gender}{tag}',
    this.initialGender,
  }) : super(key: key);

  RegExp get regexp {
    String regexp = '';
    for (var i = 0; i < Gender.values.length - 1; i++) {
      regexp +=
          Gender.values[i].forTagTemplate(genderTemplate, tag.label) + r'|';
    }
    return RegExp(
        regexp + Gender.values.last.forTagTemplate(genderTemplate, tag.label),
        caseSensitive: false);
  }

  @override
  _GenderTagState createState() => _GenderTagState();
}

class _GenderTagState extends State<GenderTag> {
  String tag;
  bool selected;
  Gender chosenGender = Gender.All;

  @override
  void initState() {
    if (widget.initialGender != null && widget.initialGender.isNotEmpty) {
      tag = widget.initialGender;
      chosenGender = genderFromGenderLetter(widget.initialGender
          .replaceFirst(RegExp(widget.tag.label, caseSensitive: false), ''));
      print(chosenGender);
    } else {
      tag = widget.tag.label;
    }
    selected = widget.selected;
    super.initState();
  }

  void setTag() {
    tag = chosenGender.forTagTemplate(widget.genderTemplate, widget.tag.label);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () async {
        RenderBox box = context.findRenderObject();
        Offset position = box.localToGlobal(Offset.zero);
        chosenGender = await showMenu<Gender>(
          context: context,
          position: RelativeRect.fromLTRB(
              position.dx, position.dy, position.dx, position.dy),
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          items: List.generate(
            Gender.values.length,
            (index) => PopupMenuItem(
              value: Gender.values[index],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Gender.values[index].nameToString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  SizedBox(
                      height: 18,
                      width: 18,
                      child: GwaAuthorFlair(
                        gender: Gender.values[index],
                      )),
                ],
              ),
            ),
          ),
        );
        if (chosenGender == null) chosenGender = Gender.All;
        widget.onSelected(false, tag);
        setState(() {
          setTag();
          selected = true;
          widget.onSelected(selected, tag);
        });
      },
      onTap: () {
        setState(() {
          setTag();
          selected = !selected;
          widget.onSelected.call(selected, tag);
        });
      },
      child: IgnorePointer(
        child: GwaTag(
          tag: widget.tag,
          selected: selected,
          onSelected: (value) {},
        ),
      ),
    );
  }
}
