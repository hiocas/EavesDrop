import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/* I'm separating the full submission model with this model, so that the app won't crash when trying to save all of the details for a submission.
This is only used for the list view.*/
class GwaSubmissionPreview {
  String title;
  String fullname;
  String thumbnailUrl = 'https://styles.redditmedia.com/t5_2u463/styles/communityIcon_1lj5xecdisi31.png?width=256&s=98e8187f0403751b02c03e7ffb9f059ce0ce18d9';

  GwaSubmissionPreview(Submission submission) {
    this.title = findSubmissionTitle(submission);
    this.fullname = submission.fullname;
    //Be careful! this only works if a certain setting in the reddit prefs (in the old prefs at the old reddit website) is checked. If it isn't we won't get nsfw previews.
    if (submission.preview.length > 0) {
      this.thumbnailUrl = submission.preview[0].source.url.toString();
    }
  }

  /// Returns a string of the name of the submission.
  String findSubmissionTitle(Submission submission) {
    var exp = RegExp(r'(?<=\])(.*?)(?=\[)');
    var matches = exp.allMatches(submission.title);
    var results = List<String>.generate(
        matches.length, (int index) => matches.elementAt(index).group(0));
    for (var title in results) {
      if (RegExp(r'[a-zA-Z]').hasMatch(title)) {
        if (title.contains('&amp;')) {
          return title.substring(0, title.indexOf('&amp;')) +
              '&' +
              title.substring(title.indexOf('&amp;') + 5);
        }
        return title.trim();
      }
    }
    return submission.title;
  }
}
