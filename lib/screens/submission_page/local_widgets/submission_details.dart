import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eavesdrop/models/gwa_submission.dart';
import 'package:eavesdrop/states/global_state.dart';
import 'package:eavesdrop/widgets/markdown_viewer.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

//TODO(Design): Maybe redesign this widget.
class SubmissionDetails extends StatelessWidget {
  final GwaSubmission gwaSubmission;
  final double maxWidth;

  const SubmissionDetails({
    Key key,
    @required this.gwaSubmission,
    this.maxWidth = 240,
  }) : super(key: key);

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
    final rwidth = MediaQuery.of(context).size.width - 140;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MarkdownViewer(
          text: _makeMarkdownDetails(),
          inPopupCard: true,
          bodyTextColor: Colors.black,
          subtitle1TextStyle: TextStyle(color: Colors.black),
          blockQuoteDecoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            color: Theme.of(context).primaryColor,
          ),
          bodyTextFontSize: 12.0,
          horizontalRuleDecoration: BoxDecoration(
              border: Border(top: BorderSide(width: 3.0, color: Colors.black))),
        ),
        Provider.of<GlobalState>(context, listen: false).eligiblePrefs
            // The LayoutBuilder is here to prevent overflow.
            ? LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth < rwidth) {
                  return Container();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: ElevatedButton.icon(
                      icon: Icon(Icons.launch),
                      label: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: rwidth - 24),
                        child: Text(
                          'Open Post in Browser',
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(15.0),
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor)),
                      onPressed: () {
                        launch(gwaSubmission.shortlink.toString());
                      }),
                );
              })
            : Container()
      ],
    );
  }
}
