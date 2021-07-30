import 'package:eavesdrop/screens/audio_player/local_widgets/play_controls.dart';
import 'package:eavesdrop/states/gwa_player_state.dart';
import 'package:eavesdrop/utils/gwa_functions.dart';
import 'package:eavesdrop/utils/util_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'expandable_player_image.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({
    Key key,
    @required this.expansionProgress,
    @required this.paletteGenerator,
    this.onTapPlaylistButton,
    this.audioListButtonSubmissionFullname,
  }) : super(key: key);

  final Animation<double> expansionProgress;
  final PaletteGenerator paletteGenerator;
  final void Function() onTapPlaylistButton;
  final String audioListButtonSubmissionFullname;

  @override
  _PlayerViewState createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Consumer<GwaPlayerState>(builder: (context, state, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ExpandablePlayerImage(
                animation: widget.expansionProgress,
                url: state.currentAudioSourceCoverUrl ??
                    GwaFunctions.getPlaceholderImageUrl('0'),
                title: state.currentAudioSourceTitle,
                author: state.currentAudioSourceAuthor,
                audioListButtonSubmissionFullname: widget.audioListButtonSubmissionFullname,
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
                child: Text(
                  state.currentAudioSourceTitle ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.paletteGenerator.dominantColor.titleTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  state.currentAudioSourceAuthor ?? '',
                  style: TextStyle(
                    color: darken(
                        widget.paletteGenerator.dominantColor.titleTextColor,
                        0.2),
                    fontWeight: FontWeight.bold,
                    fontSize: 17.0,
                  ),
                ),
              ),
              PlayControls(
                inPlaylistView: false,
                paletteGenerator: widget.paletteGenerator,
                onTapPlaylistButton: widget.onTapPlaylistButton,
              ),
            ],
          );
        }),
      ),
    );
  }
}
