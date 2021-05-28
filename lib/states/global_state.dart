import 'package:draw/draw.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:gwa_app/utils/util_functions.dart';
import 'package:gwa_app/models/gwa_submission_preview.dart';

class GlobalState with ChangeNotifier {
  Reddit _reddit;
  SubredditRef _gwaSubreddit;
  Stream<UserContent> _searchResultsStream;
  StreamSubscription<UserContent> _subscription;
  List<GwaSubmissionPreview> _searchResults = [];
  String _lastSeenSubmission = 'None';
  bool _isBusy = false;
  bool _searchEmpty = false;

  SubredditRef get gwaSubreddit => _gwaSubreddit;

  Stream<UserContent> get searchResultsStream => _searchResultsStream;

  List<GwaSubmissionPreview> get searchResults => _searchResults;

  bool get isBusy => _isBusy;

  bool get searchEmpty => _searchEmpty;

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

  loadSearch(String query, Sort sort, TimeFilter timeFilter,
      [int limit = 100]) {
    _searchResults = [];

    if (!this._isBusy) {
      _searchResultsStream = _gwaSubreddit.search(
        query,
        timeFilter: TimeFilter.all,
        sort: sort,
        params: {'after': _lastSeenSubmission, 'limit': limit.toString()},
      ).asBroadcastStream();

      _isBusy = true;
      _subscription = _searchResultsStream.listen((value) {});
      _handleSubscription();

      if (_searchResults.isNotEmpty) notifyListeners();
    }
  }

  loadTop(TimeFilter timeFilter, [int limit]) {
    if (!this._isBusy) {
      _searchResults = [];

      _searchResultsStream = _gwaSubreddit.top(
        timeFilter: TimeFilter.all,
        limit: limit ?? 100,
        params: {'after': _lastSeenSubmission},
      ).asBroadcastStream();

      _isBusy = true;
      _subscription = _searchResultsStream.listen((value) {});
      _handleSubscription();

      if (_searchResults.isNotEmpty) notifyListeners();
    }
  }

  loadHot() {
    if (!this._isBusy) {
      _searchResults = [];

      _searchResultsStream = _gwaSubreddit.hot(
        limit: 100,
        params: {'after': _lastSeenSubmission},
      ).asBroadcastStream();

      _isBusy = true;
      _subscription = _searchResultsStream.listen((value) {});
      _handleSubscription();

      if (_searchResults.isNotEmpty) notifyListeners();
    }
  }

  loadNewest() {
    if (!this._isBusy) {
      _searchResults = [];

      _searchResultsStream = _gwaSubreddit.newest(
        limit: 100,
        params: {'after': _lastSeenSubmission},
      ).asBroadcastStream();

      _isBusy = true;
      _subscription = _searchResultsStream.listen((value) {});
      _handleSubscription();

      if (_searchResults.isNotEmpty) notifyListeners();
    }
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

  _handleSubscription() {
    this._searchEmpty = false;

    if (this._subscription != null) {
      this._subscription.onData((submission) {
        GwaSubmissionPreview gwaSubmission = new GwaSubmissionPreview(submission);
        _searchResults.add(gwaSubmission);
        if (gwaSubmission.title.contains("black")) print(gwaSubmission.title);
      });

      this._subscription.onDone(() {
        this._isBusy = false;
        this._searchEmpty = this._searchResults.isEmpty;
        _subscription.cancel();
        notifyListeners();
      });
    }
  }

  Stream<UserContent> getTopStream(TimeFilter timeFilter, int limit) {
    return _gwaSubreddit.top(
      timeFilter: timeFilter,
      limit: limit,
    ).asBroadcastStream();
  }

  Stream<UserContent> getHotStream(int limit) {
    return _gwaSubreddit.hot(
      limit: limit,
    ).asBroadcastStream();
  }

  Stream<UserContent> getNewestStream(int limit) {
    return _gwaSubreddit.newest(
      limit: limit,
    ).asBroadcastStream();
  }

}
