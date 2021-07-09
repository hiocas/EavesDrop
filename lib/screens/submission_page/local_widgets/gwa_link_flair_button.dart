import 'package:draw/draw.dart';
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

  Color _makeFlairColor() {
    if (this.linkFlair == null || this.linkFlair.isEmpty) return null;
    switch (this.linkFlair) {
      case 'MOD ANNOUNCEMENT':
        return Color.fromARGB(255, 10, 161, 143);
      case 'Improvisation':
        return Color.fromARGB(255, 2, 102, 179);
      case 'Script offer':
        return Color.fromARGB(255, 99, 76, 76);
      case 'OC':
        return Color.fromARGB(255, 204, 172, 43);
      case 'Script Fill':
        return Color.fromARGB(255, 80, 76, 99);
      case 'Ramblefap':
        return Color.fromARGB(255, 0, 115, 115);
      case 'Verification':
        return Color.fromARGB(255, 13, 211, 187);
      case 'Pride Month! 🏳️‍🌈':
        return Color.fromARGB(255, 204, 82, 137);
      case 'Request':
        return Color.fromARGB(255, 73, 73, 73);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color flairWidget = _makeFlairColor();
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
