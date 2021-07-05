import 'package:flutter/material.dart';
import 'package:draw/draw.dart';
import 'package:confetti/confetti.dart';
import 'package:gwa_app/widgets/icon_text_button.dart';

class SubmissionVoteButton extends StatefulWidget {
  final String label;
  final Submission submission;
  final IconData icon;
  final IconData upvotedIcon;
  final IconData downvotedIcon;
  final String archivedSubtext;
  final Color color;
  final Color subtextColor;
  final Color backgroundColor;

  ///The duration can't be smaller then a millisecond, else it'll be 300.
  final Duration confettiDuration;
  final List<Color> confettiColors;
  final int millisecondsBeforeOnPressed;

  final bool mini;

  const SubmissionVoteButton({
    Key key,
    @required this.label,
    @required this.submission,
    @required this.icon,
    @required this.upvotedIcon,
    @required this.downvotedIcon,
    this.archivedSubtext,
    this.color,
    this.subtextColor,
    this.backgroundColor,
    @required this.confettiDuration,
    this.confettiColors,
    this.millisecondsBeforeOnPressed,
    this.mini = false,
  }) : super(key: key);

  @override
  _SubmissionVoteButtonState createState() => _SubmissionVoteButtonState();
}

class _SubmissionVoteButtonState extends State<SubmissionVoteButton> {
  ConfettiController _confettiController;
  IconData _icon;
  String _subtext;
  bool _archived;
  VoteState _voteState;

  @override
  void initState() {
    _archived = widget.submission.archived;
    _voteState = widget.submission.vote;
    if (_archived) {
      _subtext = 'This post is archived';
    }
    _setWidgets();
    _confettiController = ConfettiController(
        duration: widget.confettiDuration.inMilliseconds > 1
            ? widget.confettiDuration
            : Duration(milliseconds: 300));
    super.initState();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  _setWidgets() {
    switch (_voteState) {
      case VoteState.none:
        _icon = widget.icon;
        _subtext = 'Upvote this and show your support!';
        break;
      case VoteState.upvoted:
        _icon = widget.upvotedIcon;
        _subtext = 'Upvoted,\npress to clear';
        break;
      case VoteState.downvoted:
        _icon = widget.downvotedIcon;
        _subtext = 'Downvoted,\npress to clear';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: widget.mini ? 88 : 65,
          height: widget.mini ? 45 : 65,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              IconTextButtonElement(
                mini: widget.mini,
                label: widget.label,
                icon: _icon,
                color: _archived
                    ? widget.color.withOpacity(0.4)
                    : this.widget.color,
                backgroundColor: this.widget.backgroundColor,
              ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: widget.mini
                      ? BorderRadius.circular(14.0)
                      : BorderRadius.circular(22.0),
                  onTap: _archived == null
                      ? null
                      : () async {
                    Feedback.forTap(context);
                    if (_voteState == VoteState.none) {
                      _confettiController.play();
                      setState(() {
                        _voteState = VoteState.upvoted;
                        _setWidgets();
                      });
                      await widget.submission
                          .upvote(waitForResponse: true);
                    } else {
                      setState(() {
                        _voteState = VoteState.none;
                        _setWidgets();
                      });
                      await widget.submission
                          .clearVote(waitForResponse: true);
                    }
                  },
                  onLongPress: _archived
                      ? null
                      : () async {
                    Feedback.forTap(context);
                    if (_voteState == VoteState.none) {
                      setState(() {
                        _voteState = VoteState.downvoted;
                        _setWidgets();
                      });
                      await widget.submission
                          .downvote(waitForResponse: true);
                    } else {
                      setState(() {
                        _voteState = VoteState.none;
                        _setWidgets();
                      });
                      await widget.submission
                          .clearVote(waitForResponse: true);
                    }
                  },
                ),
              ),
              ConfettiWidget(
                emissionFrequency: 0.2,
                numberOfParticles: 10,
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                colors: widget.confettiColors ??
                    [
                      Colors.blue,
                      Colors.green,
                      Colors.orange,
                      Colors.pink,
                      Colors.purple
                    ],
              ),
            ],
          ),
        ),
        (widget.mini
            ? Container()
            : IconTextButtonSubtext(
          subtext: _subtext,
          subtextColor: _archived == null
              ? this.widget.subtextColor == null
              ? Colors.grey.withOpacity(0.6)
              : (this.widget.subtextColor.withOpacity(0.6))
              : this.widget.subtextColor,
        ))
      ],
    );
  }
}
