import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'custom_popup_widget_button.dart';

class PopupCardButton extends StatelessWidget {
  final String label;
  final String subtext;
  final IconData icon;
  final Color color;
  final Color subtextColor;
  final Color backgroundColor;
  final String heroTag;
  final Widget child;
  final Color cardColor;
  final Axis cardScrollDirection;

  /// If this is true, the placeholder will be the default one I made
  /// unless the [placeholder] parameter is specified.
  /// If it isn't the placeholder will be the normal default placeholder.
  final bool usePlaceholder;
  final Widget placeholder;

  final bool mini;

  final EdgeInsets padding;

  const PopupCardButton({
    Key key,
    this.label,
    this.subtext,
    @required this.icon,
    this.color,
    this.subtextColor,
    this.backgroundColor,
    @required this.heroTag,
    @required this.child,
    this.cardColor,
    this.cardScrollDirection,
    this.usePlaceholder,
    this.placeholder,
    this.mini = false,
    this.padding = const EdgeInsets.all(0.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPopupWidgetButton(
      label: this.label,
      subtext: this.subtext,
      icon: this.icon,
      color: this.color,
      subtextColor: this.subtextColor,
      backgroundColor: this.backgroundColor,
      mini: this.mini,
      heroTag: this.heroTag,
      widget: DefaultPopupCard(
        heroTag: this.heroTag,
        child: this.child,
        color: this.cardColor,
        scrollDirection: this.cardScrollDirection,
        padding: this.padding,
      ),
      usePlaceholder: this.usePlaceholder,
      placeholder: this.placeholder,
    );
  }
}

class DefaultPopupCard extends StatelessWidget {
  final String heroTag;
  final Widget child;
  final Color color;
  final Axis scrollDirection;
  final EdgeInsets padding;

  const DefaultPopupCard({
    Key key,
    @required this.child,
    @required this.heroTag,
    this.color,
    this.scrollDirection,
    this.padding = const EdgeInsets.all(0.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        color: color ?? Theme.of(context).backgroundColor,
        elevation: 2.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
        child: Padding(
            padding: this.padding,
            child: SingleChildScrollView(
              scrollDirection: scrollDirection ?? Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: child,
              ),
            )));
  }
}
