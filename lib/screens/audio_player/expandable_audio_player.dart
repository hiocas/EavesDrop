import 'package:eavesdrop/screens/audio_player/local_widgets/playlist_view.dart';
import 'package:eavesdrop/states/gwa_player_state.dart';
import 'package:eavesdrop/utils/gwa_functions.dart';
import 'package:eavesdrop/utils/util_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:rubber/rubber.dart';
import 'local_widgets/expandable_player_container.dart';
import 'local_widgets/player_view.dart';

class ExpandingAudioPlayer extends StatefulWidget {
  const ExpandingAudioPlayer({
    Key key,
    @required this.background,
    this.audioListButtonSubmissionFullname,
  }) : super(key: key);

  final Widget background;
  final String audioListButtonSubmissionFullname;

  @override
  _ExpandingAudioPlayerState createState() => _ExpandingAudioPlayerState();
}

class _ExpandingAudioPlayerState extends State<ExpandingAudioPlayer>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  RubberAnimationController _rubberAnimationController;
  PaletteGenerator _paletteGenerator;
  bool expanded = false;
  bool _playlist = false;

  @override
  void initState() {
    // _animationController = new AnimationController(
    //     duration: Duration(milliseconds: 500), vsync: this);
    _rubberAnimationController = RubberAnimationController(
      vsync: this,
      upperBoundValue: AnimationControllerValue(percentage: 1.0),
      lowerBoundValue: AnimationControllerValue(percentage: 0.14),
      duration: const Duration(milliseconds: 200),
      dismissable: true,
    );
    _rubberAnimationController.animationState.addListener(() {
      if (_rubberAnimationController.animationState.value ==
              AnimationState.expanded &&
          !expanded) {
        setState(() {
          expanded = true;
        });
      } else if (_rubberAnimationController.animationState.value ==
              AnimationState.collapsed &&
          expanded) {
        setState(() {
          expanded = false;
        });
      }
    });
    Provider.of<GwaPlayerState>(context, listen: false)
        .sequenceStateStream
        .listen((SequenceState sequenceState) {
      _setPaletteGenerator(
          (sequenceState.currentSource.tag as AudioData).coverUrl);
    });
    super.initState();
    _setPaletteGenerator(GwaFunctions.getPlaceholderImageUrl('0'));
  }

  _setPaletteGenerator(String imageUrl) async {
    _paletteGenerator =
        await PaletteGenerator.fromImageProvider(NetworkImage(imageUrl));
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rubberAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> expansionProgress =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _rubberAnimationController,
            curve: Interval(
                _rubberAnimationController.lowerBoundValue.percentage,
                _rubberAnimationController.upperBoundValue.percentage)));

    //TODO: Use a complimentary color palette.

    return RubberBottomSheet(
      animationController: _rubberAnimationController,
      lowerLayer: widget.background,
      upperLayer: ValueListenableBuilder<bool>(
          valueListenable:
              Provider.of<GwaPlayerState>(context).playerActiveNotifier,
          builder: (context, value, child) {
            if (value)
              return Container(
                child: ExpandablePlayerContainer(
                  animation: expansionProgress,
                  onTap: () {
                    if (_rubberAnimationController.animationState.value !=
                        AnimationState.expanded)
                      _rubberAnimationController.expand();
                    else
                      _rubberAnimationController.collapse();
                  },
                  expandedColor: _paletteGenerator.dominantColor.color,
                  collapsedColor: Theme.of(context).backgroundColor,
                  iconColor: _paletteGenerator.dominantColor.titleTextColor,
                  child: NeumorphicTheme(
                    theme: NeumorphicThemeData(
                      depth: 16,
                      lightSource: LightSource.topLeft,
                      shadowLightColor:
                          lighten(_paletteGenerator.dominantColor.color, 0.18),
                      baseColor: _paletteGenerator.dominantColor.color,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(16)),
                      intensity: 0.8,
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: _playlist
                              ? PlaylistView(
                                  paletteGenerator: _paletteGenerator,
                                  expansionProgress: expansionProgress,
                                  onTapPlaylistButton: () => setState(() {
                                    _playlist = false;
                                  }),
                                  audioListButtonSubmissionFullname:
                                      widget.audioListButtonSubmissionFullname,
                                )
                              : PlayerView(
                                  paletteGenerator: _paletteGenerator,
                                  expansionProgress: expansionProgress,
                                  onTapPlaylistButton: () => setState(() {
                                    _playlist = true;
                                  }),
                                  audioListButtonSubmissionFullname:
                                      widget.audioListButtonSubmissionFullname,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            else
              return Container();
          }),
    );
  }
}
