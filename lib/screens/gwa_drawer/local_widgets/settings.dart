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
  Box<AppSettings> _box;
  double _spacing = 15.0;

  @override
  void dispose() {
    if (_box != null) {
      _box.close();
    }
    super.dispose();
  }

  RadioListTile<AudioLaunchOptions> _makeAudioLaunchOptionRadioListTile(
      {AudioLaunchOptions value, String subtitle}) {
    return RadioListTile<AudioLaunchOptions>(
        activeColor: Theme.of(context).primaryColor,
        value: value,
        title: Text(
          audioLaunchOptionToString(value),
          style: TextStyle(color: Colors.white),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: TextStyle(color: Colors.grey[400]))
            : null,
        groupValue: _audioLaunchOptions,
        onChanged: (v) async {
          await HiveBoxes.editAppSettings(audioLaunchOptions: v);
          setState(() {
            _audioLaunchOptions = v;
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
              /* TODO: Create this when the app is first opened so we won't
                  have to check for null values. */
              if (_appSettings.audioLaunchOptions != null) {
                _audioLaunchOptions = _appSettings.audioLaunchOptions;
              } else {
                HiveBoxes.editAppSettings(
                    audioLaunchOptions: AudioLaunchOptions.ChromeCustomTabs);
                _audioLaunchOptions = AudioLaunchOptions.ChromeCustomTabs;
              }
              return Center(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.play_circle_filled_outlined,
                        color: Colors.white,
                        size: 35.0,
                      ),
                      title: Text(
                        'Choose your preferred web launcher for detected audio '
                        'links:',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0),
                      ),
                    ),
                    SizedBox(height: _spacing),
                    _makeAudioLaunchOptionRadioListTile(
                        value: AudioLaunchOptions.ChromeCustomTabs,
                        subtitle:
                            "Allows you to play audio while your phone is locked "
                            "but, since it's Chrome, your activity will be saved "
                            "in your Chrome history."),
                    _makeAudioLaunchOptionRadioListTile(
                        value: AudioLaunchOptions.WebView,
                        subtitle:
                            "Your activity will not be saved in your Chrome "
                            "history but audio played while your phone is locked "
                            "will be choppy and laggy (not a very pleasant "
                            "experience)."),
                    ExpansionTile(
                      title: Text('What is this?'),
                      textColor: Colors.white,
                      iconColor: Colors.white,
                      collapsedTextColor: Colors.grey[400],
                      collapsedIconColor: Colors.grey[400],
                      children: [
                        ListTile(
                          title: MarkdownViewer(
                            fromLibrary: false,
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
                    Divider(
                      thickness: 1.0,
                      color: Colors.black26,
                    )
                  ],
                ),
              ));
            }
            return CircularProgressIndicator();
          }),
    );
  }
}
