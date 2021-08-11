import 'package:eavesdrop/models/hive_boxes.dart';
import 'package:eavesdrop/models/tag_list.dart';
import 'package:flutter/material.dart';
import 'package:eavesdrop/screens/submission_page/local_widgets/gwa_tag.dart';
import 'package:eavesdrop/widgets/navigator_routes/hero_dialog_route.dart';
import 'package:eavesdrop/widgets/popup_card_button.dart';

import 'default_settings.dart';

class WarningTagList extends StatefulWidget {
  const WarningTagList({
    Key key,
    @required this.tagList,
    this.spacing = 15.0,
    this.explanation,
    this.spaceHead = true,
  }) : super(key: key);

  final TagList tagList;
  final double spacing;
  final Widget explanation;
  final bool spaceHead;

  @override
  _WarningTagListState createState() => _WarningTagListState();
}

class _WarningTagListState extends State<WarningTagList> {
  @override
  Widget build(BuildContext context) {
    final bool _selected =
        widget.tagList.selectedTags.any((selected) => selected);
    return ListSetting(
      icon: Icons.error_outline,
      settingName: 'Warning Tags',
      length: widget.tagList.tags.length,
      explanation: SettingExplanation(
        title: 'What is this?',
        explanation:
            "Tags that are saved as **Warning Tags** will show up first in a "
            "post page (after the author's name and the gender tags) with a "
            "special color (and icon if it's not taken by a tag avatar) to let "
            "you know that the post contains them right away.",
      ),
      heroTag: 'warning-tag-list-hero-tag',
      fabIcon: _selected ? Icons.delete_outline : Icons.add,
      fabColor: _selected
          ? Theme.of(context).accentColor
          : Theme.of(context).primaryColor,
      onFABPressed: () async {
        if (!_selected) {
          final result = await Navigator.push(
            context,
            HeroDialogRoute(
              builder: (context) =>
                  _WarningTagListDialog(tags: widget.tagList.tagLabels),
            ),
          );
          if (result != null && result.isNotEmpty) {
            widget.tagList.add(result);
            await HiveBoxes.editAppSettings(
                warningTags: widget.tagList.tagLabels);
            setState(() {});
          }
        } else {
          for (int i = 0; i < widget.tagList.tagLabels.length; i++) {
            if (widget.tagList.selectedTags[i]) {
              print(widget.tagList.tagLabels[i]);
              widget.tagList.remove(i);
              i--;
            }
          }
          await HiveBoxes.editAppSettings(
              warningTags: widget.tagList.tagLabels);
          setState(() {});
        }
      },
      itemBuilder: (context, index) => Align(
        alignment: Alignment.topLeft,
        child: GwaTag(
          tag: widget.tagList.tags[index].copyWith(inWarning: true),
          selected: widget.tagList.selectedTags[index],
          onSelected: (value) {
            widget.tagList.selectedTags[index] = value;
            setState(() {});
          },
        ),
      ),
    );
  }
}

class _WarningTagListDialog extends StatefulWidget {
  const _WarningTagListDialog({
    Key key,
    @required this.tags,
  }) : super(key: key);

  final List<String> tags;

  @override
  __WarningTagListDialogState createState() => __WarningTagListDialogState();
}

class __WarningTagListDialogState extends State<_WarningTagListDialog> {
  TextEditingController textEditingController = new TextEditingController();

  add() {
    final String text = textEditingController.text;
    if (!text.contains(RegExp(r'\]|\['))) {
      bool exists = false;
      for (String tag in widget.tags) {
        if (tag == text) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        Navigator.of(context).pop(textEditingController.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: 'warning-tag-list-hero-tag',
          child: DefaultPopupCard(
            heroTag: 'warning-tag-list-hero-tag',
            child: Column(
              children: [
                Text(
                  'Warning Tag Name:',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                ),
                SizedBox(height: 5),
                Text(
                  "Make sure it isn't included already and that there are "
                  "no \"[ ]\".",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                      fontSize: 14.0),
                ),
                TextField(
                  autofocus: true,
                  controller: textEditingController,
                  maxLines: 1,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (value) => add(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text('Add'),
                      onPressed: add,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
