import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'navigator_routes/hero_dialog_route.dart';
import 'icon_text_button.dart';
import 'rect_tweens/calm_rect_tween.dart';

class CustomPopupWidgetButton extends StatelessWidget {
  final String label;
  final String subtext;
  final IconData icon;
  final Color color;
  final Color subtextColor;
  final Color backgroundColor;
  final String heroTag;
  final Widget widget;
  ///If this is true, the placeholder will be the default one I made unless the [placeholder] parameter is specified. If it isn't the placeholder will be the normal default placeholder.
  final bool usePlaceholder;
  final Widget placeholder;
  final bool mini;

  const CustomPopupWidgetButton({
    Key key,
    this.label,
    this.subtext,
    @required this.icon,
    this.color,
    this.subtextColor,
    this.backgroundColor,
    @required this.heroTag,
    @required this.widget,
    this.usePlaceholder,
    this.placeholder,
    this.mini = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Feedback.forTap(context);
            Navigator.of(context).push(HeroDialogRoute(builder: (context) {
              return _PopupWidget(
                widget: this.widget,
                heroTag: this.heroTag,
              );
            }));
          },
          child: Hero(
            tag: this.heroTag,
            createRectTween: (begin, end) =>
                CalmRectTween(begin: begin, end: end),
            child: IconTextButtonElement(
              label: this.label,
              icon: this.icon,
              color: this.color,
              backgroundColor: this.backgroundColor,
              mini: this.mini,
            ),
            placeholderBuilder: (context, size, widget) {
              if (this.usePlaceholder ?? false) {
                if (this.placeholder == null) {
                  return Container(
                    width: size.width,
                    height: size.height,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 65,
                        height: 65,
                        child: Material(
                          color: Colors.black.withOpacity(0.3),
                          elevation: 15.0,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(22.0))),
                        ),
                      ),
                    ),
                  );
                }
                return this.placeholder;
              }
              return SizedBox(
                width: size.width,
                height: size.height,
              );
            },
          ),
        ),
        (this.mini ? Container() : IconTextButtonSubtext(
          subtext: this.subtext ?? '',
          subtextColor: this.subtextColor,
        ))
      ],
    );
  }
}

class _PopupWidget extends StatelessWidget {
  final String heroTag;
  final Widget widget;

  const _PopupWidget({
    Key key,
    @required this.widget,
    @required this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: this.heroTag,
          createRectTween: (begin, end) =>
              CalmRectTween(begin: begin, end: end),
          child: this.widget,
        ),
      ),
    );
  }
}
