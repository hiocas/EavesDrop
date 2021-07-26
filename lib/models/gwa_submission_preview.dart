import 'package:draw/draw.dart';
import 'package:eavesdrop/utils/gwa_functions.dart';

/* I'm separating the full submission model with this model, so that the app
won't crash when trying to save all of the details for a submission.
This is only used for the list view.*/

class GwaSubmissionPreview {
  String title;
  String fullname;
  String thumbnailUrl;

  GwaSubmissionPreview(Submission submission) {
    // this.title = GwaFunctions.findSubmissionTitle(submission.title);
    this.title = 'Hey there';
    this.fullname = submission.fullname;
    //Be careful! this only works if a certain setting in the reddit prefs (in the old prefs at the old reddit website) is checked. If it isn't we won't get nsfw previews.
    // if (submission.preview.length > 0) {
      // this.thumbnailUrl = submission.preview[0].source.url.toString();
    // } else {
      this.thumbnailUrl = GwaFunctions.getPlaceholderImageUrl(this.fullname);
    // }
  }

  GwaSubmissionPreview.fromData(
      String title, String fullname, String thumbnailUrl) {
    this.title = title;
    this.fullname = fullname;
    this.thumbnailUrl = thumbnailUrl;
  }
}

class GwaSubmissionPreviewWithAuthor {
  String title;
  String author;
  String authorFlairText;
  String fullname;
  String thumbnailUrl;

  GwaSubmissionPreviewWithAuthor(Submission submission) {
    this.title = GwaFunctions.findSubmissionTitle(submission.title);
    this.author = submission.author;
    this.fullname = submission.fullname;
    //Be careful! this only works if a certain setting in the reddit prefs (in the old prefs at the old reddit website) is checked. If it isn't we won't get nsfw previews.
    if (submission.preview.length > 0) {
      this.thumbnailUrl = submission.preview[0].source.url.toString();
    } else {
      this.thumbnailUrl = GwaFunctions.getPlaceholderImageUrl(this.fullname);
    }
    this.authorFlairText = submission.authorFlairText;
  }

  GwaSubmissionPreviewWithAuthor.fromData(
      String title, String author, String fullname, String thumbnailUrl, String authorFlairText) {
    this.title = title;
    this.author = author;
    this.fullname = fullname;
    this.thumbnailUrl = thumbnailUrl;
    this.authorFlairText = authorFlairText;
  }

  GwaSubmissionPreview toGwaSubmissionPreview() {
    return GwaSubmissionPreview.fromData(
        this.title, this.fullname, this.thumbnailUrl);
  }
}
