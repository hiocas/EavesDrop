import 'package:draw/draw.dart';
import 'package:eavesdrop/screens/audio_player/local_widgets/play_controls.dart';
import 'package:eavesdrop/screens/submission_page/local_widgets/all_page_local.dart';
import 'package:eavesdrop/states/gwa_player_state.dart';
import 'package:eavesdrop/utils/gwa_functions.dart';
import 'package:eavesdrop/utils/util_functions.dart';
import 'package:eavesdrop/widgets/gwa_author_flair.dart';
import 'package:eavesdrop/widgets/markdown_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import 'expandable_player_image.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({
    Key key,
    @required this.expansionProgress,
    @required this.paletteGenerator,
    this.onTapPlaylistButton,
    this.audioListButtonSubmissionFullname,
    this.inCurrentSubmissionPage,
  }) : super(key: key);

  final Animation<double> expansionProgress;
  final PaletteGenerator paletteGenerator;
  final void Function() onTapPlaylistButton;
  final String audioListButtonSubmissionFullname;
  final bool Function() inCurrentSubmissionPage;

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
                audioListButtonSubmissionFullname:
                    widget.audioListButtonSubmissionFullname,
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
                child: PopupTextButton(
                  heroTag: 'player-view-title-popup-tag',
                  fullText: MarkdownViewer(
                    inPopupCard: true,
                    text: '## Title\n'
                        '>${state.currentAudioSourceTitle}\n\n'
                        '## File Title\n'
                        '>${state.currentAudioSourceFileTitle}\n\n',
                    blockQuoteDecoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      color: Theme.of(context).primaryColor,
                    ),
                    bodyTextColor: Colors.white,
                    bodyTextFontSize: 16.0,
                  ),
                  text: Container(
                    child: Text(
                      state.currentAudioSourceTitle ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget
                            .paletteGenerator.dominantColor.titleTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    splashColor: lighten(
                        widget.paletteGenerator.dominantColor.titleTextColor,
                        0.7),
                    onLongPress: () async {
                      Navigator.pushNamedAndRemoveUntil(
                          context,
                          ExtractArgumentsSubmissionList.routeName,
                          (Route<dynamic> route) => false,
                          arguments: SubmissionListArguments(
                              'author:${state.currentAudioSourceAuthor}',
                              Sort.newest,
                              TimeFilter.all));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.currentAudioSourceAuthor ?? '',
                          style: TextStyle(
                            color: darken(
                                widget.paletteGenerator.dominantColor
                                    .titleTextColor,
                                0.2),
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0,
                          ),
                        ),
                        GwaAuthorFlair(
                          width: 16,
                          height: 14,
                          flair: state.currentAudioSourceAuthorFlairText ?? '',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              PlayControls(
                inPlaylistView: false,
                paletteGenerator: widget.paletteGenerator,
                onTapPlaylistButton: widget.onTapPlaylistButton,
                inCurrentSubmissionPage: widget.inCurrentSubmissionPage,
              ),
            ],
          );
        }),
      ),
    );
  }
}
