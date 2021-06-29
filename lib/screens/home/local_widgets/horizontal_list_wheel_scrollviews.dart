import 'package:flutter/material.dart';
import 'dart:async';
import 'package:clickable_list_wheel_view/clickable_list_wheel_widget.dart';
import 'package:draw/draw.dart';
import 'package:gwa_app/models/gwa_submission_preview.dart';
import 'package:gwa_app/widgets/gwa_list_item.dart';
import 'package:gwa_app/utils/util_functions.dart';

import 'dummy_list.dart';

class HorizontalClickableListWheelScrollView extends StatefulWidget {
  const HorizontalClickableListWheelScrollView({
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
    extends State<HorizontalClickableListWheelScrollView> {
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
            Feedback.forTap(context);
            Timer(Duration(milliseconds: 600), () {
              pushSubmissionPageWithReturnData(
                  context, widget.itemList.elementAt(index).fullname);
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

class HorizontalClickableListWheelScrollViewStream extends StatefulWidget {
  const HorizontalClickableListWheelScrollViewStream({
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
    extends State<HorizontalClickableListWheelScrollViewStream> {
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
                  ? HorizontalClickableListWheelScrollView(
                itemList: this._itemList,
                itemSize: widget.itemSize,
                offAxisFraction: widget.offAxisFraction,
                squeeze: widget.squeeze,
              )
                  : DummyList(
                itemSize: widget.itemSize ?? 150,
              ));
        });
  }
}
