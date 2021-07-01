import 'dart:async';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:gwa_app/models/gwa_submission_preview.dart';
import 'package:gwa_app/utils/util_functions.dart';

import 'dummy_flat_home_list_view.dart';

class FlatHomeListViewStream extends StatefulWidget {
  const FlatHomeListViewStream({
    Key key,
    @required this.contentStream,
    @required this.size,
    @required this.sizeRatio,
  }) : super(key: key);

  final Stream<UserContent> contentStream;
  final double size;
  final double sizeRatio;

  @override
  _FlatHomeListViewStreamState createState() => _FlatHomeListViewStreamState();
}

class _FlatHomeListViewStreamState extends State<FlatHomeListViewStream> {
  StreamController<UserContent> _streamController;
  List<GwaSubmissionPreview> previews = [];

  @override
  void initState() {
    _streamController = StreamController.broadcast();
    _streamController.stream.listen((event) {
      Submission submission = event;
      this.previews.add(GwaSubmissionPreview(submission));
    });
    widget.contentStream.pipe(_streamController);
    super.initState();
  }

  @override
  void dispose() {
    _streamController.close();
    _streamController = null;
    previews.clear();
    previews = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
              ? FlatHomeListView(
                  previews: previews,
                  size: widget.size,
                  sizeRatio: widget.sizeRatio)
              : DummyFlatHomeListView(
                  size: widget.size, sizeRatio: widget.sizeRatio, length: 3),
        );
      },
    );
  }
}

class FlatHomeListView extends StatelessWidget {
  const FlatHomeListView({
    Key key,
    @required this.previews,
    @required this.size,
    @required this.sizeRatio,
  }) : super(key: key);

  final List<GwaSubmissionPreview> previews;
  final double size;
  final double sizeRatio;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemExtent: this.size * this.sizeRatio,
      scrollDirection: Axis.horizontal,
      itemCount: this.previews.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: _FlatHomeListViewItem(
              preview: this.previews[index],
              size: this.size,
              sizeRatio: this.sizeRatio),
        );
      },
    );
  }
}

class _FlatHomeListViewItem extends StatelessWidget {
  const _FlatHomeListViewItem({
    Key key,
    @required this.preview,
    @required this.size,
    @required this.sizeRatio,
  }) : super(key: key);

  final GwaSubmissionPreview preview;
  final double size;
  final double sizeRatio;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.size * this.sizeRatio,
      height: this.size,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10.0),
        image: DecorationImage(
          image: NetworkImage(
            this.preview.thumbnailUrl,
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
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.0),
          onTap: () {
            pushSubmissionPageWithReturnData(context, this.preview.fullname);
          },
          onLongPress: () {},
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 4.0, 8.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    this.preview.title,
                    maxLines: 2,
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
