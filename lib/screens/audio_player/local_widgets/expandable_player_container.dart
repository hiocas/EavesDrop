import 'package:flutter/material.dart';

class ExpandablePlayerContainer extends AnimatedWidget {
  const ExpandablePlayerContainer({
    Key key,
    @required Animation<double> animation,
    @required this.child,
    this.collapsedColor,
    this.expandedColor = Colors.white,
    this.iconColor = Colors.grey,
    @required this.onTap,
  })  : assert(onTap != null),
        super(key: key, listenable: animation);

  final Widget child;
  final Color collapsedColor;
  final Color expandedColor;
  final Color iconColor;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final Animation animation = listenable as Animation<double>;
    return Align(
      alignment: Alignment.center,
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            margin: Tween<EdgeInsets>(
                    begin: EdgeInsets.all(16.0), end: EdgeInsets.zero)
                .animate(animation)
                .value,
            decoration: BoxDecoration(
              borderRadius: Tween<BorderRadius>(
                      begin: BorderRadius.circular(24.0),
                      end: BorderRadius.zero)
                  .animate(animation)
                  .value,
              color: ColorTween(
                begin: collapsedColor ?? Colors.white,
                end: expandedColor,
              ).animate(animation).value,
            ),
            child: GestureDetector(
              onTap: animation.value <= 0.08 ? onTap : null,
              child: child,
            ),
          ),
          Visibility(
            visible: animation.value > 0.08,
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.deferToChild,
              child: Container(
                height: 120,
                color: Colors.transparent,
                child: animation.value >= 0.8
                    ? AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: animation.value >= 0.88 ? 1.0 : 0.0,
                        child: Center(
                          child: Icon(
                            Icons.expand_more,
                            color: this.iconColor,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
