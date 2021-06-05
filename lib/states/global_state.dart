import 'package:draw/draw.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:gwa_app/utils/util_functions.dart';
import 'package:gwa_app/models/gwa_submission_preview.dart';

/*TODO: Make the load functions more clear or maybe change them. I'm not sure
    if I did lazy loading correctly and I don't know if the current way
    does any kind of unintentional harm.
 */
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

  /// Load content to [_searchResults] based on a search [query], a
  /// [timeFilter] and an optional [limit].
  /// This lazy loads by default, meaning if you call any [_loadContent]
  /// based function after it it won't clear anything, instead it'll load more
  /// submissions to [_searchResults] together with the current ones.
  /// If you want to make a brand new load, call [clearLastSeenSubmission]
  /// before this function.
  loadSearch(String query, Sort sort, TimeFilter timeFilter, [int limit = 99]) {
    _loadContent(
      limit: limit,
      stream: (overrideLimit) {
        return _gwaSubreddit.search(
          query,
          timeFilter: timeFilter ?? TimeFilter.all,
          sort: sort,
          params: {
            'after': _lastSeenSubmission,
            'limit': overrideLimit.toString()
          },
        ).asBroadcastStream();
      },
    );
  }

  /// Load the top posts from GoneWildAudio to [_searchResults] based on
  /// a [timeFilter] and an optional [limit].
  /// This lazy loads by default, meaning if you call any [_loadContent]
  /// based function after it it won't clear anything, instead it'll load more
  /// submissions to [_searchResults] together with the current ones.
  /// If you want to make a brand new load, call [clearLastSeenSubmission]
  /// before this function.
  loadTop(TimeFilter timeFilter, [int limit = 99]) {
    _loadContent(
      limit: limit,
      stream: (overrideLimit) {
        return _gwaSubreddit.top(
          timeFilter: timeFilter ?? TimeFilter.all,
          limit: overrideLimit,
          params: {'after': _lastSeenSubmission},
        ).asBroadcastStream();
      },
    );
  }

  /// Load the hot posts from GoneWildAudio to [_searchResults] with an
  /// optional [limit].
  /// This lazy loads by default, meaning if you call any [_loadContent]
  /// based function after it it won't clear anything, instead it'll load more
  /// submissions to [_searchResults] together with the current ones.
  /// If you want to make a brand new load, call [clearLastSeenSubmission]
  /// before this function.
  loadHot([int limit = 99]) {
    _loadContent(
      limit: limit,
      stream: (overrideLimit) {
        return _gwaSubreddit.hot(
          limit: overrideLimit,
          params: {'after': _lastSeenSubmission},
        ).asBroadcastStream();
      },
    );
  }

  /// Load the newest posts from GoneWildAudio to [_searchResults] with an
  /// optional [limit].
  /// This lazy loads by default, meaning if you call any [_loadContent]
  /// based function after it it won't clear anything, instead it'll load more
  /// submissions to [_searchResults] together with the current ones.
  /// If you want to make a brand new load, call [clearLastSeenSubmission]
  /// before this function.
  loadNewest([int limit = 99]) {
    _loadContent(
      limit: limit,
      stream: (overrideLimit) {
        return _gwaSubreddit.newest(
          limit: overrideLimit,
          params: {'after': _lastSeenSubmission},
        ).asBroadcastStream();
      },
    );
  }

  /// The template function to handle loading content.
  /// [stream] is a function that returns a *broadcast* stream of content to
  /// load with a content limit of [limit], it's a function so that we could
  /// override the content limit in case there's still less than a 1000
  /// submissions loaded (which is the reddit cap) but not [limit] left
  /// (for instance, if [limit] is 99 but there are only 3 submissions left
  /// to load).
  _loadContent(
      {@required Stream<UserContent> Function(int overrideLimit) stream,
        @required limit}) {
    if (!this._isBusy) {
      // Means this is a new search.
      if (this._lastSeenSubmission.isEmpty) {
        _searchResults.clear();

        _searchResultsStream = stream.call(limit);
        _isBusy = true;
        _subscription = _searchResultsStream.listen((value) {});
        _handleSubscription();

        if (_searchResults.isNotEmpty) notifyListeners();
      }
      //This isn't a new stream. Should load more submissions.
      else {
        if (this._searchResults.length < 1000) {
          int contentLimit;
          if (1000 - this._searchResults.length < limit) {
            contentLimit = 1000 - this._searchResults.length;
          } else
            contentLimit = limit;
          _searchResultsStream = stream.call(contentLimit);

          _isBusy = true;
          _subscription = _searchResultsStream.listen((value) {});
          _handleSubscription();

          notifyListeners();
        }
      }
    }
  }

  /// Returns a Future<Submission> belonging to the submission ID given.
  /// ID needs to be without the ID prefix (i.e. t3_).
  Future<Submission> populateSubmission({@required String id}) {
    return _reddit.submission(id: id).populate();
  }

  /// Automatically set lastSeenSubmission as the last loaded submission in the
  /// searchResults list. Do this when wanting to load more submissions.
  updateLastSeenSubmission() {
    _lastSeenSubmission = _searchResults.last.fullname;
    print(_lastSeenSubmission);
  }

  /// Clears the current search in preparation for a new one.
  /// This has to be called if a new stream is to be loaded, otherwise the new
  /// submissions will just get added to [_searchResults] with the current
  /// results.
  clearLastSeenSubmission() {
    this._lastSeenSubmission = '';
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
