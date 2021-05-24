import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gwa_app/models/gwa_submission.dart';
import 'package:gwa_app/widgets/markdown_viewer.dart';

//TODO(Design): Maybe redesign this widget.
class SubmissionDetails extends StatelessWidget {
  final GwaSubmission gwaSubmission;

  const SubmissionDetails({Key key, this.gwaSubmission}) : super(key: key);

  String _makeMarkdownDetails() {
    return '>### **${gwaSubmission.fullTitle}**'
        '\n---\n'
        '>Author: u/${gwaSubmission.author}.'
        '\n\n'
        '>Author Flair: ${gwaSubmission.authorFlairText}.'
        '\n\n'
        '>Flair: ${gwaSubmission.linkFlairText}.'
        '\n\n'
        '>Created: ${gwaSubmission.created.toString()}.'
        '\n\n'
        '>Upvotes: ${gwaSubmission.upvotes}.'
        '\n\n'
        '>Platinum: ${gwaSubmission.platinum}. '
        'Gold: ${gwaSubmission.gold}. '
        'Silver: ${gwaSubmission.silver}.'
        '\n\n'
        '>Number of Comments: ${gwaSubmission.numComments}.';
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownViewer(
      text: _makeMarkdownDetails(),
      bodyTextColor: Colors.black,
      blockQuoteDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        color: Theme.of(context).primaryColor,
      ),
      bodyTextFontSize: 12.0,
      horizontalRuleDecoration: BoxDecoration(
          border: Border(top: BorderSide(width: 3.0, color: Colors.black))),
    );
  }
}
