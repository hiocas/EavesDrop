import 'package:eavesdrop/models/reddit_award.dart';
import 'package:flutter/material.dart';

class RedditAwardCount extends StatelessWidget {
  final RedditAward redditAward;
  final double size;
  final double space;
  final TextStyle counterTextStyle;

  const RedditAwardCount({
    Key key,
    @required this.redditAward,
    this.size = 16.0,
    this.space = 2.0,
    this.counterTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Image.network(
            redditAward.resizedIcons.first.url,
            width: size,
            height: size,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Material(shape: CircleBorder());
            },
          ),
          SizedBox(width: space),
          Text(
            redditAward.count.toString(),
            style: counterTextStyle == null
                ? TextStyle(fontSize: size)
                : counterTextStyle.copyWith(fontSize: size),
          ),
        ],
      ),
    );
  }
}

class RedditAwardCounts extends StatefulWidget {
  final List<RedditAward> awards;
  final double size;
  final double countSpacing;
  final double spacing;
  final int maxAwards;
  final TextStyle counterTextStyle;

  const RedditAwardCounts({
    Key key,
    @required this.awards,
    this.size = 9.0,
    this.countSpacing = 2.0,
    this.spacing = 2.0,
    this.maxAwards,
    this.counterTextStyle,
  }) : super(key: key);

  @override
  _RedditAwardCountsState createState() => _RedditAwardCountsState();
}

class _RedditAwardCountsState extends State<RedditAwardCounts> {
  int length;
  List<Widget> redditAwardCounts;

  @override
  void initState() {
    if (widget.maxAwards == null) {
      length = widget.awards.length;
    } else if (widget.maxAwards < widget.awards.length) {
      length = widget.maxAwards + 1;
    } else {
      length = widget.awards.length;
    }
    redditAwardCounts = List.generate(length, (index) {
      if (index == 0)
        return RedditAwardCount(
          redditAward: widget.awards[index],
          size: widget.size,
          space: widget.countSpacing,
          counterTextStyle: widget.counterTextStyle,
        );
      else {
        if (widget.maxAwards != null &&
            widget.maxAwards < widget.awards.length &&
            index == length - 1) {
          return Text(
            '...',
            style: widget.counterTextStyle == null
                ? TextStyle(fontSize: widget.size)
                : widget.counterTextStyle.copyWith(fontSize: widget.size),
          );
        }
      }
      return Padding(
        padding: EdgeInsets.only(left: widget.spacing),
        child: RedditAwardCount(
          redditAward: widget.awards[index],
          size: widget.size,
          space: widget.countSpacing,
          counterTextStyle: widget.counterTextStyle,
        ),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: redditAwardCounts,
    );
  }
}

class RedditAwardCountsWrap extends StatefulWidget {
  final List<RedditAward> awards;
  final double size;
  final double countSpacing;
  final double spacing;
  final int maxAwards;
  final TextStyle counterTextStyle;
  final Widget leading;

  const RedditAwardCountsWrap({
    Key key,
    @required this.awards,
    this.size = 9.0,
    this.countSpacing = 2.0,
    this.spacing = 2.0,
    this.maxAwards,
    this.counterTextStyle,
    this.leading,
  }) : super(key: key);

  @override
  _RedditAwardCountsWrapState createState() => _RedditAwardCountsWrapState();
}

class _RedditAwardCountsWrapState extends State<RedditAwardCountsWrap> {
  int length;
  List<Widget> redditAwardCounts;

  @override
  void initState() {
    if (widget.maxAwards == null) {
      length = widget.awards.length;
    } else if (widget.maxAwards < widget.awards.length) {
      length = widget.maxAwards + 1;
    } else {
      length = widget.awards.length;
    }
    if (widget.leading == null) {
      redditAwardCounts = [];
    } else {
      redditAwardCounts = [widget.leading];
    }
    redditAwardCounts.addAll(List.generate(length, (index) {
      if (index == 0)
        return RedditAwardCount(
          redditAward: widget.awards[index],
          size: widget.size,
          space: widget.countSpacing,
          counterTextStyle: widget.counterTextStyle,
        );
      else {
        if (widget.maxAwards != null &&
            widget.maxAwards < widget.awards.length &&
            index == length - 1) {
          return Text(
            '...',
            style: TextStyle(fontSize: widget.size),
          );
        }
      }
      return Padding(
        padding: EdgeInsets.only(left: widget.spacing),
        child: RedditAwardCount(
          redditAward: widget.awards[index],
          size: widget.size,
          space: widget.countSpacing,
          counterTextStyle: widget.counterTextStyle,
        ),
      );
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: redditAwardCounts,
    );
  }
}
