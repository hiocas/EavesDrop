import 'package:flutter/material.dart';

class GwaScrollbar extends StatelessWidget {
  const GwaScrollbar({
    Key key,
    this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thickness: 4.8,
      radius: Radius.circular(8.0),
      child: child,
    );
  }
}
