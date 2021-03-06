import 'package:flutter/material.dart';
import 'package:eavesdrop/screens/submission_list/local_widgets/gender_tag.dart';

class GwaAuthorFlair extends StatelessWidget {
  const GwaAuthorFlair({
    Key key,
    this.flair,
    this.gender,
    this.padding = const EdgeInsets.only(left: 2.0),
    this.width,
    this.height,
  }) : super(key: key);

  final String flair;
  final Gender gender;
  final EdgeInsets padding;
  final double width;
  final double height;

  String _getFlairImagePath() {
    if (this.flair == null || this.flair.isEmpty) {
      if (this.gender == null) {
        return '';
      } else {
        switch (gender) {
          case Gender.NonBinary:
            return 'lib/assets/images/GwaNonBinaryAvatar.png';
          case Gender.TransFemale:
            return 'lib/assets/images/GwaTransFemaleAvatar.png';
          case Gender.TransMale:
            return 'lib/assets/images/GwaTransMaleAvatar.png';
          case Gender.Female:
            return 'lib/assets/images/GwaFemaleAvatar.png';
          case Gender.Male:
            return 'lib/assets/images/GwaMaleAvatar.png';
          default:
            return '';
        }
      }
    }
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
      case ':Writer:Writer':
        return 'lib/assets/images/GwaWriterAvatar.png';
      case 'Verified!':
        return 'Verified!';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(flair != null || gender != null);
    final String flairImagePath = _getFlairImagePath();
    if (flairImagePath == 'Verified!') {
      return SizedBox(
        width: width,
        height: height,
        child: Padding(
          padding: padding,
          child: Material(
            color: Color.fromARGB(255, 52, 53, 54),
            borderRadius: BorderRadius.circular(4.0),
            child: Center(
              child: Text(
                'V',
                style: TextStyle(
                  fontSize: height - 2.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }
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
