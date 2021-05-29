import 'package:flutter/material.dart';

class SlideFadeTransition extends StatelessWidget {
  const SlideFadeTransition({
    Key key,
    @required this.animationController,
    @required this.child,
    this.beginOffset,
    this.endOffset,
    this.slideCurve,
  }) : super(key: key);

  final AnimationController animationController;
  final Widget child;
  final Offset beginOffset;
  final Offset endOffset;
  final Curve slideCurve;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: this.beginOffset ?? Offset(0.0, 0.06),
        end: this.endOffset ?? Offset.zero,
      ).animate(CurvedAnimation(
          parent: this.animationController,
          curve: this.slideCurve ?? Curves.easeInOut)),
      child: FadeTransition(
        opacity: this.animationController,
        child: this.child,
      ),
    );
  }
}