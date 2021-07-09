import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:eavesdrop/models/hive_boxes.dart';
import 'package:eavesdrop/widgets/markdown_viewer.dart';
import 'package:eavesdrop/models/gwa_submission.dart';
import 'local_widgets/all_page_local.dart';
import 'package:provider/provider.dart';
import 'package:eavesdrop/states/global_state.dart';

class SubmissionPage extends StatefulWidget {
  final String submissionFullname;

  const SubmissionPage({
    Key key,
    this.submissionFullname,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => SubmissionPageState();
}

class SubmissionPageState extends State<SubmissionPage> {
  String _fullname;
  GwaSubmission _submission;
  ScrollController _scrollController;
  GlobalKey<FloatingPlayButtonState> _floatingPlayButtonKey =
      new GlobalKey<FloatingPlayButtonState>();
  bool miniButtons;
  bool _showFPB = true;

  @override
  void initState() {
    super.initState();
    _fullname = widget.submissionFullname;
    if (_fullname.contains('t3_')) {
      _fullname = _fullname.substring(3);
    }
    _scrollController = new ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<Submission> _initSubmissionPage() async {
    final appSettings = await HiveBoxes.getAppSettings();
    miniButtons = appSettings.miniButtons;
    return Provider.of<GlobalState>(context, listen: false)
        .populateSubmission(id: _fullname);
  }

  @override
  Widget build(BuildContext context) {
    /* This keeps track of how many times the user tapped the author name
    so that if it's multiple times we can show them a Snackbar that tells them
    to long press on the author's name if they want to see their submissions. */
    return FutureBuilder(
      future: _initSubmissionPage(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          _submission = new GwaSubmission(snapshot.data);
          _showFPB = _submission.hasAudioUrl || _submission.tags.length > 0;
          return Container(
            color: Theme.of(context).primaryColor,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Theme.of(context).backgroundColor,
                body: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    //App Bar
                    SubmissionPageAppBar(
                      submission: _submission,
                      maxTitleTop: 120,
                      maxTitleAlignTop: 200,
                    ),
                    //Buttons and Tags
                    SubmissionPageButtonsAndTags(
                      mini: miniButtons,
                      submission: _submission,
                      redditSubmission: snapshot.data,
                    ),
                    //MarkdownViewer
                    SliverPadding(
                      padding: const EdgeInsets.all(10.0),
                      sliver: SliverToBoxAdapter(
                          child: GestureDetector(
                        behavior: HitTestBehavior.deferToChild,
                        onTap: () {
                          if (_showFPB &&
                              _floatingPlayButtonKey.currentState.animates) {
                            _floatingPlayButtonKey.currentState.animateButton();
                          }
                        },
                        child: Material(
                          color: Theme.of(context).backgroundColor,
                          elevation: 15.0,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(32.0))),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: MarkdownViewer(
                              text: _submission.selftext,
                              inPopupCard: false,
                              bodyTextFontSize: 14.0,
                            ),
                          ),
                        ),
                      )),
                    ),
                    /*FIXME(Design): This makes sure the SelfTextViewer (now the
                        MarkdownViewer) can be fully read without the floating
                        action button blocking the text at the end of the
                        CustomScrollView. Find a better solution or redesign
                        the ui. */
                    SliverToBoxAdapter(
                      child: Container(
                        height: 70,
                      ),
                    )
                  ],
                ),
                floatingActionButton: _showFPB
                    ? FloatingPlayButton(
                        key: _floatingPlayButtonKey,
                        heroTag: 'floating-play-button-popup',
                        submission: _submission,
                        scrollController: _scrollController,
                      )
                    : null,
                floatingActionButtonLocation:
                    _showFPB ? FloatingActionButtonLocation.centerFloat : null,
              ),
            ),
          );
        }
      },
    );
  }
}
