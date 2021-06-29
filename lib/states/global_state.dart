import 'package:draw/draw.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:gwa_app/models/audio_launch_options.dart';
import 'package:gwa_app/services/reddit_client_service.dart';
import 'package:gwa_app/models/gwa_submission_preview.dart';

/*TODO: Make the load functions more clear or maybe change them. I'm not sure
    if I did lazy loading correctly and I don't know if the current way
    does any kind of unintentional harm. */

/* TODO: Think of a way that prepareForNewSearch() could be called automatically
    from here so we won't depend on other classes to call it and if they don't
    the user will just be stuck in a loading loop. */

/* TODO: Use PUSHSHIFT in the future. The current reddit api allows only 250
    results from a subreddit search. */

// FIXME: When searching 'title:F4M' we get 249 results instead of 250.
class GlobalState with ChangeNotifier {
  Stream<UserContent> _searchResultsStream;
  StreamSubscription<UserContent> _subscription;
  List<GwaSubmissionPreview> _searchResults = [];
  String _lastSeenSubmission = '';
  bool _isBusy = false;
  bool _searchEmpty = false;

  /// Is there any more content to load in [searchResultsStream]?
  /// This gets set when the content stream is done streaming and gets reset on
  /// a [prepareNewSearch] call.
  bool _outOfSearchData = false;

  RedditClientService _redditClientService;

  SubredditRef get gwaSubreddit => _redditClientService.gwaSubreddit;

  Stream<UserContent> get searchResultsStream => _searchResultsStream;

  List<GwaSubmissionPreview> get searchResults => _searchResults;

  bool get isBusy => _isBusy;

  bool get searchEmpty => _searchEmpty;

  /// Is there any more content to load in [searchResultsStream]?
  /// This gets set when the content stream is done streaming and gets reset on
  /// a [prepareNewSearch] call.
  bool get outOfSearchData => _outOfSearchData;

  RedditClientService get redditClientService => _redditClientService;

  bool get eligiblePrefs => _redditClientService.eligiblePrefs;

  AudioLaunchOptions audioLaunchOptions = AudioLaunchOptions.ChromeCustomTabs;

  /// Constructs [_redditClientService] and initialises it.
  Future<void> initApp() async {
    _redditClientService = await RedditClientService.createInitialService();
    await _redditClientService.init();

    notifyListeners();
  }

  /// Load content to [_searchResults] based on a search [query], a
  /// [timeFilter] and an optional [limit].
  /// This lazy loads by default, meaning if you call any [_loadContent]
  /// based function after it it won't clear anything, instead it'll load more
  /// submissions to [_searchResults] together with the current ones.
  /// If you want to make a brand new load, call [prepareNewSearch]
  /// before this function.
  loadSearch(String query, Sort sort, TimeFilter timeFilter, [int limit = 99]) {
    _loadContent(
      limit: limit,
      stream: (overrideLimit) {
        return _redditClientService.gwaSubreddit.search(
          query,
          timeFilter: timeFilter ?? TimeFilter.all,
          sort: sort,
          /* TODO: Find a way to implement the raw_json=1 parameter so we won't
              have to handle &amp etc... in MarkdownViewer. */
          params: {
            'after': _lastSeenSubmission,
            'limit': overrideLimit.toString(),
            'count':
            _searchResults.isEmpty ? '0' : _searchResults.length.toString(),
            'include_over_18': 'on'
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
  /// If you want to make a brand new load, call [prepareNewSearch]
  /// before this function.
  loadTop(TimeFilter timeFilter, [int limit = 99]) {
    _loadContent(
      limit: limit,
      stream: (overrideLimit) {
        return _redditClientService.gwaSubreddit.top(
          timeFilter: timeFilter ?? TimeFilter.all,
          limit: overrideLimit,
          after: _lastSeenSubmission,
        ).asBroadcastStream();
      },
    );
  }

  /// Load the hot posts from GoneWildAudio to [_searchResults] with an
  /// optional [limit].
  /// This lazy loads by default, meaning if you call any [_loadContent]
  /// based function after it it won't clear anything, instead it'll load more
  /// submissions to [_searchResults] together with the current ones.
  /// If you want to make a brand new load, call [prepareNewSearch]
  /// before this function.
  loadHot([int limit = 99]) {
    _loadContent(
      limit: limit,
      stream: (overrideLimit) {
        return _redditClientService.gwaSubreddit.hot(
          limit: overrideLimit,
          after: _lastSeenSubmission,
        ).asBroadcastStream();
      },
    );
  }

  /// Load the newest posts from GoneWildAudio to [_searchResults] with an
  /// optional [limit].
  /// This lazy loads by default, meaning if you call any [_loadContent]
  /// based function after it it won't clear anything, instead it'll load more
  /// submissions to [_searchResults] together with the current ones.
  /// If you want to make a brand new load, call [prepareNewSearch]
  /// before this function.
  loadNewest([int limit = 99]) {
    _loadContent(
      limit: limit,
      stream: (overrideLimit) {
        return _redditClientService.gwaSubreddit
            .newest(
          limit: overrideLimit,
          after: _lastSeenSubmission,
        )
            .asBroadcastStream();
      },
    );
  }

  /// Load the posts with the most comments from GoneWildAudio to
  /// [_searchResults] based on a [timeFilter] and an optional [limit].
  /// This lazy loads by default, meaning if you call any [_loadContent]
  /// based function after it it won't clear anything, instead it'll load more
  /// submissions to [_searchResults] together with the current ones.
  /// If you want to make a brand new load, call [prepareNewSearch]
  /// before this function.
  loadControversial(TimeFilter timeFilter, [int limit = 99]) {
    _loadContent(
        limit: limit,
        stream: (overrideLimit) {
          return _redditClientService.gwaSubreddit
              .controversial(
            timeFilter: timeFilter ?? TimeFilter.all,
            limit: limit,
            after: _lastSeenSubmission,
          )
              .asBroadcastStream();
        });
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
    /* Don't load content if we're already loading content or if there's no
    more content to load (based on current load)*/
    if (!this._isBusy && !this._outOfSearchData) {
      // Means this is a new search.
      if (this._lastSeenSubmission.isEmpty) {
        _searchResults.clear();

        _searchResultsStream = stream.call(limit);
        _isBusy = true;
        _subscription = _searchResultsStream.listen((value) {});
        _handleSubscription(limit);

        if (_searchResults.isNotEmpty) notifyListeners();
      }
      //This isn't a new stream. Should load more submissions.
      else {
        if (this._searchResults.length < 1000) {
          int contentLimit;
          if (1000 - this._searchResults.length < limit) {
            contentLimit = 1000 - this._searchResults.length;
          } else {
            contentLimit = limit;
          }
          print('content limit: $contentLimit');
          _searchResultsStream = stream.call(contentLimit);

          _isBusy = true;
          _subscription = _searchResultsStream.listen((value) {});
          _handleSubscription(contentLimit);

          notifyListeners();
        }
      }
    }
  }

  /// Returns a Future<Submission> belonging to the submission of the ID given.
  /// [id] needs to be without the ID prefix (i.e. t3_).
  Future<Submission> populateSubmission({String id}) {
    return _redditClientService.reddit.submission(id: id).populate();
  }

  /// Returns a Future<Submission> belonging to the submission of the link given.
  Future<Submission> populateSubmissionUrl({String url}) {
    return _redditClientService.reddit.submission(url: url).populate();
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
  prepareNewSearch() {
    this._lastSeenSubmission = '';
    this._outOfSearchData = false;
  }

  _handleSubscription(int requestsNum) {
    this._searchEmpty = false;

    if (this._subscription != null) {
      int _requestsReceived = 0;

      this._subscription.onData((submission) {
        GwaSubmissionPreview gwaSubmission =
        new GwaSubmissionPreview(submission);
        _searchResults.add(gwaSubmission);
        _requestsReceived++;
      });

      this._subscription.onDone(() {
        this._isBusy = false;
        this._searchEmpty = this._searchResults.isEmpty;
        this._subscription.cancel();
        print('received: $_requestsReceived');
        if (_requestsReceived < requestsNum) {
          this._outOfSearchData = true;
        }
        print('Out of search data: ${this.outOfSearchData}');
        print(this._searchResults.length);
        notifyListeners();
      });
    }
  }

  Stream<UserContent> getTopStream(TimeFilter timeFilter, int limit) {
    return _redditClientService.gwaSubreddit
        .top(
      timeFilter: timeFilter,
      limit: limit,
    )
        .asBroadcastStream();
  }

  Stream<UserContent> getHotStream(int limit) {
    return _redditClientService.gwaSubreddit
        .hot(
      limit: limit,
    )
        .asBroadcastStream();
  }

  Stream<UserContent> getNewestStream(int limit) {
    return _redditClientService.gwaSubreddit
        .newest(
      limit: limit,
    )
        .asBroadcastStream();
  }
}
