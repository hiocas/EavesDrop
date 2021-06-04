import 'dart:async';
import 'package:gwa_app/screens/home_section_page/home_section_page.dart';
import 'package:gwa_app/widgets/animations%20and%20transitions/transitions.dart';
import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'horizontal_list_wheel_scrollviews.dart';

class HomeSection extends StatefulWidget {
  const HomeSection({
    Key key,
    @required this.title,
    @required this.contentStream,
    this.animationDuration,
    this.waitDuration,
    this.homeSectionPageContentStream,
    this.homeSectionPageShowOnlyPictures,
    this.homeSectionPageMaxPages,
    this.homeSectionPageShufflePages,
    this.itemSize,
    this.offAxisFraction,
    this.squeeze,
  }) : super(key: key);

  final String title;
  final Stream<UserContent> contentStream;
  final Duration animationDuration;
  final Stream<UserContent> homeSectionPageContentStream;
  final bool homeSectionPageShowOnlyPictures;
  final bool homeSectionPageShufflePages;
  final int homeSectionPageMaxPages;
  final double itemSize;
  final double offAxisFraction;
  final double squeeze;

  /// The Duration to wait after instantiating this widget before playing the
  /// initial load animation.
  final Duration waitDuration;

  @override
  __HomeSectionState createState() => __HomeSectionState();
}

class __HomeSectionState extends State<HomeSection>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this,
        duration: widget.animationDuration ?? Duration(milliseconds: 500));
    Timer(widget.waitDuration ?? Duration(seconds: 1),
            () => _animationController.forward());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SlideFadeTransition(
        animationController: this._animationController,
        child: Container(
          child: Material(
            color: Theme.of(context).backgroundColor,
            elevation: 15.0,
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
            child: InkWell(
              onLongPress: () {
                if (widget.homeSectionPageContentStream != null) {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => HomeSectionPage(
                          sectionTitle: widget.title,
                          pageShowOnlyPictures:
                          widget.homeSectionPageShowOnlyPictures,
                          shufflePages: widget.homeSectionPageShufflePages,
                          maxPages: widget.homeSectionPageMaxPages,
                          contentStream: widget.homeSectionPageContentStream),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.all(Radius.circular(24.0)),
              highlightColor: Theme.of(context).primaryColor.withOpacity(0.3),
              splashColor: Theme.of(context).primaryColor.withOpacity(0.5),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: Column(
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
                    Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          radius: 2.5,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).accentColor,
                          ],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(24.0)),
                      ),
                      child: HorizontalClickableListWheelScrollViewStream(
                        stream: this.widget.contentStream,
                        itemSize: widget.itemSize ?? 130,
                        offAxisFraction: widget.offAxisFraction,
                        squeeze: widget.squeeze,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}