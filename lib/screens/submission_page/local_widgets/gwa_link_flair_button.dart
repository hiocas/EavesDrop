import 'package:draw/draw.dart';
import 'package:eavesdrop/utils/gwa_functions.dart';
import 'package:flutter/material.dart';
import 'package:eavesdrop/utils/util_functions.dart';

class GwaLinkFlairButton extends StatelessWidget {
  const GwaLinkFlairButton({
    Key key,
    @required this.linkFlair,
    this.width,
    this.height,
    this.padding = const EdgeInsets.only(left: 2.0),
  }) : super(key: key);

  final String linkFlair;
  final double width;
  final double height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final Color flairWidget = GwaFunctions.getLinkFlairTextColor(linkFlair);
    if (flairWidget == null) return Container();
    return Padding(
      padding: padding,
      child: SizedBox(
        width: this.width,
        height: this.height,
        child: Material(
          color: flairWidget,
          borderRadius: BorderRadius.circular(8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(8.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                this.linkFlair,
                style: TextStyle(
                  fontSize: this.height == null ? null : this.height - 1.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            onLongPress: () => popSubmissionPageWithData(
              context,
              query: 'flair_name:"$linkFlair"',
              sort: Sort.relevance,
              timeFilter: TimeFilter.all,
            ),
          ),
        ),
      ),
    );
  }
}
