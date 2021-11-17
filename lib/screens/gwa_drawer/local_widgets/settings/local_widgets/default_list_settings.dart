import 'package:flutter/material.dart';

import 'default_settings.dart';

class _DefaultListSetting extends StatelessWidget {
  const _DefaultListSetting({
    Key key,
    @required this.list,
    @required this.icon,
    @required this.settingName,
    @required this.length,
    @required this.itemBuilder,
    @required this.onButtonPressed,
    @required this.heroTag,
    @required this.noChildrenMessage,
    this.buttonIcon = Icons.add,
    this.buttonColor,
    this.buttonText = 'Add',
    this.spacing = 15.0,
    this.explanation,
    this.spaceHead = 15.0,
    this.height = 110.0,
  }) : super(key: key);

  final Widget list;
  final IconData icon;
  final String settingName;
  final double spacing;
  final Widget explanation;
  final double spaceHead;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final void Function() onButtonPressed;
  final IconData buttonIcon;
  final Color buttonColor;
  final String buttonText;
  final String heroTag;
  final int length;
  final double height;
  final String noChildrenMessage;

  @override
  Widget build(BuildContext context) {
    return Setting(
      icon: icon,
      settingName: settingName,
      spacing: spacing,
      explanation: explanation,
      spaceHead: spaceHead,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: length == 0
                ? Center(
                    child: Expanded(
                      child: Text(
                        noChildrenMessage,
                        style:
                            TextStyle(color: Colors.grey[400], fontSize: 14.0),
                      ),
                    ),
                  )
                : list,
          ),
          Hero(
            tag: heroTag,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  this.buttonColor ?? Theme.of(context).primaryColor,
                ),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              onPressed: onButtonPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(buttonText),
                  const SizedBox(width: 8),
                  Icon(buttonIcon),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GridSetting extends StatelessWidget {
  const GridSetting({
    Key key,
    @required this.icon,
    @required this.settingName,
    @required this.length,
    @required this.itemBuilder,
    @required this.onButtonPressed,
    @required this.heroTag,
    @required this.noChildrenMessage,
    this.buttonIcon = Icons.add,
    this.buttonText = 'Add',
    this.buttonColor,
    this.spacing = 0.0,
    this.explanation,
    this.spaceHead = 15.0,
    this.height = 110.0,
  }) : super(key: key);

  final IconData icon;
  final String settingName;
  final double spacing;
  final Widget explanation;
  final double spaceHead;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final void Function() onButtonPressed;
  final IconData buttonIcon;
  final String buttonText;
  final Color buttonColor;
  final String heroTag;
  final int length;
  final double height;
  final String noChildrenMessage;

  @override
  Widget build(BuildContext context) {
    return _DefaultListSetting(
      list: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisExtent: 120.0,
          mainAxisSpacing: 4.0,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: length,
        padding: const EdgeInsets.only(left: 16.0),
        itemBuilder: itemBuilder,
      ),
      icon: icon,
      settingName: settingName,
      spacing: spacing,
      explanation: explanation,
      spaceHead: spaceHead,
      itemBuilder: itemBuilder,
      onButtonPressed: onButtonPressed,
      buttonIcon: buttonIcon,
      buttonColor: buttonColor,
      buttonText: buttonText,
      heroTag: heroTag,
      length: length,
      height: height,
      noChildrenMessage: noChildrenMessage,
    );
  }
}

class ListSetting extends StatelessWidget {
  const ListSetting({
    Key key,
    @required this.icon,
    @required this.settingName,
    @required this.length,
    @required this.itemBuilder,
    @required this.onButtonPressed,
    @required this.heroTag,
    @required this.noChildrenMessage,
    this.buttonIcon = Icons.add,
    this.buttonText = 'Add',
    this.buttonColor,
    this.spacing = 0.0,
    this.explanation,
    this.spaceHead = 15.0,
    this.height = 110.0,
  }) : super(key: key);

  final IconData icon;
  final String settingName;
  final double spacing;
  final Widget explanation;
  final double spaceHead;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final void Function() onButtonPressed;
  final IconData buttonIcon;
  final Color buttonColor;
  final String buttonText;
  final String heroTag;
  final int length;
  final double height;
  final String noChildrenMessage;

  @override
  Widget build(BuildContext context) {
    return _DefaultListSetting(
      list: ListView.builder(
        itemCount: length,
        padding: const EdgeInsets.only(left: 16.0),
        itemBuilder: itemBuilder,
      ),
      icon: icon,
      settingName: settingName,
      spacing: spacing,
      explanation: explanation,
      spaceHead: spaceHead,
      itemBuilder: itemBuilder,
      onButtonPressed: onButtonPressed,
      buttonIcon: buttonIcon,
      buttonText: buttonText,
      buttonColor: buttonColor,
      heroTag: heroTag,
      length: length,
      height: height,
      noChildrenMessage: noChildrenMessage,
    );
  }
}
