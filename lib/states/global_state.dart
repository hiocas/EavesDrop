import 'package:draw/draw.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:gwa_app/utils/util_functions.dart';
import 'package:gwa_app/models/gwa_submission_preview.dart';

class GlobalState with ChangeNotifier {
  Reddit _reddit;
  SubredditRef _gwaSubreddit;
  Stream<UserContent> _searchResultsStream;
  List<GwaSubmissionPreview> _searchResults = [];
  String _lastSeenSubmission = 'None';

  SubredditRef get gwaSubreddit => _gwaSubreddit;

  Stream<UserContent> get searchResultsStream => _searchResultsStream;

  List<GwaSubmissionPreview> get searchResults => _searchResults;

  Future<void> initApp() async {
    Map<String, dynamic> _data =
        await parseJsonFromAssets('lib/assets/reddit.json');

    _reddit = await Reddit.createScriptInstance(
      clientId: _data["CLIENT_ID"],
      clientSecret: _data["SECRET"],
      userAgent: 'MyAPI/0.0.1',
      username: _data["username"],
      password: _data["password"],
    );

    _gwaSubreddit = _reddit.subreddit('gonewildaudio');

    notifyListeners();
  }

  loadSearch(String query, Sort sort, TimeFilter timeFilter) {
    _searchResults = [];

    _searchResultsStream = _gwaSubreddit.search(
      query,
      timeFilter: TimeFilter.all,
      sort: sort,
      params: {'after': _lastSeenSubmission},
    ).asBroadcastStream();

    _searchResultsStream.listen((submission) {
      GwaSubmissionPreview gwaSubmission = new GwaSubmissionPreview(submission);
      _searchResults.add(gwaSubmission);
    });
  }

  loadTop(TimeFilter timeFilter) {
    _searchResults = [];

    _searchResultsStream = _gwaSubreddit.top(
      timeFilter: TimeFilter.all,
      limit: 200,
      params: {'after': _lastSeenSubmission},
    ).asBroadcastStream();

    _searchResultsStream.listen((submission) {
      GwaSubmissionPreview gwaSubmission = new GwaSubmissionPreview(submission);
      _searchResults.add(gwaSubmission);
    });
  }

  loadHot() {
    _searchResults = [];

    _searchResultsStream = _gwaSubreddit.hot(
      limit: 200,
      params: {'after': _lastSeenSubmission},
    ).asBroadcastStream();

    _searchResultsStream.listen((submission) {
      GwaSubmissionPreview gwaSubmission = new GwaSubmissionPreview(submission);
      _searchResults.add(gwaSubmission);
    });
  }

  loadNewest() {
    _searchResults = [];

    _searchResultsStream = _gwaSubreddit.newest(
      limit: 200,
      params: {'after': _lastSeenSubmission},
    ).asBroadcastStream();

    _searchResultsStream.listen((submission) {
      GwaSubmissionPreview gwaSubmission = new GwaSubmissionPreview(submission);
      _searchResults.add(gwaSubmission);
    });
  }

  /// Returns a Future<Submission> belonging to the submission ID given.
  /// ID needs to be without the ID prefix (i.e. t3_).
  Future<Submission> populateSubmission({@required String id}) {
    return _reddit.submission(id: id).populate();
  }

  /// Automatically set lastSeenSubmission as the last loaded submission in the searchResults list.
  updateLastSeenSubmission() {
    _lastSeenSubmission = _searchResults.last.fullname;
  }
}
