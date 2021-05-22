import 'package:flutter/cupertino.dart';

// THIS ISN'T MY CODE
class ConstrainedView extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;

  const ConstrainedView({
    Key key,
    @required this.child,
    this.width = 250,
    this.height = 250,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < width || constraints.maxHeight < height) {
        return const Text('');
      }
      return child;
    });
  }
}
