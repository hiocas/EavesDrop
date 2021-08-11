import 'package:eavesdrop/widgets/markdown_viewer.dart';
import 'package:flutter/material.dart';

class Setting extends StatelessWidget {
  final IconData icon;
  final String settingName;
  final double spacing;
  final Widget explanation;
  final bool spaceHead;
  final Widget content;

  const Setting({
    Key key,
    @required this.icon,
    @required this.settingName,
    @required this.content,
    this.spacing = 15.0,
    this.explanation,
    this.spaceHead = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: spaceHead ? spacing : 0.0,
        ),
        ListTile(
          leading: Icon(
            icon,
            color: Colors.white,
            size: 35.0,
          ),
          title: Text(
            settingName,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.0),
          ),
        ),
        SizedBox(height: spacing),
        content,
        explanation ??
            SizedBox(
              height: spacing,
            ),
        Divider(
          thickness: 1.0,
          color: Colors.black26,
        )
      ],
    );
  }
}

class OptionSetting extends StatelessWidget {
  const OptionSetting({
    Key key,
    @required this.icon,
    @required this.settingName,
    this.spacing = 15.0,
    @required this.options,
    this.explanation,
    this.spaceHead = true,
  }) : super(key: key);

  final IconData icon;
  final String settingName;
  final double spacing;
  final List<SettingOption> options;
  final Widget explanation;
  final bool spaceHead;

  @override
  Widget build(BuildContext context) {
    return Setting(
      icon: icon,
      settingName: settingName,
      spacing: spacing,
      explanation: explanation,
      spaceHead: spaceHead,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options,
      ),
    );
  }
}

class SettingOption<T> extends RadioListTile<T> {
  SettingOption(BuildContext context,
      {@required String title,
      String subtitle,
      @required T value,
      @required T groupValue,
      @required void Function(dynamic) onChanged})
      : super(
          activeColor: Theme.of(context).primaryColor,
          value: value,
          title: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          subtitle: subtitle != null
              ? Text(subtitle, style: TextStyle(color: Colors.grey[400]))
              : null,
          groupValue: groupValue,
          onChanged: onChanged,
        );
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
    this.fabIcon = Icons.add,
    this.fabColor,
    this.spacing = 15.0,
    this.explanation,
    this.spaceHead = true,
  }) : super(key: key);

  final IconData icon;
  final String settingName;
  final double spacing;
  final Widget explanation;
  final bool spaceHead;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final void Function() onFABPressed;
  final IconData fabIcon;
  final Color fabColor;
  final String heroTag;
  final int length;

  @override
  Widget build(BuildContext context) {
    return Setting(
      icon: icon,
      settingName: settingName,
      spacing: spacing,
      explanation: explanation,
      spaceHead: spaceHead,
      content: SizedBox(
        height: 110,
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
                          'You have no Warning Tags saved.',
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 14.0),
                        ),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisExtent: 120.0,
                        mainAxisSpacing: 4.0,
                      ),
                      // shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: length,
                      padding: const EdgeInsets.only(left: 16.0),
                      itemBuilder: itemBuilder,
                    ),
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

class SettingExplanation extends StatelessWidget {
  const SettingExplanation({
    Key key,
    @required this.title,
    @required this.explanation,
  }) : super(key: key);

  final String title;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(this.title),
      textColor: Colors.white,
      iconColor: Colors.white,
      collapsedTextColor: Colors.grey[400],
      collapsedIconColor: Colors.grey[400],
      children: [
        ListTile(
          title: MarkdownViewer(
            inPopupCard: false,
            text: this.explanation,
            bodyTextFontSize: 14.0,
            bodyTextColor: Colors.grey[400],
          ),
        )
      ],
    );
  }
}
