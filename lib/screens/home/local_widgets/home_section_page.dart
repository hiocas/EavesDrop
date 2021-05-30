import 'dart:async';
import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gwa_app/models/gwa_submission_preview.dart';
import 'package:gwa_app/screens/submission_page/submission_page.dart';
import 'package:gwa_app/widgets/animations%20and%20transitions/transitions.dart';
import 'package:gwa_app/widgets/gwa_list_item.dart';
import 'package:gwa_app/widgets/gwa_scrollbar.dart';

class HomeSectionPage extends StatefulWidget {
  const HomeSectionPage({
    Key key,
    @required this.sectionTitle,
    @required this.contentStream,
    this.pageShowOnlyPictures,
    this.maxPages,
  }) : super(key: key);

  final String sectionTitle;
  final Stream<UserContent> contentStream;

  /// If true, [_HomeSectionPageView] will show only submissions with
  /// a thumbnail picture that isn't the default one.
  /// If false, [_HomeSectionPageView] will show randomly selected submissions
  /// from the contentStream.
  final bool pageShowOnlyPictures;
  final int maxPages;

  @override
  _HomeSectionPageState createState() => _HomeSectionPageState();
}

class _HomeSectionPageState extends State<HomeSectionPage> {
  StreamController<UserContent> _streamController;
  List<GwaSubmissionPreviewWithAuthor> _submissionsList = [];

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
      appBar: AppBar(
        titleSpacing: 0.0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .backgroundColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.0),
                  bottomRight: Radius.circular(24.0))),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) =>
              LinearGradient(
                colors: [
                  Theme
                      .of(context)
                      .primaryColor,
                  Theme
                      .of(context)
                      .accentColor,
                ],
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: Text(
            widget.sectionTitle,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 26.0),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Theme
          .of(context)
          .backgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 90.0),
        child: StreamBuilder(
            stream: widget.contentStream,
            builder: (context, snapshot) {
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder:
                    (Widget child, Animation<double> animation) =>
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
                  } else {
                    _pageList = List<GwaSubmissionPreviewWithAuthor>.from(
                        _submissionsList);
                    _pageList.shuffle();
                    _pageList.sublist(0, widget.maxPages ?? 15);
                  }
                  return GwaScrollbar(
                    child: CustomScrollView(
                      physics: BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      slivers: [
                        SliverToBoxAdapter(
                            child: _HomeSectionPageView(
                              previews: _pageList,
                            )),
                        SliverToBoxAdapter(
                            child: Divider(
                                color: Theme
                                    .of(context)
                                    .primaryColor,
                                indent: 12.0,
                                endIndent: 12.0)),
                        _SubmissionList(
                          submissionList: _submissionsList,
                        ),
                      ],
                    ),
                  );
                })
                    : _DummyPage(),
              );
            }),
      ),
    );
  }
}

class _SubmissionList extends StatelessWidget {
  const _SubmissionList({
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

// THIS IS NOT MY DESIGN AND CODE I LOOKED AT A TUTORIAL BY Marcus Ng.
class _HomeSectionPageView extends StatefulWidget {
  const _HomeSectionPageView({
    Key key,
    @required this.previews,
  }) : super(key: key);

  final List<GwaSubmissionPreviewWithAuthor> previews;

  @override
  _HomeSectionPageViewState createState() => _HomeSectionPageViewState();
}

class _HomeSectionPageViewState extends State<_HomeSectionPageView> {
  PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    this._pageController = PageController(viewportFraction: 0.9);
    // Auto Scroll Pages:
    Timer.periodic(Duration(seconds: 8), (timer) {
      if (this._currentPage < widget.previews.length) {
        this._currentPage++;
      } else {
        this._currentPage = 0;
      }

      /* To get rid of errors that happen when the page controller isn't
      attached to any scroll views. */
      if (this._pageController.hasClients) {
        this._pageController.animateToPage(_currentPage,
            duration: Duration(milliseconds: 800),
            curve: Curves.easeInOutQuint);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.0,
      child: PageView.builder(
        controller: this._pageController,
        itemCount: widget.previews.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SubmissionPage(
                        submissionFullname: widget.previews[index].fullname,
                        fromLibrary: false,
                      ),
                ),
              );
            },
            child: Container(
              margin:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              width: 120.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                image: DecorationImage(
                  image: NetworkImage(
                    widget.previews[index].thumbnailUrl,
                  ),
                  fit: BoxFit.cover,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0.0, 2.0),
                    blurRadius: 6.0,
                  )
                ],
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 4.0, 16.0),
                    child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.previews[index].title,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(widget.previews[index].author,
                                style: TextStyle(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.0),
                                overflow: TextOverflow.ellipsis),
                          ],
                        )),
                  ),
                ],
              ),
            ),
          );
        },
        onPageChanged: (int pageIndex) {
          this._currentPage = pageIndex;
        },
      ),
    );
  }
}

class _DummyPage extends StatefulWidget {
  const _DummyPage({
    Key key,
    this.crossAxisCount,
  }) : super(key: key);

  final int crossAxisCount;

  @override
  __DummyPageState createState() => __DummyPageState();
}

class __DummyPageState extends State<_DummyPage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 500,
        ));
    Timer(Duration(milliseconds: 500), () => _animationController.forward());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideFadeTransition(
      animationController: this._animationController,
      beginOffset: Offset(0.0, 0.02),
      child: CustomScrollView(
        physics: NeverScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _DummyHomeSectionPageView(),
          ),
          SliverToBoxAdapter(
              child: Divider(
                  color: Theme
                      .of(context)
                      .primaryColor,
                  indent: 12.0,
                  endIndent: 12.0)),
          _DummySubmissionList(
            crossAxisCount: this.widget.crossAxisCount,
          ),
        ],
      ),
    );
  }
}

class _DummyHomeSectionPageView extends StatefulWidget {
  const _DummyHomeSectionPageView({Key key}) : super(key: key);

  @override
  __DummyHomeSectionPageViewState createState() =>
      __DummyHomeSectionPageViewState();
}

class __DummyHomeSectionPageViewState extends State<_DummyHomeSectionPageView> {
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    this._pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    this._pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.0,
      child: PageView.builder(
        controller: _pageController,
        itemCount: 2,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            width: 120.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.grey[900],
                ],
              ),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0.0, 2.0),
                  blurRadius: 6.0,
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DummySubmissionList extends StatelessWidget {
  const _DummySubmissionList({Key key, this.crossAxisCount}) : super(key: key);

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
            return DummyListItem();
          },
          childCount: 12,
        ),
      ),
    );
  }
}
