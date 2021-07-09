import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:eavesdrop/widgets/gwa_list_item.dart';

class DummyList extends StatefulWidget {
  const DummyList({
    Key key,
    this.itemSize,
  }) : super(key: key);
  final double itemSize;

  @override
  _DummyListState createState() => _DummyListState();
}

class _DummyListState extends State<DummyList> {
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