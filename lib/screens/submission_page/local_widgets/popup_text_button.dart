import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gwa_app/widgets/navigator_routes/hero_dialog_route.dart';
import 'package:gwa_app/widgets/rect_tweens/calm_rect_tween.dart';

//TODO(Design): Make an actual animation for this.
class PopupTextButton extends StatelessWidget {
  final String heroTag;
  final Widget text;
  final String fullText;
  final Color cardColor;

  const PopupTextButton({
    Key key,
    @required this.heroTag,
    @required this.text,
    @required this.fullText,
    this.cardColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(HeroDialogRoute(builder: (context) {
          return _PopupTextCard(
            heroTag: this.heroTag,
            fullText: this.fullText,
            color: this.cardColor,
          );
        }));
      },
      child: Hero(
        tag: this.heroTag,
        child: this.text,
        flightShuttleBuilder: _flightShuttleBuilder,
      ),
    );
  }

  Widget _flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return DefaultTextStyle(
        style: DefaultTextStyle.of(toHeroContext).style,
        child: toHeroContext.widget);
  }
}

class _PopupTextCard extends StatelessWidget {
  final String heroTag;
  final String fullText;
  final Color color;

  const _PopupTextCard({
    Key key,
    @required this.heroTag,
    @required this.fullText,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: heroTag,
          createRectTween: (begin, end) =>
              CalmRectTween(begin: begin, end: end),
          child: Material(
            color: color ?? Theme.of(context).backgroundColor,
            elevation: 2.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  this.fullText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
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
