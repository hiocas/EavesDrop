import 'package:draw/draw.dart';
import 'package:gwa_app/utils/gwa_functions.dart';
import 'package:hive/hive.dart';

/* I'm separating the full submission model with this model, so that the app
won't crash when trying to save all of the details for a submission.
This is only used for the list view.*/

class GwaSubmissionPreview extends HiveObject{
  String title;
  String fullname;
  String thumbnailUrl;

  GwaSubmissionPreview(Submission submission) {
    this.title = findSubmissionTitle(submission.title);
    this.fullname = submission.fullname;
    //Be careful! this only works if a certain setting in the reddit prefs (in the old prefs at the old reddit website) is checked. If it isn't we won't get nsfw previews.
    if (submission.preview.length > 0) {
      this.thumbnailUrl = submission.preview[0].source.url.toString();
    }
    else {
      this.thumbnailUrl =
          'https://styles.redditmedia.com/t5_2u463/styles/communityIcon_1lj5xecdisi31.png?width=256&s=98e8187f0403751b02c03e7ffb9f059ce0ce18d9';
    }
  }
}
