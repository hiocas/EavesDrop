import 'package:eavesdrop/utils/gwa_functions.dart';
import 'package:eavesdrop/utils/util_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:rubber/rubber.dart';

class ExpandingAudioPlayer extends StatefulWidget {
  const ExpandingAudioPlayer({
    Key key,
    @required this.background,
  }) : super(key: key);

  final Widget background;

  @override
  _ExpandingAudioPlayerState createState() => _ExpandingAudioPlayerState();
}

class _ExpandingAudioPlayerState extends State<ExpandingAudioPlayer>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  RubberAnimationController _rubberAnimationController;
  PaletteGenerator _paletteGenerator;
  bool expanded = false;
  double _sliderVal = 0.0;
  String _submissionFullname = 't';

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
    super.initState();
    _setPaletteGenerator();
  }

  _setPaletteGenerator() async {
    _paletteGenerator = await PaletteGenerator.fromImageProvider(
        NetworkImage(GwaFunctions.getPlaceholderImageUrl(_submissionFullname)));
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
      upperLayer: Container(
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
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
              intensity: 0.8,
            ),
            child: Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ExpandablePlayerImage(
                        animation: expansionProgress,
                        url: GwaFunctions.getPlaceholderImageUrl(
                            _submissionFullname),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Text(
                          'Hey There',
                          style: TextStyle(
                            color:
                                _paletteGenerator.dominantColor.titleTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          'Hey There',
                          style: TextStyle(
                            color: darken(
                                _paletteGenerator.dominantColor.titleTextColor,
                                0.2),
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 24.0, right: 24.0, top: 24.0),
                        child: NeumorphicSlider(
                            height: 12.0,
                            style: SliderStyle(
                              depth: 16.0,
                              lightSource: LightSource.topLeft,
                              accent: _paletteGenerator.lightVibrantColor.color,
                              variant: _paletteGenerator
                                  .dominantColor.titleTextColor,
                            ),
                            value: _sliderVal,
                            onChanged: (value) => setState(() {
                                  _sliderVal = value;
                                })),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0, bottom: 0.0),
                        child: SizedBox(
                          width: 280,
                          child: Material(
                            type: MaterialType.transparency,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                PlayerIconButton(
                                  icon: CupertinoIcons.backward_fill,
                                  paletteGenerator: _paletteGenerator,
                                  onPressed: () {},
                                ),
                                PlayerIconButton(
                                  icon: CupertinoIcons.play_arrow_solid,
                                  iconSize: 65,
                                  paletteGenerator: _paletteGenerator,
                                  onPressed: () {},
                                ),
                                PlayerIconButton(
                                  icon: CupertinoIcons.forward_fill,
                                  paletteGenerator: _paletteGenerator,
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 60,
                        width: 180,
                        child: Material(
                          type: MaterialType.transparency,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              PlayerIconButton(
                                icon: CupertinoIcons.gobackward_15,
                                iconSize: 25,
                                paletteGenerator: _paletteGenerator,
                                onPressed: () {},
                              ),
                              PlayerIconButton(
                                icon: CupertinoIcons.square_arrow_up,
                                iconSize: 30,
                                paletteGenerator: _paletteGenerator,
                                onPressed: () {},
                              ),
                              PlayerIconButton(
                                icon: CupertinoIcons.goforward_15,
                                iconSize: 25,
                                paletteGenerator: _paletteGenerator,
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ExpandablePlayerContainer extends AnimatedWidget {
  const ExpandablePlayerContainer({
    Key key,
    @required Animation<double> animation,
    @required this.child,
    this.collapsedColor,
    this.expandedColor = Colors.white,
    this.iconColor = Colors.grey,
    @required this.onTap,
  })  : assert(onTap != null),
        super(key: key, listenable: animation);

  final Widget child;
  final Color collapsedColor;
  final Color expandedColor;
  final Color iconColor;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final Animation animation = listenable as Animation<double>;
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Container(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
            width: MediaQuery.of(context).size.width,
            margin: Tween<EdgeInsets>(
                    begin: EdgeInsets.all(16.0), end: EdgeInsets.zero)
                .animate(animation)
                .value,
            decoration: BoxDecoration(
              borderRadius: Tween<BorderRadius>(
                      begin: BorderRadius.circular(24.0),
                      end: BorderRadius.zero)
                  .animate(animation)
                  .value,
              color: ColorTween(
                      begin: collapsedColor ?? Colors.white, end: expandedColor)
                  .animate(animation)
                  .value,
            ),
            child: child,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120,
            color: Colors.transparent,
            child: animation.value >= 0.8
                ? AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: animation.value >= 0.81 ? 1.0 : 0.0,
                    child: Center(
                      child: Icon(
                        Icons.expand_more,
                        color: this.iconColor,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class ExpandablePlayerImage extends AnimatedWidget {
  const ExpandablePlayerImage({
    Key key,
    @required Animation<double> animation,
    @required this.url,
    this.maxSize = 250,
    this.minSize = 50,
  }) : super(key: key, listenable: animation);

  final String url;
  final double maxSize;
  final double minSize;

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
                begin: const EdgeInsets.only(left: 20.0), end: EdgeInsets.zero)
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
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hey There',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            'Hey There\'s author',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13.0,
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0),
                        child: Material(
                          type: MaterialType.transparency,
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.play_arrow),
                                iconSize: 33.0,
                                color: Colors.white,
                                splashColor: Colors.grey,
                                splashRadius: 20.0,
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: Icon(Icons.skip_next),
                                iconSize: 33.0,
                                color: Colors.white,
                                splashColor: Colors.grey,
                                splashRadius: 20.0,
                                onPressed: () {},
                              ),
                            ],
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

class PlayerIconButton extends StatelessWidget {
  const PlayerIconButton({
    Key key,
    @required this.icon,
    this.iconSize = 45,
    @required this.paletteGenerator,
    @required this.onPressed,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;
  final PaletteGenerator paletteGenerator;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
      ),
      iconSize: iconSize,
      color: paletteGenerator.dominantColor.titleTextColor,
      splashColor:
          paletteGenerator.dominantColor.bodyTextColor.withOpacity(0.2),
      splashRadius: 30,
      onPressed: onPressed,
    );
  }
}
