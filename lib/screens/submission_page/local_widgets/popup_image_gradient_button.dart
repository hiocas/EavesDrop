import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:eavesdrop/widgets/navigator_routes/hero_dialog_route.dart';
import 'package:eavesdrop/widgets/rect_tweens/calm_rect_tween.dart';

//FIXME: Fix the return animation of the image.
class PopupImageGradientButton extends StatelessWidget {
  final String heroTag;
  final Image image;

  const PopupImageGradientButton({
    Key key,
    @required this.heroTag,
    @required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Feedback.forTap(context);
        Navigator.of(context).push(HeroDialogRoute(builder: (context) {
          return _PopupImageGradientFullPage(
            heroTag: this.heroTag,
            image: this.image,
          );
        }));
      },
      child: Hero(
        tag: this.heroTag,
        createRectTween: (begin, end) => CalmRectTween(begin: begin, end: end),
        child: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black, Colors.transparent],
            ).createShader(bounds);
          },
          blendMode: BlendMode.multiply,
          child: this.image,
        ),
      ),
    );
  }
}

@Deprecated('Using _PopupImageGradientFullPage now instead of this class.')
class _PopupImageGradientPage extends StatelessWidget {
  final String heroTag;
  final Image image;

  const _PopupImageGradientPage({
    Key key,
    @required this.heroTag,
    @required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      createRectTween: (begin, end) => CalmRectTween(begin: begin, end: end),
      child: GestureDetector(
        onDoubleTap: () {
          Navigator.of(context).pop(HeroDialogRoute(builder: (context) {
            return;
          }));
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
            image: DecorationImage(
              image: this.image.image,
              fit: BoxFit.fitHeight,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  child: InteractiveViewer(
                    child: this.image,
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

class _PopupImageGradientFullPage extends StatelessWidget {
  final String heroTag;
  final Image image;

  const _PopupImageGradientFullPage({
    Key key,
    @required this.heroTag,
    @required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      createRectTween: (begin, end) => CalmRectTween(begin: begin, end: end),
      child: Container(
        color: Theme.of(context).primaryColor,
        child: SafeArea(
          child: GestureDetector(
            onDoubleTap: () {
              Navigator.of(context).pop(HeroDialogRoute(builder: (context) {
                return;
              }));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32.0),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: this.image.image,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: InteractiveViewer(
                    maxScale: 5.0,
                    child: FittedBox(
                      child: this.image,
                    ),
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
