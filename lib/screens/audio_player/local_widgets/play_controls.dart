import 'package:eavesdrop/screens/audio_player/local_widgets/player_icon_button.dart';
import 'package:eavesdrop/states/gwa_player_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

class PlayControls extends StatelessWidget {
  const PlayControls({
    Key key,
    @required this.paletteGenerator,
    @required this.onTapPlaylistButton,
    @required this.inPlaylistView,
  }) : super(key: key);

  final PaletteGenerator paletteGenerator;
  final void Function() onTapPlaylistButton;
  final bool inPlaylistView;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SeekBar(
          accent: paletteGenerator.lightVibrantColor.color,
          variant: paletteGenerator.dominantColor.titleTextColor,
        ),
        SizedBox(
          width: 270,
          child: Material(
            type: MaterialType.transparency,
            child: Consumer<GwaPlayerState>(
              builder: (context, state, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    PlayerIconButton(
                      icon: CupertinoIcons.backward_fill,
                      paletteGenerator: paletteGenerator,
                      onPressed: state.audioPlayer.currentIndex == 0
                          ? null
                          : () => state.audioPlayer.seekToPrevious(),
                    ),
                    PlayerIconButton(
                      icon: state.isPlaying
                          ? CupertinoIcons.pause_solid
                          : CupertinoIcons.play_arrow_solid,
                      iconSize: 65,
                      paletteGenerator: paletteGenerator,
                      onPressed: () {
                        if (state.isPlaying)
                          state.pause();
                        else
                          state.play();
                      },
                    ),
                    PlayerIconButton(
                      icon: CupertinoIcons.forward_fill,
                      paletteGenerator: paletteGenerator,
                      onPressed: state.audioPlayer.nextIndex == null
                          ? null
                          : () => state.seekToNext(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        SizedBox(
          height: 60,
          width: 200,
          child: Material(
            type: MaterialType.transparency,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                PlayerIconButton(
                  icon: CupertinoIcons.gobackward_15,
                  iconSize: 30,
                  paletteGenerator: paletteGenerator,
                  onPressed: () =>
                      Provider.of<GwaPlayerState>(context, listen: false)
                          .skipSeconds(-15),
                ),
                PlayerIconButton(
                  icon: inPlaylistView
                      ? CupertinoIcons.square_list_fill
                      : CupertinoIcons.square_list,
                  iconSize: 35,
                  paletteGenerator: paletteGenerator,
                  onPressed: onTapPlaylistButton,
                ),
                PlayerIconButton(
                  icon: CupertinoIcons.globe,
                  iconSize: 35,
                  paletteGenerator: paletteGenerator,
                  onPressed: () {
                    final ChromeSafariBrowser browser =
                        new ChromeSafariBrowser();
                    browser.open(
                        url: Provider.of<GwaPlayerState>(context, listen: false)
                            .currentAudioSourceSubmissionUrl,
                        options: ChromeSafariBrowserClassOptions(
                            android: AndroidChromeCustomTabsOptions(
                                addDefaultShareMenuItem: true),
                            ios: IOSSafariOptions(barCollapsingEnabled: true)));
                  },
                ),
                PlayerIconButton(
                  icon: CupertinoIcons.goforward_15,
                  iconSize: 30,
                  paletteGenerator: paletteGenerator,
                  onPressed: () =>
                      Provider.of<GwaPlayerState>(context, listen: false)
                          .skipSeconds(15),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class SeekBar extends StatefulWidget {
  const SeekBar({
    Key key,
    @required this.variant,
    @required this.accent,
  }) : super(key: key);

  final Color variant;
  final Color accent;

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  SliderStyle _sliderStyle;

  @override
  void initState() {
    _sliderStyle = SliderStyle(
      depth: 16.0,
      lightSource: LightSource.topLeft,
      accent: widget.accent,
      variant: widget.variant,
    );
    super.initState();
  }

  String _audioDurationToString(Duration duration) {
    if (duration.inHours < 1) {
      return '${duration.inMinutes}:${_doubleValue(duration.inSeconds % 60)}';
    }
    return '';
  }

  String _doubleValue(int value) {
    if (value < 10) {
      return '0$value';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0),
      child: Consumer<GwaPlayerState>(builder: (context, state, _) {
        return ValueListenableBuilder<Duration>(
          valueListenable: state.audioProgressNotifier,
          child: Text(
            _audioDurationToString(state.currentIndexedAudioSource.duration),
            style: TextStyle(color: widget.variant),
          ),
          builder: (context, value, child) {
            return Column(
              children: [
                NeumorphicSlider(
                  height: 8.0,
                  style: _sliderStyle,
                  min: 0,
                  max: state.currentIndexedAudioSource.duration.inSeconds
                      .toDouble(),
                  value: value.inSeconds.toDouble(),
                  onChanged: (value) => setState(
                    () {
                      state.audioPlayer.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _audioDurationToString(value),
                        style: TextStyle(color: widget.variant),
                      ),
                      child,
                    ],
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
