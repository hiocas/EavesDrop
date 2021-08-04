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
  ScrollController _scrollController;

  @override
  void initState() {
    int currentIndex = Provider.of<GwaPlayerState>(context, listen: false)
        .audioPlayer
        .currentIndex;
    _scrollController = ScrollController(
        initialScrollOffset: _calcIndexScrollOffset(currentIndex));
    super.initState();
  }

  double _calcIndexScrollOffset(int index) => 16.0 * index;

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
                      scrollController: _scrollController,
                      itemCount: state.effectiveSequence.length,
                      shrinkWrap: true,
                      onReorder: (int oldIndex, int newIndex) {
                        int fromIndex = oldIndex;
                        int toIndex = newIndex;
                        if (toIndex == state.playlist.length) toIndex--;
                        state.playlist.move(fromIndex, toIndex);
                      },
                      itemBuilder: (context, index) {
                        AudioData audioData =
                            state.effectiveSequence[index].tag;
                        GwaPlayerState gwaPlayerState =
                            Provider.of<GwaPlayerState>(context, listen: false);
                        return Dismissible(
                          key: ValueKey(audioData.id),
                          direction: DismissDirection.startToEnd,
                          background: Container(
                            color: Colors.black54,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Icon(CupertinoIcons.xmark_circle_fill),
                              ),
                            ),
                          ),
                          confirmDismiss: (direction) => Future.value(
                              gwaPlayerState.audioPlayer.currentIndex != index),
                          onDismissed: (direction) {
                            gwaPlayerState.playlist.removeAt(index);
                          },
                          child: ListTile(
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
                            onTap: () async {
                              if (gwaPlayerState.audioPlayer.currentIndex !=
                                  index) {
                                await gwaPlayerState.audioPlayer
                                    .seek(Duration.zero, index: index);
                                if (!gwaPlayerState.isPlaying)
                                  gwaPlayerState.play();
                              }
                            },
                          ),
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
