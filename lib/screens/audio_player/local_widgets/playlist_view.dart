import 'package:eavesdrop/screens/audio_player/local_widgets/expandable_player_image.dart';
import 'package:eavesdrop/screens/audio_player/local_widgets/play_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eavesdrop/states/gwa_player_state.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

class PlaylistView extends StatefulWidget {
  const PlaylistView({
    Key key,
    @required this.expansionProgress,
    @required this.paletteGenerator,
    @required this.onTapPlaylistButton,
    this.audioListButtonSubmissionFullname,
    this.inCurrentSubmissionPage,
  }) : super(key: key);

  final Animation<double> expansionProgress;
  final PaletteGenerator paletteGenerator;
  final void Function() onTapPlaylistButton;
  final String audioListButtonSubmissionFullname;
  final bool Function() inCurrentSubmissionPage;

  @override
  _PlaylistViewState createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Consumer<GwaPlayerState>(builder: (context, state, child) {
              return ExpandablePlayerImage(
                animation: ConstantTween(0.0).animate(kAlwaysCompleteAnimation),
                url: state.currentAudioSourceCoverUrl,
                title: state.currentAudioSourceTitle,
                author: state.currentAudioSourceAuthor,
                playControlsAnimation: Tween<double>(begin: 0.0, end: 1.0)
                    .animate(CurvedAnimation(
                        parent: widget.expansionProgress,
                        curve: Interval(0.0, 0.08))),
                audioListButtonSubmissionFullname:
                    widget.audioListButtonSubmissionFullname,
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0),
            child: Material(
              type: MaterialType.transparency,
              child: SizedBox(
                  height: 265,
                  child: Consumer<GwaPlayerState>(
                      builder: (context, state, child) {
                    return ReorderableListView.builder(
                      itemCount: state.effectiveSequence.length,
                      shrinkWrap: true,
                      onReorder: (int oldIndex, int newIndex) {
                        int fromIndex = oldIndex;
                        int toIndex = newIndex;
                        if (toIndex == state.playlist.length) toIndex--;
                        if (fromIndex != 0 && toIndex != 0) {
                          state.playlist.move(fromIndex, toIndex);
                        }
                      },
                      itemBuilder: (context, index) {
                        AudioData audioData =
                            state.effectiveSequence[index].tag;
                        return ListTile(
                          key: ValueKey(
                              audioData.title.toString() + index.toString()),
                          dense: true,
                          leading: Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              image: DecorationImage(
                                image: NetworkImage(audioData.coverUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(
                            audioData.title,
                            style: const TextStyle(fontSize: 14.0),
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(CupertinoIcons.text_justify),
                          tileColor: state.audioPlayer.currentIndex == index
                              ? Colors.black26
                              : null,
                          onTap: () => Provider.of<GwaPlayerState>(context,
                                  listen: false)
                              .play(),
                        );
                      },
                    );
                  })),
            ),
          ),
          PlayControls(
            inPlaylistView: true,
            paletteGenerator: widget.paletteGenerator,
            onTapPlaylistButton: widget.onTapPlaylistButton,
            inCurrentSubmissionPage: widget.inCurrentSubmissionPage,
          ),
        ],
      ),
    );
  }
}
