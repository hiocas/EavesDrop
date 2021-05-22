import 'dart:ui';
import 'package:flutter/widgets.dart';

// THIS ISN'T MY CODE
/// {@template calm_rect_tween}
/// A less dramatic [RectTween] used in [Hero] animations.
/// {@endtemplate}
class CalmRectTween extends RectTween {
  CalmRectTween({
    @required Rect begin,
    @required Rect end,
  }) : super(begin: begin, end: end);

  @override
  Rect lerp(double t) {
    final elasticCurveValue = Curves.easeOut.transform(t);
    return Rect.fromLTRB(
      lerpDouble(begin.left, end.left, elasticCurveValue),
      lerpDouble(begin.top, end.top, elasticCurveValue),
      lerpDouble(begin.right, end.right, elasticCurveValue),
      lerpDouble(begin.bottom, end.bottom, elasticCurveValue),
    );
  }
}
