import 'package:eavesdrop/widgets/markdown_viewer.dart';
import 'package:flutter/material.dart';

class Setting extends StatelessWidget {
  final IconData icon;
  final String settingName;
  final double spacing;
  final Widget explanation;
  final double spaceHead;
  final Widget content;

  const Setting({
    Key key,
    @required this.icon,
    @required this.settingName,
    @required this.content,
    this.spacing = 0.0,
    this.explanation,
    this.spaceHead = 15.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: spaceHead ?? 0.0),
      child: ExpansionTile(
        title: Text(
          settingName,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        leading: Icon(
          icon,
          color: Colors.white,
          size: 35.0,
        ),
        tilePadding: EdgeInsets.only(left: 16.0),
        children: [
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
      ),
    );
  }
}

class OptionSetting extends StatelessWidget {
  const OptionSetting({
    Key key,
    @required this.icon,
    @required this.settingName,
    this.spacing,
    @required this.options,
    this.explanation,
    this.spaceHead = 15.0,
  }) : super(key: key);

  final IconData icon;
  final String settingName;
  final double spacing;
  final List<SettingOption> options;
  final Widget explanation;
  final double spaceHead;

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
