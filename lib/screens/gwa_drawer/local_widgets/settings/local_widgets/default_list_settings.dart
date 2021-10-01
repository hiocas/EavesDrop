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
    @required this.onFABPressed,
    @required this.heroTag,
    @required this.noChildrenMessage,
    this.fabIcon = Icons.add,
    this.fabColor,
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
  final void Function() onFABPressed;
  final IconData fabIcon;
  final Color fabColor;
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
      content: SizedBox(
        height: height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Material(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12.0),
              child: length == 0
                  ? Center(
                      child: Expanded(
                        child: Text(
                          noChildrenMessage,
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 14.0),
                        ),
                      ),
                    )
                  : list,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: heroTag,
                backgroundColor:
                    this.fabColor ?? Theme.of(context).primaryColor,
                child: Icon(fabIcon),
                onPressed: onFABPressed,
              ),
            )
          ],
        ),
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
    @required this.onFABPressed,
    @required this.heroTag,
    @required this.noChildrenMessage,
    this.fabIcon = Icons.add,
    this.fabColor,
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
  final void Function() onFABPressed;
  final IconData fabIcon;
  final Color fabColor;
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
      onFABPressed: onFABPressed,
      fabIcon: fabIcon,
      fabColor: fabColor,
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
    @required this.onFABPressed,
    @required this.heroTag,
    @required this.noChildrenMessage,
    this.fabIcon = Icons.add,
    this.fabColor,
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
  final void Function() onFABPressed;
  final IconData fabIcon;
  final Color fabColor;
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
      onFABPressed: onFABPressed,
      fabIcon: fabIcon,
      fabColor: fabColor,
      heroTag: heroTag,
      length: length,
      height: height,
      noChildrenMessage: noChildrenMessage,
    );
  }
}
