import 'dart:convert';

import 'package:draw/draw.dart';
import 'package:gwa_app/states/global_state.dart';
import 'package:gwa_app/utils/util_functions.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

/// Houses [Reddit] constructors with the relevant api data.
class _RedditCreators {
  final String clientID;
  final Uri redirectUri;
  final String userAgent;

  _RedditCreators({this.clientID, this.redirectUri, this.userAgent});

  static Future<_RedditCreators> createInstance() async {
    Map<String, dynamic> data =
        await parseJsonFromAssets('lib/assets/reddit.json');
    return _RedditCreators(
        clientID: data["CLIENT_ID"],
        redirectUri: Uri.parse(data['REDIRECT_URI']),
        userAgent: data['USER_AGENT']);
  }

  Reddit createInstalledFlow() => Reddit.createInstalledFlowInstance(
      clientId: this.clientID,
      userAgent: this.userAgent,
      redirectUri: this.redirectUri);

  Future<Reddit> createUntrustedReadOnlyInstance() =>
      Reddit.createUntrustedReadOnlyInstance(
        clientId: this.clientID,
        userAgent: this.userAgent,
        deviceId: Uuid().v4(),
      );
}

/// Manages log-ins and log-outs.
/// This class also houses the main [Reddit] instance together with the main
/// GoneWildAudio [SubredditRef].
class RedditClientService {
  final _RedditCreators _redditCreators;

  /// The [Reddit] instance to pass to [GlobalState].
  Reddit reddit;

  /// The GoneWildAudio Subreddit Reference to pass to [GlobalState].
  SubredditRef gwaSubreddit;

  /// The untrusted [Reddit] instance to keep instead of re-generating every
  /// time we need it.
  Reddit _untrustedReddit;

  /// This [Reddit] instance is used only to generate auth urls.
  /// we don't use [reddit] since if the user clicks on the link and gets back
  /// to the app, [reddit] won't be an untrusted instance but instead an
  /// unauthorised app instance (since to generate auth urls we need that kind
  /// of [Reddit] instance). This will mean we won't be able to send requests
  /// to it.
  /// In summery: to keep [reddit] untrusted until we know for sure that the
  /// user logged in, we keep the unauthorised instance which we need in order
  /// to generate auth urls here.
  Reddit _oauthReddit;

  /// Gets called in [init] after the user either allows access (and gets
  /// redirected back to the app).
  /// It is passed as a parameter in [login];
  void Function() _onClientAllows;

  /// The display name of the logged-in user [Reddit] instance in [reddit].
  /// If the user isn't logged in this is empty.
  String displayName = '';

  /// Returns whether the user is logged in or not.
  bool get loggedIn => !reddit.readOnly;

  /// Updates [reddit] and [_gwaSubreddit].
  setReddit(Reddit newInstance) {
    this.reddit = newInstance;
    if(!loggedIn) this.displayName = '';
    this.gwaSubreddit = this.reddit.subreddit('gonewildaudio');
  }

  /// Constructs the [RedditClientService] based on an initial [Reddit]
  /// instance.
  /// To start making service calls use [createInitialService] instead.
  RedditClientService(Reddit initialInstance, this._redditCreators) {
    this._untrustedReddit = initialInstance;
    this.reddit = initialInstance;
    this.gwaSubreddit = this.reddit.subreddit('gonewildaudio');
  }

  /// Use this as a constructor to start making service calls.
  /// Returns a [RedditClientService] with an untrusted read only reddit
  /// instance. See [Reddit.createUntrustedReadOnlyInstance].
  /// Call [init] after this to listen for links to authorize.
  /// ```dart
  /// redditClientService = await RedditClientService.createInitialService();
  /// await redditClientService.init();
  /// ```
  static Future<RedditClientService> createInitialService() async {
    _RedditCreators _redditCreators = await _RedditCreators.createInstance();
    final Reddit initialRedditInstance =
        await _redditCreators.createUntrustedReadOnlyInstance();
    return RedditClientService(initialRedditInstance, _redditCreators);
  }

  /// Listens for uni links and either authorises the user client and sets
  /// [reddit] to the new authorized user's [Reddit] instance or if failed sets
  /// [reddit] to [_untrustedReddit].
  init() async {
    try {
      uriLinkStream.listen((link) async {
        print('Got: $link');
        if (link != null && link.queryParameters['code'] != null) {
          String authCode = link.queryParameters['code'];
          print('Auth Code Stream: $authCode');

          /// If the user accepted, set [_reddit] to the reddit instance that
          /// generated the auth link, saved in [_oauthReddit] to authorise
          /// in [_authorizeClient].
          setReddit(_oauthReddit);
          await _authorizeClient(authCode);
          if (_onClientAllows != null) _onClientAllows.call();
        } else {
          setReddit(this._untrustedReddit);
        }
      });
    } catch (e) {
      throw (e);
    }
  }

  /// Launches the browser with the authorise link for the user to permit access
  /// in.
  /// [onClientAllows] will get called after the user allows access (and gets
  /// redirected back to the app). This can be used as a way to pop a login
  /// window when the client returns.
  login({void Function() onClientAllows}) {
    /// Create an installed instance of [Reddit], which is unauthenticated...
    _oauthReddit = _redditCreators.createInstalledFlow();

    /// Set [_onClientReturns] to be called in [init].
    _onClientAllows = onClientAllows;

    /// Generate an auth url and launch it. We then proceed to the
    /// [uriLinkStream] event listener in [init] if the user accepts or
    /// declines access to us.
    /// If the user doesn't accept or declines access (for instance if he just
    /// closes his browser and returns to the app) [_reddit] will still have
    /// an untrusted instance of [Reddit].
    /// If the user did accept or declines then the listener for [uriLinkStream]
    /// in [init] will get a new event and there we will set [_reddit]
    /// accordingly.
    launch(_generateAuthUrl(_oauthReddit).toString());
  }

  /// Authorises [reddit] with the received [authCode].
  Future<void> _authorizeClient(String authCode) async {
    await reddit.auth.authorize(authCode);
    var _me = await reddit.user.me();
    this.displayName = _me.displayName;
  }

  /// Logs the user out.
  logout() {
    setReddit(this._untrustedReddit);
  }

  /// Returns an auth url relevant to [reddit], which must be an instance of
  /// [Reddit] with a [WebAuthenticator].
  Uri _generateAuthUrl(Reddit reddit) {
    return reddit.auth
        .url(['read', 'account', 'identity'], 'gwa-app', compactLogin: true);
  }

  /// Returns whether the current user in [reddit] (if logged in) has eligible
  /// preferences to see submission preview thumbnails (if 'media' is 'on').
  Future<bool> eligiblePreferences() async {
    if (loggedIn) {
      Map<String, dynamic> prefs =
          await reddit.get('api/v1/me/prefs', objectify: false);
      return Future.value(prefs['media'] == 'on');
    }
    return Future.value(false);
  }

  /// If [reddit] houses a logged in instance of [Reddit] and in the user's
  /// preferences 'media' isn't 'on, sets 'media' to be 'on'.
  Future<bool> setEligiblePreferences() async {
    if (loggedIn) {
      bool eligible = await eligiblePreferences();
      if (!eligible) {
        await reddit.patch('api/v1/me/prefs', body: {
          'json': jsonEncode({'media': 'on'})
        });
        return await eligiblePreferences();
      }
    }
    return Future.value(false);
  }
}
