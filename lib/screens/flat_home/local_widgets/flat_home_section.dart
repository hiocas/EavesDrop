import 'dart:async';
import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eavesdrop/screens/flat_home/local_widgets/flat_home_list_view.dart';
import 'package:eavesdrop/screens/flat_home/new_home.dart';
import 'package:eavesdrop/screens/home_section_page/home_section_page.dart';
import 'package:eavesdrop/widgets/animations%20and%20transitions/transitions.dart';

class FlatHomeSection extends StatefulWidget {
  const FlatHomeSection({
    Key key,
    @required this.title,
    @required this.contentStream,
    @required this.animate,
    this.animationDuration = const Duration(milliseconds: 500),
    this.waitDuration = const Duration(seconds: 1),
    @required this.homeSectionPageContentStream,
    this.homeSectionPageShowOnlyPictures,
    this.homeSectionPageShufflePages,
    this.homeSectionPageMaxPages,
    this.size,
    this.sizeRatio = 1.5,
    this.showAuthors = false,
    this.textSize,
    this.authorTextSize,
  }) : super(key: key);

  final String title;
  final Stream<UserContent> contentStream;
  final Stream<UserContent> homeSectionPageContentStream;
  final bool homeSectionPageShowOnlyPictures;
  final bool homeSectionPageShufflePages;
  final int homeSectionPageMaxPages;
  final double size;
  final double sizeRatio;

  final bool animate;
  final Duration animationDuration;
  final Duration waitDuration;

  final bool showAuthors;

  final double textSize;
  final double authorTextSize;

  @override
  _FlatHomeSectionState createState() => _FlatHomeSectionState();
}

class _FlatHomeSectionState extends State<FlatHomeSection>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this,
        duration: widget.animate ? widget.animationDuration : Duration.zero);
    Timer(widget.animate ? widget.waitDuration : Duration.zero, () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    if (AnimateOnce.animate) {
      AnimateOnce.animate = false;
    }
    _animationController.dispose();
    _animationController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideFadeTransition(
      animation: this._animationController,
      beginOffset: const Offset(0.0, -0.06),
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: const BorderRadius.only(
                bottomLeft: const Radius.circular(10.0),
                topLeft: const Radius.circular(10.0),
                topRight: const Radius.circular(10.0)),
            onLongPress: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => HomeSectionPage(
                      sectionTitle: this.widget.title,
                      pageShowOnlyPictures:
                          this.widget.homeSectionPageShowOnlyPictures,
                      shufflePages: this.widget.homeSectionPageShufflePages,
                      maxPages: this.widget.homeSectionPageMaxPages,
                      contentStream: this.widget.homeSectionPageContentStream),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    this.widget.title,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  height: this.widget.size,
                  width: MediaQuery.of(context).size.width,
                  child: FlatHomeListViewStream(
                    contentStream: this.widget.contentStream,
                    showAuthors: this.widget.showAuthors,
                    textSize: this.widget.textSize,
                    authorTextSize: this.widget.authorTextSize,
                    size: this.widget.size,
                    sizeRatio: this.widget.sizeRatio,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
