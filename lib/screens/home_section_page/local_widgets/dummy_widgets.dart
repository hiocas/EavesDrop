import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eavesdrop/widgets/animations%20and%20transitions/transitions.dart';
import 'package:eavesdrop/widgets/gwa_list_item.dart';

class DummyPage extends StatefulWidget {
  const DummyPage({
    Key key,
    this.crossAxisCount,
  }) : super(key: key);

  final int crossAxisCount;

  @override
  _DummyPageState createState() => _DummyPageState();
}

class _DummyPageState extends State<DummyPage>
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
      animation: this._animationController,
      beginOffset: Offset(0.0, 0.02),
      child: CustomScrollView(
        physics: NeverScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: DummyHomeSectionPageView(),
          ),
          SliverToBoxAdapter(
              child: Divider(
                  color: Theme.of(context).primaryColor,
                  indent: 12.0,
                  endIndent: 12.0)),
          DummySubmissionList(
            crossAxisCount: this.widget.crossAxisCount,
          ),
        ],
      ),
    );
  }
}

class DummyHomeSectionPageView extends StatefulWidget {
  const DummyHomeSectionPageView({Key key}) : super(key: key);

  @override
  _DummyHomeSectionPageViewState createState() =>
      _DummyHomeSectionPageViewState();
}

class _DummyHomeSectionPageViewState extends State<DummyHomeSectionPageView> {
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
      height: 230.0,
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

class DummySubmissionList extends StatelessWidget {
  const DummySubmissionList({Key key, this.crossAxisCount}) : super(key: key);

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