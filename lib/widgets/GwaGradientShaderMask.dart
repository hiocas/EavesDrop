import 'package:flutter/material.dart';

class GwaGradientShaderMask extends ShaderMask {
  GwaGradientShaderMask(
    BuildContext context, {
    @required Widget child,
  }) : super(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).accentColor,
              ],
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
          },
          child: child,
        );
}
