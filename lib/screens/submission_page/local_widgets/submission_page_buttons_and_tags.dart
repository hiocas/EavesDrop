import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:gwa_app/models/gwa_submission.dart';
import 'package:gwa_app/screens/submission_page/local_widgets/popup_add_card_button.dart';
import 'package:gwa_app/screens/submission_page/local_widgets/popup_tags_card_button.dart';
import 'package:gwa_app/screens/submission_page/local_widgets/submission_details.dart';
import 'package:gwa_app/states/global_state.dart';
import 'package:gwa_app/utils/util_functions.dart'
    show UtilFunctions, getTagName;
import 'package:gwa_app/widgets/particles_icon_text_button.dart';
import 'package:gwa_app/widgets/popup_card_button.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' show launch;

/*TODO: Should probably break this widget into two (stateless buttons and
    stateful tags). I'm not sure where to generate _selectedTags though. */
class SubmissionPageButtonsAndTags extends StatefulWidget {
  const SubmissionPageButtonsAndTags({
    Key key,
    @required this.submission,
    @required this.redditSubmission,
    @required this.fromLibrary,
  }) : super(key: key);

  final GwaSubmission submission;
  final Submission redditSubmission;
  final bool fromLibrary;

  @override
  _SubmissionPageButtonsAndTagsState createState() =>
      _SubmissionPageButtonsAndTagsState();
}

class _SubmissionPageButtonsAndTagsState
    extends State<SubmissionPageButtonsAndTags> {
  List<bool> _selectedTags = [];

  @override
  void initState() {
    _selectedTags = List<bool>.generate(
      widget.submission.tags.length,
      (index) => false,
    );
    super.initState();
  }

  Widget _makeSupportButton(BuildContext context) {
    if (Provider.of<GlobalState>(context, listen: false).eligiblePrefs) {
      return ParticlesIconTextToggleButton(
        icon: Icons.favorite_border,
        iconPressed: Icons.favorite,
        label: 'Upvote',
        subtext: 'Upvote this and show your support!',
        color: Theme.of(context).primaryColor,
        initialPressed: _voted(),
        millisecondsBeforeOnPressed: 0,
        onPressed: () async {
          // TODO: Display a snackbar if action failed.
          if (_voted()) {
            await widget.redditSubmission.clearVote(waitForResponse: true);
          } else {
            await widget.redditSubmission.upvote(waitForResponse: true);
          }
        },
        confettiDuration: Duration(milliseconds: 300),
      );
    }
    return ParticlesIconTextButton(
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

  bool _voted() {
    if (widget.redditSubmission.vote == VoteState.upvoted) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 4.0,
              right: 4.0,
              bottom: 10.0,
              top: 15.0,
            ),
            //TODO(Design): Design these buttons better.
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PopupAddCardButton(
                  icon: Icons.add,
                  label: 'Save',
                  subtext: 'Save this post to your library',
                  color: Theme.of(context).primaryColor,
                  gwaSubmission: widget.submission,
                  heroTag: 'save-submission-popup',
                  usePlaceholder: true,
                  fromLibrary: widget.fromLibrary,
                ),
                _makeSupportButton(context),
                PopupCardButton(
                  icon: Icons.expand,
                  label: 'Details',
                  subtext: "Show all of the post's details",
                  color: Theme.of(context).primaryColor,
                  heroTag: 'submission-details-popup',
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SubmissionDetails(
                      gwaSubmission: widget.submission,
                    ),
                  ),
                  usePlaceholder: true,
                ),
                PopupTagsCardButton(
                  icon: Icons.search,
                  label: 'Tags',
                  subtext: "View and query all of the post's tags",
                  color: Theme.of(context).primaryColor,
                  heroTag: 'submission-tags-popup',
                  gwaSubmission: widget.submission,
                  selectedTags: _selectedTags,
                  onSelected: (bool value, int index) {
                    print(widget.submission.tags[index]);
                    setState(() {
                      _selectedTags[index] = value;
                      print(_selectedTags[index]);
                    });
                  },
                  usePlaceholder: true,
                ),
              ],
            ),
          ),
          (widget.submission.tags.length > 0
              ? Container(
                  margin:
                      const EdgeInsets.only(left: 10.0, top: 4.0, bottom: 4.0),
                  height: 35,
                  child: ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      var tagList = widget.submission.tags;
                      var avatarCreator =
                          UtilFunctions.tagChipAvatar(tagList[index]);
                      Widget avatar = avatarCreator[0];
                      int chars = avatarCreator[1];
                      //If there are 2 chars as an avatar.
                      if (chars == 2)
                        return Container(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: FilterChip(
                            labelPadding:
                                const EdgeInsets.only(left: 2.0, right: 10.0),
                            padding: const EdgeInsets.only(left: 4.0),
                            visualDensity: VisualDensity.compact,
                            selected: _selectedTags[index],
                            label: Text(getTagName(tagList[index])),
                            backgroundColor: Theme.of(context).primaryColor,
                            selectedColor: Theme.of(context).accentColor,
                            side: BorderSide(width: 0.0),
                            avatar: avatar,
                            onSelected: (bool value) {
                              print(tagList[index]);
                              setState(() {
                                _selectedTags[index] = value;
                                print(_selectedTags[index]);
                              });
                            },
                          ),
                        );
                      //If there is any other number of chars as an avatar.
                      else
                        return Container(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: FilterChip(
                            labelPadding:
                                const EdgeInsets.only(left: 3.0, right: 6.0),
                            visualDensity: VisualDensity.compact,
                            selected: _selectedTags[index],
                            label: Text(getTagName(tagList[index])),
                            backgroundColor: Theme.of(context).primaryColor,
                            selectedColor: Theme.of(context).accentColor,
                            side: BorderSide(width: 0.0),
                            avatar: avatar,
                            onSelected: (bool value) {
                              print(tagList[index]);
                              setState(() {
                                _selectedTags[index] = value;
                                print(_selectedTags[index]);
                              });
                            },
                          ),
                        );
                    },
                    itemCount: widget.submission.tags.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                  ),
                  /* This makes it so we won't show the tag list if the
                        post has no tags. */
                )
              : Container()),
        ],
      ),
    );
  }
}
