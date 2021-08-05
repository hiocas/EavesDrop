import 'package:draw/draw.dart';
import 'package:eavesdrop/models/tag_list.dart';
import 'package:eavesdrop/screens/submission_page/local_widgets/submission_page_tags_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eavesdrop/models/gwa_submission.dart';
import 'package:eavesdrop/screens/submission_page/local_widgets/popup_add_card_button.dart';
import 'package:eavesdrop/screens/submission_page/local_widgets/popup_tags_card_button.dart';
import 'package:eavesdrop/screens/submission_page/local_widgets/submission_details.dart';
import 'package:eavesdrop/states/global_state.dart';
import 'package:eavesdrop/widgets/particles_icon_text_button.dart';
import 'submission_vote_button.dart';
import 'package:eavesdrop/widgets/popup_card_button.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' show launch;

/*TODO: Should probably break this widget into two (stateless buttons and
    stateful tags). I'm not sure where to generate _selectedTags though. */
class SubmissionPageButtonsAndTags extends StatefulWidget {
  const SubmissionPageButtonsAndTags({
    Key key,
    @required this.submission,
    @required this.redditSubmission,
    this.mini = false,
  }) : super(key: key);

  final GwaSubmission submission;
  final Submission redditSubmission;
  final bool mini;

  @override
  _SubmissionPageButtonsAndTagsState createState() =>
      _SubmissionPageButtonsAndTagsState();
}

class _SubmissionPageButtonsAndTagsState
    extends State<SubmissionPageButtonsAndTags> {
  TagList tagList;

  @override
  void initState() {
    tagList = TagList(widget.submission.tags);
    super.initState();
  }

  Widget _makeSupportButton(BuildContext context) {
    if (Provider.of<GlobalState>(context, listen: false).eligiblePrefs) {
      return SubmissionVoteButton(
        mini: widget.mini,
        icon: Icons.favorite_border,
        upvotedIcon: Icons.favorite,
        downvotedIcon: Icons.thumb_down,
        label: 'Vote',
        archivedSubtext: 'This post is archived',
        color: Theme.of(context).primaryColor,
        submission: widget.redditSubmission,
        millisecondsBeforeOnPressed: 0,
        confettiDuration: Duration(milliseconds: 300),
      );
    }
    return ParticlesIconTextButton(
      mini: widget.mini,
      icon: Icons.favorite_border,
      iconPressed: Icons.favorite,
      label: 'Open',
      subtext: 'Upvote this and show your support!',
      color: Theme.of(context).primaryColor,
      onPressed: () {
        launch(widget.submission.shortlink.toString());
      },
      confettiDuration: Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 4.0,
              right: 4.0,
              bottom: widget.mini ? 4.0 : 10.0,
              top: 15.0,
            ),
            //TODO(Design): Design these buttons better.
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PopupAddCardButton(
                  mini: widget.mini,
                  icon: Icons.add,
                  label: 'Save',
                  subtext: 'Save this post to your library',
                  color: Theme.of(context).primaryColor,
                  gwaSubmission: widget.submission,
                  heroTag: 'save-submission-popup',
                  usePlaceholder: true,
                ),
                _makeSupportButton(context),
                PopupCardButton(
                  icon: Icons.expand,
                  label: 'Details',
                  subtext: "Show all of the post's details",
                  color: Theme.of(context).primaryColor,
                  mini: widget.mini,
                  heroTag: 'submission-details-popup',
                  child: SubmissionDetails(
                    gwaSubmission: widget.submission,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  usePlaceholder: true,
                ),
                PopupTagsCardButton(
                  icon: Icons.search,
                  label: 'Tags',
                  subtext: "View and query all of the post's tags",
                  color: Theme.of(context).primaryColor,
                  mini: widget.mini,
                  heroTag: 'submission-tags-popup',
                  gwaSubmission: widget.submission,
                  tagList: tagList,
                  onSelected: (bool value, int index) {
                    setState(() {
                      tagList.selectedTags[index] = value;
                    });
                  },
                  usePlaceholder: true,
                ),
              ],
            ),
          ),
          SubmissionPageTagsList(
            tagList: tagList,
          )
        ],
      ),
    );
  }
}
