import 'package:flutter/material.dart';

class SlideFadeTransition extends StatelessWidget {
  const SlideFadeTransition({
    Key key,
    @required this.animation,
    @required this.child,
    this.beginOffset = const Offset(0.0, 0.06),
    this.endOffset = Offset.zero,
    this.slideCurve = Curves.easeInOut,
  }) : super(key: key);

  final Animation<double> animation;
  final Widget child;
  final Offset beginOffset;
  final Offset endOffset;
  final Curve slideCurve;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: this.beginOffset,
        end: this.endOffset,
      ).animate(CurvedAnimation(
          parent: this.animation, curve: this.slideCurve)),
      child: FadeTransition(
        opacity: this.animation,
        child: this.child,
      ),
    );
  }
}
