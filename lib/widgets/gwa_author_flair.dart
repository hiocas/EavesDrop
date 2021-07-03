import 'package:flutter/material.dart';

class GwaAuthorFlair extends StatelessWidget {
  const GwaAuthorFlair({
    Key key,
    @required this.flair,
    this.padding = const EdgeInsets.only(left: 2.0),
    this.width,
    this.height,
  }) : super(key: key);

  final String flair;
  final EdgeInsets padding;
  final double width;
  final double height;

  String _getFlairImagePath() {
    if (this.flair == null || this.flair.isEmpty)
      return '';
    switch (this.flair) {
      case ':NB:Verified!':
        return 'lib/assets/images/GwaNonBinaryAvatar.png';
      case ':trans: Verified!':
        return 'lib/assets/images/GwaTransFemaleAvatar.png';
      case ':trans:Verified!':
        return 'lib/assets/images/GwaTransMaleAvatar.png';
      case ':female: Verified!':
        return 'lib/assets/images/GwaFemaleAvatar.png';
      case ':male: Verified!':
        return 'lib/assets/images/GwaMaleAvatar.png';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String flairImagePath = _getFlairImagePath();
    if (flairImagePath.isNotEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: Padding(
          padding: padding,
          child: Image.asset(flairImagePath),
        ),
      );
    }
    return Container();
  }
}
