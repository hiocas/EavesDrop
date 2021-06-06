import 'package:markdown/markdown.dart' as md;
import 'package:draw/draw.dart';
import 'package:gwa_app/utils/gwa_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;

//TODO: Add support for tags in a submission's selftext.
class GwaSubmission {
  String fullTitle;
  String title = '';
  String selftext = '';
  String author = '';
  Uri shortlink;
  Uri url;
  String fullname = '';
  List<String> tags = [];
  List<String> urls = ['hey'];
  List<String> audioUrls = [];
  String firstImageOrGifUrl = '';
  Image img;
  String thumbnailUrl;
  bool hasAudioUrl = false;
  String fromNow;
  int upvotes;
  DateTime created;
  int gold;
  int silver;
  int platinum;
  String linkFlairText;
  String authorFlairText;
  int numComments;

  GwaSubmission(Submission submission) {
    this.fullTitle = submission.title ?? '';
    this.title = findSubmissionTitle(this.fullTitle) ?? '';
    this.shortlink = submission.shortlink;
    this.selftext = submission.selftext ?? '';
    this.author = submission.author ?? '';
    this.url = submission.url;
    this.fullname = submission.fullname ?? '';
    this.tags = findSubmissionTags();
    this.urls = findSubmissionURLS(this.selftext);
    _populateAudioUrls(submission);
    var urlStr = this.url.toString();
    //Only add the url to urls if it has soundgasm in it -> when posting a link submission to reddit this is where the link is.
    if (urlStr.contains('soundgasm')) this.urls.add(urlStr);
    if (submission.preview.length > 0)
      this.thumbnailUrl = submission.preview[0].source.url.toString();
    this.firstImageOrGifUrl = findFirstImageOrGifURL(submission);
    this.img = _getImg();
    this.hasAudioUrl = checkHasAudioUrl();
    this.fromNow = getTimeSinceCreated(submission.createdUtc);
    this.upvotes = submission.upvotes ?? 0;
    this.created = submission.createdUtc ?? DateTime.now();
    this.gold = submission.gold ?? 0;
    this.silver = submission.silver ?? 0;
    this.platinum = submission.platinum ?? 0;
    this.linkFlairText = submission.linkFlairText ?? '';
    this.authorFlairText = submission.authorFlairText ?? '';
    this.numComments = submission.numComments ?? 0;
  }

  List<String> findSubmissionTags() {
    var exp = RegExp(r'(?<=\[)(.*?)(?=\])');
    var matches = exp.allMatches(this.fullTitle);
    List<String> tags = [];
    print(matches.length);
    if (matches.length > 0) {
      tags = ['{author:}${this.author}'];
      for (RegExpMatch match in matches) {
        tags.add(match.group(0).replaceAll('&amp;', '&'));
      }
    }
    return tags;
  }

  // Returns a list strings of all urls found in a submission's self text.
  // There's an issue with the reddit &amp; flag, it can appear mid url
  /* FIXME: There is a possibility that this won't work 100% of the times,
      I'm assuming here that every link in a reddit posts gets turned into
      a Markdown hyper link (in the [text](link) format).
      I would've used a regex, but a simple regex sometimes fails on me (gets
      stuff that aren't in the link) and a more complex one gets accurate
      results but can sometimes freeze the app completely as I guess it uses
      too much resources. This current way assumes every link would be picked
      up by markdown but it works (doesn't freeze the app and gets accurate
      results).
      I could dump this and search only for soundcloud/image/gif links, which
      are the only links I use this for.
   */
  List<String> findSubmissionURLS(String text) {
    final html = parse(md.markdownToHtml(text));
    final List<String> hrefs = html
        .getElementsByTagName('a')
        .where((e) => e.attributes.containsKey('href'))
        .map((e) => e.attributes['href'])
        .toList();
    return hrefs;
  }

  /// Returns a string of the first image or gif url found in a submission's self text.
  String findFirstImageOrGifURL(Submission submission) {
    for (var s in this.urls) {
      if (s.contains('.jpg') || s.contains('.png') || s.contains('.gif')) {
        return s;
      }
    }
    if (this.thumbnailUrl != null) {
      return this.thumbnailUrl;
    }
    return 'https://styles.redditmedia.com/t5_2u463/styles/communityIcon_1lj5xecdisi31.png?width=256&s=98e8187f0403751b02c03e7ffb9f059ce0ce18d9';
  }

  _populateAudioUrls(Submission submission) {
    for (String url in this.urls) {
      if (url.contains('soundgasm')) {
        this.audioUrls.add(url);
      } else if (url.contains('soundcloud')) {
        this.audioUrls.add(url);
      }
    }
  }

  bool checkHasAudioUrl() {
    for (var url in this.urls) {
      if (url.contains('soundgasm')) return true;
    }
    return false;
  }

  Image _getImg() {
    return Image.network(
      this.firstImageOrGifUrl,
      fit: BoxFit.cover,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 200,
          width: 200,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes
                  : null,
            ),
          ),
        );
      },
      errorBuilder:
          (BuildContext context, Object exception, StackTrace stackTrace) {
        return Image.network(
          this.thumbnailUrl ??
              'https://styles.redditmedia.com/t5_2u463/styles/communityIcon_1lj5xecdisi31.png?width=256&s=98e8187f0403751b02c03e7ffb9f059ce0ce18d9',
          fit: BoxFit.cover,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              width: 200,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes
                      : null,
                ),
              ),
            );
          },
          errorBuilder:
              (BuildContext context, Object exception, StackTrace stackTrace) {
            return Text('There was an error');
          },
        );
      },
    );
  }

  String getTimeSinceCreated(DateTime created) {
    if (created == null) return 'None';
    var diff = DateTime.now().difference(created);
    var years = (diff.inDays / 365).truncate();
    var months = (diff.inDays / 30).truncate();
    var weeks = (diff.inDays / 7).truncate();
    var days = diff.inDays;
    var hours = diff.inHours;
    var minutes = diff.inMinutes;
    var seconds = diff.inSeconds;
    if (years >= 1)
      return years.toString() + 'y';
    else if (months >= 1)
      return months.toString() + 'mo';
    else if (weeks >= 1)
      return weeks.toString() + 'w';
    else if (days >= 1)
      return days.toString() + 'd';
    else if (hours >= 1)
      return hours.toString() + 'h';
    else if (minutes >= 1)
      return minutes.toString() + 'm';
    else if (seconds >= 1) return seconds.toString() + 's';
    return 'now';
  }
}
