import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'navigator_routes/hero_dialog_route.dart';
import 'package:gwa_app/widgets/icon_text_button.dart';

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(HeroDialogRoute(builder: (context) {
              return _PopupWidget(
                widget: this.widget,
                heroTag: this.heroTag,
              );
            }));
          },
          child: Hero(
            tag: this.heroTag,
            child: IconTextButtonElement(
              label: this.label,
              icon: this.icon,
              color: this.color,
              backgroundColor: this.backgroundColor,
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
                              borderRadius: BorderRadius.all(Radius.circular(22.0))),
                        ),
                      ),
                    ),
                  );
                }
                print('hey');
                return this.placeholder;
              }
              return SizedBox(width: size.width, height: size.height,);
            },
          ),
        ),
        IconTextButtonSubtext(
          subtext: this.subtext ?? '',
          subtextColor: this.subtextColor,
        )
      ],
    );
  }
}

class _PopupWidget extends StatelessWidget {
  final String heroTag;
  final Widget widget;
  final Color color;
  final Axis scrollDirection;

  const _PopupWidget({
    Key key,
    @required this.widget,
    @required this.heroTag,
    this.color,
    this.scrollDirection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: this.heroTag,
          child: this.widget,
        ),
      ),
    );
  }
}
