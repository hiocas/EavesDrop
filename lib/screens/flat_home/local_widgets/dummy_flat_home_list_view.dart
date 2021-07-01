import 'package:flutter/material.dart';

class DummyFlatHomeListView extends StatelessWidget {
  const DummyFlatHomeListView({
    Key key,
    @required this.size,
    @required this.sizeRatio,
    @required this.length,
  }) : super(key: key);

  final double size;
  final double sizeRatio;
  final int length;

  @override
  Widget build(BuildContext context) {
    return ListView(
        itemExtent: this.size * this.sizeRatio,
        scrollDirection: Axis.horizontal,
        children: List.generate(this.length, (index) {
          return Padding(
            padding: const EdgeInsets.all(6.0),
            child: _DummyFlatHomeListViewItem(
              size: this.size,
              sizeRatio: this.sizeRatio,
            ),
          );
        }));
  }
}

class _DummyFlatHomeListViewItem extends StatelessWidget {
  const _DummyFlatHomeListViewItem({
    Key key,
    @required this.size,
    @required this.sizeRatio,
  }) : super(key: key);

  final double size;
  final double sizeRatio;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.size * this.sizeRatio,
      height: this.size,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0.0, 2.0),
            blurRadius: 6.0,
          )
        ],
      ),
      child: Container(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.9), Colors.transparent],
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
