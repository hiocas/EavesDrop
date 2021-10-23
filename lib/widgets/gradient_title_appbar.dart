import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GradientTitleAppBar extends AppBar {
  GradientTitleAppBar(BuildContext context,
      {@required String title,
      Color backgroundColor,
      Gradient gradient,
      double elevation})
      : super(
          elevation: elevation,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.0),
                  bottomRight: Radius.circular(24.0))),
          titleSpacing: 0.0,
          backgroundColor: Colors.transparent,
          backwardsCompatibility: false,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                color: backgroundColor ?? Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24.0),
                    bottomRight: Radius.circular(24.0))),
          ),
          title: ShaderMask(
            shaderCallback: (bounds) {
              if (gradient != null)
                return gradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height));
              return LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.secondary,
                ],
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
            },
            child: Text(
              title,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 26.0),
            ),
          ),
        );
}
