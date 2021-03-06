import 'package:flutter/material.dart';

class IconTextButton extends StatelessWidget {
  final String label;
  final String subtext;
  final IconData icon;
  final Color color;
  final Color subtextColor;
  final Color backgroundColor;
  final void Function() onPressed;

  const IconTextButton({
    Key key,
    @required this.label,
    this.subtext,
    @required this.icon,
    this.color,
    this.subtextColor,
    this.backgroundColor,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: IconTextButtonElement(
            label: this.label,
            icon: this.icon,
            color: this.color,
            backgroundColor: this.backgroundColor,
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

class IconTextButtonElement extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final bool mini;

  const IconTextButtonElement({
    Key key,
    this.label,
    this.icon,
    this.color,
    this.backgroundColor,
    this.mini = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.mini) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Container(
          width: 88,
          height: 45,
          child: Material(
            color: this.backgroundColor ?? Theme.of(context).backgroundColor,
            elevation: 15.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(14.0))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: this.color ?? Theme.of(context).primaryColor,
                  size: 28.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                      label ?? '',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: this.color ?? Theme.of(context).primaryColor)),
                )
              ],
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Container(
        width: 65,
        height: 65,
        child: Material(
          color: this.backgroundColor ?? Theme.of(context).backgroundColor,
          elevation: 15.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(22.0))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Icon(
                  icon,
                  color: this.color ?? Theme.of(context).primaryColor,
                  size: 28.0,
                ),
              ),
              Text(
                label ?? '',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: this.color ?? Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IconTextButtonSubtext extends StatelessWidget {
  final String subtext;
  final Color subtextColor;

  const IconTextButtonSubtext({
    Key key,
    @required this.subtext,
    this.subtextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86.0,
      height: 24.0,
      child: Text(
        this.subtext,
        textAlign: TextAlign.center,
        style:
            TextStyle(fontSize: 10.0, color: this.subtextColor ?? Colors.grey),
      ),
    );
  }
}
