import 'package:eavesdrop/models/tag_list.dart';
import 'package:flutter/material.dart';

import 'gwa_tag.dart';

class SubmissionPageTagsList extends StatefulWidget {
  final TagList tagList;

  const SubmissionPageTagsList({
    Key key,
    this.tagList,
  }) : super(key: key);

  @override
  _SubmissionPageTagsListState createState() => _SubmissionPageTagsListState();
}

class _SubmissionPageTagsListState extends State<SubmissionPageTagsList> {
  @override
  Widget build(BuildContext context) {
    if (widget.tagList.tags.length == 0) return Container();
    return Container(
      margin: const EdgeInsets.only(left: 10.0, top: 4.0, bottom: 4.0),
      height: 35,
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return GwaTag(
            tag: widget.tagList.tags[index],
            selected: widget.tagList.selectedTags[index],
            onSelected: (value) {
              setState(() {
                widget.tagList.selectedTags[index] = value;
              });
            },
          );
        },
        itemCount: widget.tagList.tags.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
