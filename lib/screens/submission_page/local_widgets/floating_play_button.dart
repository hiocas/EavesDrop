import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gwa_app/models/gwa_submission.dart';
import 'package:gwa_app/utils/util_functions.dart';
import 'package:gwa_app/widgets/navigator_routes/hero_dialog_route.dart';
import 'package:gwa_app/widgets/rect_tweens/calm_rect_tween.dart';
import 'package:gwa_app/widgets/website_viewer.dart';
import 'dart:math' as Math;

class FloatingPlayButton extends StatefulWidget {
  const FloatingPlayButton({
    Key key,
    @required this.submission,
    this.heroTag,
    @required this.scrollController,
  }) : super(key: key);

  final GwaSubmission submission;
  final String heroTag;
  final ScrollController scrollController;

  @override
  _FloatingPlayButtonState createState() => _FloatingPlayButtonState();
}

class _FloatingPlayButtonState extends State<FloatingPlayButton>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  bool _isFABVisible;

  @override
  void initState() {
    super.initState();
    double alwaysShowFABAt;
    ScrollDirection showDirection = ScrollDirection.forward;
    ScrollDirection hideDirection = ScrollDirection.reverse;
    bool canHideFAB = true;
    _isFABVisible = true;
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 500));
    widget.scrollController.addListener(() {
      // To avoid a null error.
      if (widget.scrollController.position.hasContentDimensions) {
        // TODO: Make this less messy...
        alwaysShowFABAt = Math.max(
            widget.scrollController.position.maxScrollExtent -
                widget.scrollController.position.maxScrollExtent * 0.3,
            0);
        canHideFAB = widget.scrollController.offset < alwaysShowFABAt;
        if (canHideFAB &&
            widget.scrollController.position.userScrollDirection ==
                hideDirection) {
          if (_isFABVisible) {
            setState(() {
              _isFABVisible = false;
              _animationController.forward();
            });
          }
        } else if (widget.scrollController.position.userScrollDirection ==
            showDirection) {
          if (!_isFABVisible) {
            setState(() {
              _isFABVisible = true;
              _animationController.reverse();
            });
          }
        } else if (!canHideFAB) {
          setState(() {
            _isFABVisible = true;
            _animationController.reverse();
          });
        }

        // Switch directions.
        if (widget.scrollController.offset >=
            widget.scrollController.position.maxScrollExtent) {
          hideDirection = ScrollDirection.forward;
          showDirection = ScrollDirection.reverse;
        } else if (widget.scrollController.offset <=
            widget.scrollController.position.minScrollExtent) {
          showDirection = ScrollDirection.forward;
          hideDirection = ScrollDirection.reverse;
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position:
          Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 2.0)).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOutQuint,
        ),
      ),
      child: Hero(
        tag: this.widget.heroTag,
        createRectTween: (begin, end) => CalmRectTween(begin: begin, end: end),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            gradient: RadialGradient(
              radius: 4.0,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).cardColor,
              ],
            ),
          ),
          width: 220.0,
          child: RawMaterialButton(
            shape: new CircleBorder(),
            onPressed: () {
              Navigator.of(context).push(HeroDialogRoute(builder: (context) {
                return _PopupCard(
                  submission: this.widget.submission,
                  heroTag: this.widget.heroTag,
                );
              }));
            },
            child: Icon(
              Icons.play_arrow,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _PopupCard extends StatelessWidget {
  final String heroTag;
  final GwaSubmission submission;

  const _PopupCard({
    Key key,
    @required this.heroTag,
    @required this.submission,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Hero(
          tag: this.heroTag,
          createRectTween: (begin, end) =>
              CalmRectTween(begin: begin, end: end),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 700.0,
            ),
            child: Material(
              color: Theme.of(context).backgroundColor,
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0)),
              child: Builder(builder: (context) {
                if (submission.audioUrls.length == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Couldn't find a Soundgasm.net url to launch.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.1),
                              fontSize: 22.0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).primaryColor)),
                              onPressed: () {
                                //First pop this page.
                                Navigator.pop(context);
                                //Then pop submission page and send data.
                                popSubmissionPageWithData(
                                  context,
                                  query: submission.title,
                                  sort: Sort.relevance,
                                  timeFilter: TimeFilter.all,
                                );
                              },
                              icon: Icon(Icons.search),
                              label: Text('Search Fills'),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(14.0),
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(color: Colors.black),
                  itemBuilder: (context, index) {
                    return Container(
                      // decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.black, width: 3.0))),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WebsiteViewer(
                                title: submission.title,
                                url: submission.audioUrls[index],
                              ),
                            ),
                          );
                        },
                        title: Text(
                          getUrlTitle(submission.audioUrls[index]),
                          style: TextStyle(
                            color: Colors.grey[300],
                          ),
                        ),
                        subtitle: Text(
                          submission.audioUrls[index],
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: submission.audioUrls.length,
                  shrinkWrap: true,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
