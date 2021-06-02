import 'dart:async';
import 'package:gwa_app/screens/home/local_widgets/home_section_page.dart';
import 'package:gwa_app/states/global_state.dart';
import 'package:gwa_app/widgets/animations%20and%20transitions/transitions.dart';
import 'package:provider/provider.dart';
import 'package:clickable_list_wheel_view/clickable_list_wheel_widget.dart';
import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gwa_app/models/gwa_submission_preview.dart';
import 'package:gwa_app/widgets/gradient_appbar_flexible_space.dart';
import 'package:gwa_app/widgets/gwa_list_item.dart';
import 'package:gwa_app/utils/util_functions.dart';

//FIXME: Sometimes certain lists don't load.
class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text('Home'),
          elevation: 15.0,
          backgroundColor: Colors.transparent,
          flexibleSpace: GradientAppBarFlexibleSpace(),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              print('The app bar leading button has been pressed');
              // Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _HomeSection(
              title: 'Top Posts of The Month',
              waitDuration: Duration(milliseconds: 800),
              contentStream: Provider.of<GlobalState>(context, listen: false)
                  .getTopStream(TimeFilter.month, 21),
              homeSectionPageContentStream:
                  Provider.of<GlobalState>(context, listen: false)
                      .getTopStream(TimeFilter.month, 99),
            ),
            _HomeSection(
              title: 'Top Posts of The Week',
              waitDuration: Duration(milliseconds: 700),
              contentStream: Provider.of<GlobalState>(context, listen: false)
                  .getTopStream(TimeFilter.week, 21),
              homeSectionPageContentStream:
                  Provider.of<GlobalState>(context, listen: false)
                      .getTopStream(TimeFilter.week, 99),
            ),
            _HomeSection(
              title: 'Hot Posts',
              waitDuration: Duration(milliseconds: 600),
              contentStream: Provider.of<GlobalState>(context, listen: false)
                  .getHotStream(21),
              homeSectionPageShufflePages: true,
              homeSectionPageContentStream:
                  Provider.of<GlobalState>(context, listen: false)
                      .getHotStream(99),
            )
          ],
        ),
      ),
    );
  }
}

class _HorizontalClickableListWheelScrollView extends StatefulWidget {
  const _HorizontalClickableListWheelScrollView({
    Key key,
    @required this.itemList,
    this.itemSize,
    this.offAxisFraction,
    this.squeeze,
  }) : super(key: key);

  final List<GwaLibraryListItem> itemList;
  final double itemSize;
  final double offAxisFraction;
  final double squeeze;

  @override
  __HorizontalClickableListWheelScrollViewState createState() =>
      __HorizontalClickableListWheelScrollViewState();
}

class __HorizontalClickableListWheelScrollViewState
    extends State<_HorizontalClickableListWheelScrollView> {
  final _scrollController = FixedExtentScrollController(initialItem: 1);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: this.widget.itemSize == null ? 170 : this.widget.itemSize * 1.14,
      child: RotatedBox(
        quarterTurns: -1,
        child: ClickableListWheelScrollView(
          scrollController: _scrollController,
          itemHeight: this.widget.itemSize ?? 150,
          itemCount: widget.itemList.length,
          onItemTapCallback: (index) {
            Timer(Duration(milliseconds: 600), () {
              pushSubmissionPageWithReturnData(
                  context, widget.itemList.elementAt(index).fullname, false);
            });
          },
          child: ListWheelScrollView.useDelegate(
            offAxisFraction: this.widget.offAxisFraction ?? 0.0,
            controller: _scrollController,
            itemExtent: this.widget.itemSize ?? 150,
            perspective: 0.002,
            squeeze: this.widget.squeeze ?? 1.0,
            physics:
                BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            childDelegate: ListWheelChildBuilderDelegate(
                childCount: widget.itemList.length,
                builder: (BuildContext context, int index) {
                  return RotatedBox(
                    quarterTurns: 1,
                    child: SizedBox(
                      width: this.widget.itemSize ?? 150.0,
                      height: this.widget.itemSize ?? 150.0,
                      child: widget.itemList.elementAt(index),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}

class _HorizontalClickableListWheelScrollViewStream extends StatefulWidget {
  const _HorizontalClickableListWheelScrollViewStream({
    Key key,
    @required this.stream,
    this.itemSize,
    this.offAxisFraction,
    this.squeeze,
  }) : super(key: key);

  final Stream<UserContent> stream;
  final double itemSize;
  final double offAxisFraction;
  final double squeeze;

  @override
  _HorizontalClickableListWheelScrollViewStreamState createState() =>
      _HorizontalClickableListWheelScrollViewStreamState();
}

class _HorizontalClickableListWheelScrollViewStreamState
    extends State<_HorizontalClickableListWheelScrollViewStream> {
  StreamController<UserContent> _streamController;
  List<GwaLibraryListItem> _itemList = [];

  @override
  void initState() {
    _streamController = StreamController.broadcast();
    _streamController.stream.listen((event) {
      Submission submission = event;
      GwaSubmissionPreview preview = new GwaSubmissionPreview(submission);
      this._itemList.add(GwaLibraryListItem(
            title: preview.title,
            fullname: preview.fullname,
            thumbnailUrl: preview.thumbnailUrl,
          ));
    });
    widget.stream.pipe(_streamController);
    super.initState();
  }

  @override
  void dispose() {
    _streamController.close();
    _streamController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: this.widget.stream,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          return AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) =>
                  FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
              child: snapshot.hasData
                  ? _HorizontalClickableListWheelScrollView(
                      itemList: this._itemList,
                      itemSize: widget.itemSize,
                      offAxisFraction: widget.offAxisFraction,
                      squeeze: widget.squeeze,
                    )
                  : _DummyList(
                      itemSize: widget.itemSize ?? 150,
                    ));
        });
  }
}

class _DummyList extends StatefulWidget {
  const _DummyList({
    Key key,
    this.itemSize,
  }) : super(key: key);
  final double itemSize;

  @override
  _DummyListState createState() => _DummyListState();
}

class _DummyListState extends State<_DummyList> {
  final _scrollController = FixedExtentScrollController(initialItem: 1);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.itemSize * 1.14,
      child: RotatedBox(
        quarterTurns: -1,
        child: ListWheelScrollView.useDelegate(
          controller: _scrollController,
          offAxisFraction: 0.0,
          itemExtent: widget.itemSize,
          perspective: 0.002,
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          childDelegate: ListWheelChildBuilderDelegate(
              childCount: 3,
              builder: (BuildContext context, int index) {
                return RotatedBox(
                  quarterTurns: 1,
                  child: SizedBox(
                    width: widget.itemSize,
                    height: widget.itemSize,
                    child: DummyListItem(),
                  ),
                );
              }),
        ),
      ),
    );
  }
}

class _HomeSection extends StatefulWidget {
  const _HomeSection({
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

class __HomeSectionState extends State<_HomeSection>
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
                      child: _HorizontalClickableListWheelScrollViewStream(
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
