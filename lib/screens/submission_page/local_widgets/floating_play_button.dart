import 'package:draw/draw.dart';
import 'package:eavesdrop/states/gwa_player_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:eavesdrop/models/audio_launch_options.dart';
import 'package:eavesdrop/models/gwa_submission.dart';
import 'package:eavesdrop/models/hive_boxes.dart';
import 'package:eavesdrop/utils/util_functions.dart';
import 'package:eavesdrop/widgets/navigator_routes/hero_dialog_route.dart';
import 'package:eavesdrop/widgets/rect_tweens/calm_rect_tween.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    show
        ChromeSafariBrowser,
        ChromeSafariBrowserClassOptions,
        AndroidChromeCustomTabsOptions,
        IOSSafariOptions;
import 'dart:math' as Math;

import 'package:eavesdrop/widgets/website_viewer.dart';
import 'package:provider/provider.dart';

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad() {
    print("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}

/* FIXME: You can't dismiss this button before starting to scroll because
    animates is null. */
class FloatingPlayButton extends StatefulWidget {
  const FloatingPlayButton({
    Key key,
    @required this.submission,
    this.heroTag,
    @required this.scrollController,
  }) : super(key: key);

  final GwaSubmission submission;
  final String heroTag;
  final ScrollController scrollController;

  @override
  FloatingPlayButtonState createState() => FloatingPlayButtonState();
}

class FloatingPlayButtonState extends State<FloatingPlayButton>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  bool _isFABVisible;
  bool animates;
  void Function() _waitForNotNull;

  animateButton() {
    if (_animationController != null) {
      if (_isFABVisible) {
        _isFABVisible = false;
        _animationController.forward();
      } else {
        _isFABVisible = true;
        _animationController.reverse();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    double alwaysShowFABAt;
    bool canHideFAB = true;
    _isFABVisible = true;
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 500));
    void Function() animateButton = () {
      alwaysShowFABAt =
          Math.max(widget.scrollController.position.maxScrollExtent - 200, 0);
      canHideFAB = widget.scrollController.offset < alwaysShowFABAt;
      if (canHideFAB &&
          widget.scrollController.position.userScrollDirection ==
              ScrollDirection.reverse) {
        if (_isFABVisible) {
          setState(() {
            _isFABVisible = false;
            _animationController.forward();
          });
        }
      } else if (widget.scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isFABVisible) {
          setState(() {
            _isFABVisible = true;
            _animationController.reverse();
          });
        }
      } else if (!canHideFAB & !_isFABVisible) {
        setState(() {
          _isFABVisible = true;
          _animationController.reverse();
        });
      }
    };
    _waitForNotNull = () {
      if (widget.scrollController.position.hasContentDimensions) {
        /* If maxScrollController is smaller than 450, don't animate the button
         based on the user scrolling. */
        if (widget.scrollController.position.maxScrollExtent <= 450) {
          animates = false;
          _removeWaitForNotNull();
        } else {
          alwaysShowFABAt = Math.max(
              widget.scrollController.position.maxScrollExtent - 200, 0);
          animates = true;
          _removeWaitForNotNull();
          widget.scrollController.addListener(animateButton);
        }
      }
    };
    widget.scrollController.addListener(_waitForNotNull);
  }

  _removeWaitForNotNull() {
    widget.scrollController.removeListener(_waitForNotNull);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position:
          Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(0.0, 2.0)).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOutQuint,
        ),
      ),
      child: Hero(
        tag: this.widget.heroTag,
        createRectTween: (begin, end) => CalmRectTween(begin: begin, end: end),
        child: ValueListenableBuilder<bool>(
          valueListenable: Provider.of<GwaPlayerState>(context, listen: false)
              .playerActiveNotifier,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(const Radius.circular(15.0)),
              gradient: RadialGradient(
                radius: 4.0,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).cardColor,
                ],
              ),
            ),
            width: 220.0,
            child: RawMaterialButton(
              shape: const CircleBorder(),
              onPressed: () {
                Navigator.of(context).push(HeroDialogRoute(builder: (context) {
                  return FloatingPlayButtonPopupCard(
                    submission: this.widget.submission,
                    heroTag: this.widget.heroTag,
                  );
                }));
              },
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          ),
          builder: (context, value, child) {
            return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: value ? Container() : child);
          },
        ),
      ),
    );
  }
}

class FloatingPlayButtonPopupCard extends StatelessWidget {
  final String heroTag;
  final GwaSubmission submission;

  const FloatingPlayButtonPopupCard({
    Key key,
    @required this.heroTag,
    @required this.submission,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChromeSafariBrowser browser = new MyChromeSafariBrowser();
    AudioLaunchOptions _audioLaunchOptions;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Hero(
          tag: this.heroTag,
          createRectTween: (begin, end) =>
              CalmRectTween(begin: begin, end: end),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 700.0,
            ),
            child: Material(
              color: Theme.of(context).backgroundColor,
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0)),
              child: Builder(builder: (context) {
                if (submission.audioUrls.length == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Couldn't find a Soundgasm.net url to launch.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.1),
                              fontSize: 22.0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).primaryColor)),
                              onPressed: () {
                                //First pop this page.
                                Navigator.pop(context);
                                //Then pop submission page and send data.
                                popSubmissionPageWithData(
                                  context,
                                  query: submission.title,
                                  sort: Sort.relevance,
                                  timeFilter: TimeFilter.all,
                                );
                              },
                              icon: Icon(Icons.search),
                              label: Text('Search Fills'),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(14.0),
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(color: Colors.black),
                  itemBuilder: (context, index) {
                    return Container(
                      child: ListTile(
                        onLongPress: () async {
                          final appSettings = await HiveBoxes.getAppSettings();
                          _audioLaunchOptions = appSettings.audioLaunchOptions;
                          if (_audioLaunchOptions ==
                              AudioLaunchOptions.EavesDrop) {
                            final playerState = Provider.of<GwaPlayerState>(
                                context,
                                listen: false);
                            final List<ListTile> tiles = [
                              ListTile(
                                leading: Icon(
                                  CupertinoIcons.text_insert,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  'Play Next',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onTap: () async {
                                  final source = await getAudioSource(
                                      submission.audioUrls[index]);
                                  playerState.insertAudioToPlaylist(
                                      source,
                                      AudioData(
                                          submission.title,
                                          getUrlTitle(
                                              submission.audioUrls[index]),
                                          submission.author,
                                          submission.authorFlairText,
                                          submission.firstImageOrGifUrl,
                                          submission.fullname));
                                },
                              ),
                              ListTile(
                                leading: Icon(
                                  CupertinoIcons.text_append,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  'Play Last',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onTap: () async {
                                  final source = await getAudioSource(
                                      submission.audioUrls[index]);
                                  await playerState.addAudioToPlaylist(
                                      source,
                                      AudioData(
                                          submission.title,
                                          getUrlTitle(
                                              submission.audioUrls[index]),
                                          submission.author,
                                          submission.authorFlairText,
                                          submission.firstImageOrGifUrl,
                                          submission.fullname));
                                },
                              ),
                              ListTile(
                                leading: Icon(
                                  CupertinoIcons.globe,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  'Open in Browser',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onTap: () => browser.open(
                                    url: Uri.parse(submission.audioUrls[index]),
                                    options: ChromeSafariBrowserClassOptions(
                                        android: AndroidChromeCustomTabsOptions(
                                            addDefaultShareMenuItem: true),
                                        ios: IOSSafariOptions(
                                            barCollapsingEnabled: true))),
                              ),
                            ];
                            showModalBottomSheet(
                              context: context,
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(32))),
                              builder: (context) => Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: tiles.length,
                                  itemBuilder: (context, index) => tiles[index],
                                  separatorBuilder: (context, index) => Divider(
                                    color: Colors.grey[700],
                                    thickness: 1.0,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        onTap: () async {
                          final appSettings = await HiveBoxes.getAppSettings();
                          _audioLaunchOptions = appSettings.audioLaunchOptions;
                          switch (_audioLaunchOptions) {
                            case AudioLaunchOptions.EavesDrop:
                              Navigator.of(context).pop('launch-audio-player');
                              final playerState = Provider.of<GwaPlayerState>(
                                  context,
                                  listen: false);
                              final source = await getAudioSource(
                                  submission.audioUrls[index]);
                              await playerState.addAudioToPlaylist(
                                  source,
                                  AudioData(
                                      submission.title,
                                      getUrlTitle(submission.audioUrls[index]),
                                      submission.author,
                                      submission.authorFlairText,
                                      submission.firstImageOrGifUrl,
                                      submission.fullname));
                              playerState.seekToNext();
                              playerState.play();
                              break;
                            case AudioLaunchOptions.ChromeCustomTabs:
                              browser.open(
                                  url: Uri.parse(submission.audioUrls[index]),
                                  options: ChromeSafariBrowserClassOptions(
                                      android: AndroidChromeCustomTabsOptions(
                                          addDefaultShareMenuItem: true),
                                      ios: IOSSafariOptions(
                                          barCollapsingEnabled: true)));
                              break;
                            case AudioLaunchOptions.WebView:
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WebsiteViewer(
                                      title: submission.title,
                                      url: submission.audioUrls[index]),
                                ),
                              );
                              break;
                          }
                        },
                        title: Text(
                          getUrlTitle(submission.audioUrls[index]),
                          style: TextStyle(
                            color: Colors.grey[300],
                          ),
                        ),
                        subtitle: Text(
                          submission.audioUrls[index],
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: submission.audioUrls.length,
                  shrinkWrap: true,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
