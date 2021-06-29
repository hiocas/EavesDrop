import 'package:flutter/material.dart';
import 'package:gwa_app/models/app_settings.dart';
import 'package:gwa_app/models/audio_launch_options.dart';
import 'package:gwa_app/models/hive_boxes.dart';
import 'package:gwa_app/widgets/gradient_title_appbar.dart';
import 'package:gwa_app/utils/util_functions.dart'
    show audioLaunchOptionToString;
import 'package:gwa_app/widgets/markdown_viewer.dart';
import 'package:hive/hive.dart';

class Settings extends StatefulWidget {
  const Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  AudioLaunchOptions _audioLaunchOptions;
  bool _miniButtons;
  bool _librarySmallSubmissions;
  Box<AppSettings> _box;

  @override
  void dispose() {
    if (_box != null) {
      _box.close();
    }
    super.dispose();
  }

  _SettingOption<AudioLaunchOptions> _makeAudioLaunchOptionSettingOption(
      BuildContext context,
      {AudioLaunchOptions value,
      String subtitle}) {
    return _SettingOption<AudioLaunchOptions>(context,
        value: value,
        title: audioLaunchOptionToString(value),
        subtitle: subtitle,
        groupValue: _audioLaunchOptions, onChanged: (v) async {
      await HiveBoxes.editAppSettings(audioLaunchOptions: v);
      setState(() {
        _audioLaunchOptions = v;
      });
    });
  }

  _SettingOption<bool> _makeMiniButtonsSettingOption(BuildContext context,
      {bool value, String title, String subtitle}) {
    return _SettingOption<bool>(context,
        value: value,
        title: title,
        subtitle: subtitle,
        groupValue: _miniButtons, onChanged: (v) async {
      await HiveBoxes.editAppSettings(miniButtons: v);
      setState(() {
        _miniButtons = v;
      });
    });
  }

  _SettingOption<bool> _makeLibrarySmallSubmissionsSettingOption(
      BuildContext context,
      {bool value,
      String title,
      String subtitle}) {
    return _SettingOption<bool>(context,
        value: value,
        title: title,
        subtitle: subtitle,
        groupValue: _librarySmallSubmissions, onChanged: (v) async {
      await HiveBoxes.editAppSettings(librarySmallSubmissions: v);
      setState(() {
        _librarySmallSubmissions = v;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientTitleAppBar(
        context,
        title: 'Settings',
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: FutureBuilder<Box<AppSettings>>(
          future: HiveBoxes.openAppSettingsBox(),
          builder: (context, futureBox) {
            if (futureBox.hasData) {
              _box = futureBox.data;
              AppSettings _appSettings = futureBox.data.getAt(0);
              _audioLaunchOptions = _appSettings.audioLaunchOptions;
              _miniButtons = _appSettings.miniButtons;
              _librarySmallSubmissions = _appSettings.librarySmallSubmissions;
              return Center(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    // AudioLaunchOption setting
                    _Setting(
                      icon: Icons.play_circle_filled_outlined,
                      settingName:
                          'Choose your preferred web launcher for detected audio '
                          'links:',
                      spaceHead: false,
                      options: [
                        _makeAudioLaunchOptionSettingOption(context,
                            value: AudioLaunchOptions.ChromeCustomTabs,
                            subtitle:
                                "Allows you to play audio while your phone is "
                                "locked but, since it's Chrome, your activity "
                                "will be saved in your Chrome history."),
                        _makeAudioLaunchOptionSettingOption(context,
                            value: AudioLaunchOptions.WebView,
                            subtitle: "Your activity will not be saved in your "
                                "Chrome history but audio played while your "
                                "phone is locked will be choppy and laggy (not "
                                "a very pleasant experience).")
                      ],
                      explanation: ExpansionTile(
                        title: Text('What is this?'),
                        textColor: Colors.white,
                        iconColor: Colors.white,
                        collapsedTextColor: Colors.grey[400],
                        collapsedIconColor: Colors.grey[400],
                        children: [
                          ListTile(
                            title: MarkdownViewer(
                              inPopupCard: false,
                              text:
                                  "When you click on the large play button after opening a post, this setting tells the app which browser to open the audio link with.\n\n"
                                  "**Chrome Custom Tabs** is the default option. It's downside is that your browsing history in it is automatically saved to your Chrome history.\n\n"
                                  "**WebView** is the other option. It won't save your history to your chrome history but if you lock your phone while listening to the audio it will be choppy (this is because WebView uses an older method to handle background audio tasks. If you're using an older version of Android, it may not be choppy and actually be usable).\n"
                                  "This is the reason the WakeLock button exists on there. I know it's a very invasive solution but it's genuinely the only solution I've managed to find and implement in time.\n\n"
                                  "Unfortunately, these are the only ways I managed to find to launch web content.\n\n"
                                  "In the future, I'd like to have a custom made player for posts built into the app. This would hopefully solve most of these issues.\n\n"
                                  "Also, if you know of a better way we can do this where both downsides are nonexistent, please contribute to this project on GitHub!",
                              bodyTextFontSize: 14.0,
                              bodyTextColor: Colors.grey[400],
                            ),
                          )
                        ],
                      ),
                    ),
                    // Action Button Size Setting
                    _Setting(
                        icon: Icons.aspect_ratio_outlined,
                        settingName: "Choose your action buttons' size:",
                        options: [
                          _makeMiniButtonsSettingOption(
                            context,
                            value: false,
                            title: "Default",
                            subtitle:
                                "Will show bigger buttons and a subtext to "
                                "describe what they each do.",
                          ),
                          _makeMiniButtonsSettingOption(
                            context,
                            value: true,
                            title: "Small",
                            subtitle:
                                "Will show smaller buttons consisting only of "
                                "an icon an a label.",
                          ),
                        ]),
                    // Library Cross Axis Extent Setting
                    _Setting(
                        icon: Icons.grid_view_outlined,
                        settingName: "Choose your library's posts size:",
                        options: [
                          _makeLibrarySmallSubmissionsSettingOption(context,
                              title: 'Big', value: false),
                          _makeLibrarySmallSubmissionsSettingOption(context,
                              title: 'Small', value: true),
                        ])
                  ],
                ),
              ));
            }
            return CircularProgressIndicator();
          }),
    );
  }
}

class _Setting extends StatelessWidget {
  const _Setting({
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
  final List<_SettingOption> options;
  final Widget explanation;
  final bool spaceHead;

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
        Column(
          mainAxisSize: MainAxisSize.min,
          children: options,
        ),
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

class _SettingOption<T> extends RadioListTile<T> {
  _SettingOption(BuildContext context,
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
