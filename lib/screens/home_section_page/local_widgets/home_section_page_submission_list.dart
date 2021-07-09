import 'package:flutter/material.dart';
import 'package:eavesdrop/models/gwa_submission_preview.dart';
import 'package:eavesdrop/widgets/gwa_list_item.dart';

class SubmissionList extends StatelessWidget {
  const SubmissionList({
    Key key,
    @required this.submissionList,
    this.crossAxisCount,
  }) : super(key: key);

  final List<GwaSubmissionPreviewWithAuthor> submissionList;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: this.crossAxisCount ?? 3,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
            return GwaListItem(
              submission: submissionList[index].toGwaSubmissionPreview(),
            );
          },
          childCount: submissionList.length,
        ),
      ),
    );
  }
}