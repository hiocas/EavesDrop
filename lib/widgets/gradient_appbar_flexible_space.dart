import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GradientAppBarFlexibleSpace extends StatelessWidget {
  const GradientAppBarFlexibleSpace({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0)),
        gradient: LinearGradient(colors: [
          Theme.of(context).primaryColor,
          Theme.of(context).cardColor,
        ], begin: Alignment.bottomLeft, end: Alignment.bottomRight),
      ),
    );
  }
}
