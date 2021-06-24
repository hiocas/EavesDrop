import 'dart:async';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:gwa_app/models/gwa_submission_preview.dart';
import 'package:gwa_app/widgets/gradient_title_appbar.dart';
import 'package:gwa_app/widgets/gwa_scrollbar.dart';
import 'local_widgets/dummy_widgets.dart';
import 'local_widgets/home_section_page_submission_list.dart';
import 'local_widgets/home_section_page_view.dart';

class HomeSectionPage extends StatefulWidget {
  const HomeSectionPage({
    Key key,
    @required this.sectionTitle,
    @required this.contentStream,
    this.pageShowOnlyPictures,
    this.maxPages,
    this.shufflePages,
  }) : super(key: key);

  final String sectionTitle;
  final Stream<UserContent> contentStream;

  /// If true, [HomeSectionPageView] will show only submissions with
  /// a thumbnail picture that isn't the default one.
  /// If false, [HomeSectionPageView] will show randomly selected submissions
  /// from the contentStream.
  final bool pageShowOnlyPictures;

  /// If true, [HomeSectionPageView] will display a shuffled list based on
  /// [contentStream].
  /// If false, the order of the pages will remain as the order of [contentStream].
  final bool shufflePages;
  final int maxPages;

  @override
  _HomeSectionPageState createState() => _HomeSectionPageState();
}

class _HomeSectionPageState extends State<HomeSectionPage> {
  StreamController<UserContent> _streamController;
  List<GwaSubmissionPreviewWithAuthor> _submissionsList = [];

  final double pushFromTop = 90.0;

  @override
  void initState() {
    _streamController = StreamController.broadcast();
    _streamController.stream.listen((event) {
      Submission submission = event;
      this._submissionsList.add(GwaSubmissionPreviewWithAuthor(submission));
    });
    widget.contentStream.pipe(_streamController);
    super.initState();
  }

  @override
  void dispose() {
    _streamController.close();
    _streamController = null;
    _submissionsList.clear();
    _submissionsList = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientTitleAppBar(context, title: widget.sectionTitle),
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).backgroundColor,
      body: StreamBuilder(
          stream: widget.contentStream,
          builder: (context, snapshot) {
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) =>
                  FadeTransition(
                opacity: animation,
                child: child,
              ),
              child: snapshot.hasData
                  ? Builder(builder: (context) {
                      List<GwaSubmissionPreviewWithAuthor> _pageList;
                      if (widget.pageShowOnlyPictures ?? false) {
                        _pageList = [];
                        int count = 0;
                        for (var i = 0;
                            i < _submissionsList.length &&
                                count < (widget.maxPages ?? 15);
                            i++) {
                          if (_submissionsList[i].thumbnailUrl !=
                              'https://styles.redditmedia.com/t5_2u463/'
                                  'styles/communityIcon_1lj5xecdisi31.png?'
                                  'width=256&s=98e8187f0403751b02c03e7ffb9f0'
                                  '59ce0ce18d9') {
                            _pageList.add(_submissionsList[i]);
                            count++;
                          }
                        }
                        if (widget.shufflePages ?? false) _pageList.shuffle();
                      } else if (widget.shufflePages ?? false) {
                        _pageList = List<GwaSubmissionPreviewWithAuthor>.from(
                            _submissionsList);
                        _pageList.shuffle();
                        _pageList = _pageList.sublist(0, widget.maxPages ?? 15);
                      } else {
                        _pageList = List<GwaSubmissionPreviewWithAuthor>.from(
                            _submissionsList);
                        _pageList = _pageList.sublist(0, widget.maxPages ?? 15);
                      }
                      return GwaScrollbar(
                        child: CustomScrollView(
                          physics: BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          slivers: [
                            SliverToBoxAdapter(
                                child: SizedBox(height: pushFromTop)),
                            SliverToBoxAdapter(
                                child: HomeSectionPageView(
                              previews: _pageList,
                            )),
                            SliverToBoxAdapter(
                                child: Divider(
                                    color: Theme.of(context).primaryColor,
                                    indent: 12.0,
                                    endIndent: 12.0)),
                            SubmissionList(
                              submissionList: _submissionsList,
                            ),
                          ],
                        ),
                      );
                    })
                  : Padding(
                      padding: EdgeInsets.only(top: pushFromTop),
                      child: DummyPage(),
                    ),
            );
          }),
    );
  }
}
