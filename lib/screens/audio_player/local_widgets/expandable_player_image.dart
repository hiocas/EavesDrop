import 'package:draw/draw.dart' show Submission;
import 'package:eavesdrop/models/gwa_submission.dart';
import 'package:eavesdrop/screens/submission_page/local_widgets/all_page_local.dart';
import 'package:eavesdrop/screens/submission_page/local_widgets/floating_play_button.dart';
import 'package:eavesdrop/states/global_state.dart';
import 'package:eavesdrop/states/gwa_player_state.dart';
import 'package:eavesdrop/widgets/navigator_routes/hero_dialog_route.dart';
import 'package:eavesdrop/widgets/rect_tweens/calm_rect_tween.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

class ExpandablePlayerImage extends AnimatedWidget {
  const ExpandablePlayerImage({
    Key key,
    @required Animation<double> animation,
    @required this.title,
    @required this.author,
    @required this.url,
    this.maxSize = 250,
    this.minSize = 50,
    this.playControlsAnimation,
    this.audioListButtonSubmissionFullname,
  }) : super(key: key, listenable: animation);

  final String url;
  final String title;
  final String author;
  final double maxSize;
  final double minSize;
  final Animation<double> playControlsAnimation;
  final String audioListButtonSubmissionFullname;

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    final double size = Tween<double>(begin: this.minSize, end: this.maxSize)
        .animate(animation)
        .value;
    final borderRadius = Tween<BorderRadius>(
            begin: BorderRadius.circular(4.0), end: BorderRadius.circular(16.0))
        .animate(animation)
        .value;
    return AlignTransition(
      alignment:
          Tween<Alignment>(begin: Alignment.centerLeft, end: Alignment.center)
              .animate(animation),
      child: Padding(
        padding: Tween<EdgeInsets>(
                begin: const EdgeInsets.only(left: 20.0),
                end: const EdgeInsets.only(top: 50.0))
            .animate(animation)
            .value,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: size,
              width: size,
              child: Neumorphic(
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.roundRect(borderRadius),
                  shape: NeumorphicShape.concave,
                  depth: Tween<double>(
                          begin: 0.0,
                          end: NeumorphicTheme.of(context).current.depth)
                      .animate(animation)
                      .value,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    image: DecorationImage(
                      image: NetworkImage(
                        this.url,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: animation.value < 0.08,
              child: FadeTransition(
                opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                    CurvedAnimation(
                        parent: animation, curve: Interval(0.0, 0.08))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: audioListButtonSubmissionFullname == null
                            ? 173
                            : 123,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title ?? 'Nothing playing at the moment.',
                              style: TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            Text(
                              author ?? '',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: audioListButtonSubmissionFullname == null
                            ? 98
                            : 147,
                        child: FadeTransition(
                          opacity: Tween<double>(begin: 1.0, end: 0.0)
                              .animate(playControlsAnimation ?? animation),
                          child: Material(
                            type: MaterialType.transparency,
                            child: Consumer<GwaPlayerState>(
                                builder: (context, state, _) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(state.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow),
                                    iconSize: 33.0,
                                    color: Colors.white,
                                    splashColor: Colors.grey,
                                    splashRadius: 20.0,
                                    onPressed: () {
                                      if (state.isPlaying)
                                        state.pause();
                                      else
                                        state.play();
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.skip_next),
                                    iconSize: 33.0,
                                    color: Colors.white,
                                    splashColor: Colors.grey,
                                    splashRadius: 20.0,
                                    onPressed:
                                        state.audioPlayer.nextIndex == null
                                            ? null
                                            : () => state.seekToNext(),
                                  ),
                                  AudioListButton(
                                    audioListButtonSubmissionFullname:
                                        audioListButtonSubmissionFullname,
                                  )
                                ],
                              );
                            }),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AudioListButton extends StatelessWidget {
  const AudioListButton({
    Key key,
    @required this.audioListButtonSubmissionFullname,
  }) : super(key: key);

  final String audioListButtonSubmissionFullname;

  @override
  Widget build(BuildContext context) {
    if (audioListButtonSubmissionFullname == null) {
      return Container();
    }
    return Hero(
      tag: 'audio-list-button-popup-tag',
      createRectTween: (begin, end) => CalmRectTween(begin: begin, end: end),
      child: FutureBuilder<Submission>(
          future: Provider.of<GlobalState>(context, listen: false)
              .populateSubmission(
                  id: audioListButtonSubmissionFullname.substring(3)),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final GwaSubmission gwaSubmission = GwaSubmission(snapshot.data);
              return Material(
                color: Theme.of(context).primaryColor,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: Icon(Icons.playlist_play),
                  iconSize: 33.0,
                  color: Theme.of(context).backgroundColor,
                  splashColor: Colors.grey,
                  splashRadius: 20.0,
                  onPressed: () {
                    Navigator.of(context)
                        .push(HeroDialogRoute(builder: (context) {
                      return FloatingPlayButtonPopupCard(
                        submission: gwaSubmission,
                        heroTag: 'audio-list-button-popup-tag',
                      );
                    }));
                  },
                ),
              );
            }
            return Container();
          }),
    );
  }
}
