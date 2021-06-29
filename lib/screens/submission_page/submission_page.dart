import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gwa_app/models/hive_boxes.dart';
import 'package:gwa_app/utils/util_functions.dart';
import 'package:gwa_app/widgets/markdown_viewer.dart';
import 'package:gwa_app/models/gwa_submission.dart';
import 'local_widgets/all_page_local.dart';
import 'package:provider/provider.dart';
import 'package:gwa_app/states/global_state.dart';

/* FIXME: If we search for certain queries (for instance
    'authorLookingForMyBlueSky') in SubmissionList and then press on them
    to open their SubmissionPage sometimes the page will get stuck and the
    whole app will freeze. */
class SubmissionPage extends StatefulWidget {
  final String submissionFullname;

  ///Are we coming here from the [Library] page?
  final bool fromLibrary;

  const SubmissionPage({
    Key key,
    this.submissionFullname,
    @required this.fromLibrary,
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
          return RefreshIndicator(
            color: Theme.of(context).accentColor,
            backgroundColor: Theme.of(context).backgroundColor,
            /*TODO: Implement pull to refresh without pushing a new route (it
                looks confusing and a bit jarring). */
            onRefresh: () {
              /*FIXME: This makes it so we can't search using tags after
                 refreshing. */
              pushReplacementSubmissionPageWithReturnData(
                  context, widget.submissionFullname, widget.fromLibrary);
              return Future.value();
            },
            child: Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              body: SafeArea(
                child: Container(
                  color: Theme.of(context).backgroundColor,
                  child: CustomScrollView(
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
                          fromLibrary: widget.fromLibrary),
                      //MarkdownViewer
                      SliverPadding(
                        padding: const EdgeInsets.all(10.0),
                        sliver: SliverToBoxAdapter(
                            child: GestureDetector(
                          behavior: HitTestBehavior.deferToChild,
                          onTap: () {
                            print('Hide button');
                            if (_floatingPlayButtonKey.currentState.animates) {
                              _floatingPlayButtonKey.currentState
                                  .animateButton();
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
                                fromLibrary: widget.fromLibrary,
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
                ),
              ),
              floatingActionButton: FloatingPlayButton(
                key: _floatingPlayButtonKey,
                heroTag: 'floating-play-button-popup',
                submission: _submission,
                scrollController: _scrollController,
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            ),
          );
        }
      },
    );
  }
}
