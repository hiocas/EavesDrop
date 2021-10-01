import 'package:eavesdrop/models/library_gwa_submission.dart';
import 'package:eavesdrop/models/tag_list.dart';
import 'package:eavesdrop/screens/flat_home/new_home.dart';
import 'package:eavesdrop/screens/gwa_drawer/local_widgets/settings/local_widgets/library_list_tags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eavesdrop/models/app_settings.dart';
import 'package:eavesdrop/models/audio_launch_options.dart';
import 'package:eavesdrop/models/hive_boxes.dart';
import 'package:eavesdrop/models/placeholders_options.dart';
import 'package:eavesdrop/screens/gwa_drawer/gwa_drawer.dart';
import 'package:eavesdrop/utils/gwa_functions.dart';
import 'package:eavesdrop/widgets/gradient_title_appbar.dart';
import 'package:eavesdrop/utils/util_functions.dart'
    show audioLaunchOptionToString, placeholdersOptionsToString;
import 'package:hive/hive.dart';
import 'local_widgets/default_settings.dart';
import 'local_widgets/warning_tag_list.dart';

class Settings extends StatefulWidget {
  const Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  AudioLaunchOptions _audioLaunchOptions;
  PlaceholdersOptions _placeholdersOptions;
  bool _miniButtons;
  bool _librarySmallSubmissions;
  Box<AppSettings> _box;
  TagList _warningTagList;
  List<String> _libraryListTags;
  List<int> _libraryListTagsCount;

  @override
  void dispose() {
    if (_box != null) {
      _box.close();
    }
    super.dispose();
  }

  SettingOption<AudioLaunchOptions> _makeAudioLaunchOptionSettingOption(
      BuildContext context,
      {AudioLaunchOptions value,
      String subtitle}) {
    return SettingOption<AudioLaunchOptions>(context,
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

  SettingOption<PlaceholdersOptions> _makePlaceholdersOptionsSettingOption(
      BuildContext context,
      {PlaceholdersOptions value,
      String subtitle}) {
    return SettingOption<PlaceholdersOptions>(context,
        value: value,
        title: placeholdersOptionsToString(value),
        subtitle: subtitle,
        groupValue: _placeholdersOptions, onChanged: (v) async {
      await HiveBoxes.editAppSettings(placeholdersOptions: v);
      GwaFunctions.setPlaceholders(v);
      GwaDrawerManager.updateOnReturn = true;
      AnimateOnce.animate = true;
      setState(() {
        _placeholdersOptions = v;
      });
    });
  }

  SettingOption<bool> _makeMiniButtonsSettingOption(BuildContext context,
      {bool value, String title, String subtitle}) {
    return SettingOption<bool>(context,
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

  SettingOption<bool> _makeLibrarySmallSubmissionsSettingOption(
      BuildContext context,
      {bool value,
      String title,
      String subtitle}) {
    return SettingOption<bool>(context,
        value: value,
        title: title,
        subtitle: subtitle,
        groupValue: _librarySmallSubmissions, onChanged: (v) async {
      await HiveBoxes.editAppSettings(librarySmallSubmissions: v);
      GwaDrawerManager.updateOnReturn = true;
      setState(() {
        _librarySmallSubmissions = v;
      });
    });
  }

  Future<AppSettings> initSettings() async {
    final List<LibraryGwaSubmission> _saved =
        await HiveBoxes.getLibraryGwaSubmissionList();
    final _appSettings = await HiveBoxes.getAppSettings();
    _libraryListTags = _appSettings.libraryListsTags;
    _libraryListTagsCount = List.filled(_libraryListTags.length, 0);
    for (LibraryGwaSubmission submission in _saved) {
      for (String list in submission.lists) {
        _libraryListTagsCount[_libraryListTags.indexOf(list)]++;
      }
    }
    return _appSettings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientTitleAppBar(
        context,
        title: 'Settings',
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: FutureBuilder<AppSettings>(
          future: initSettings(),
          builder: (context, futureBox) {
            if (futureBox.hasData) {
              AppSettings _appSettings = futureBox.data;
              _audioLaunchOptions = _appSettings.audioLaunchOptions;
              _placeholdersOptions = _appSettings.placeholdersOptions;
              _miniButtons = _appSettings.miniButtons;
              _librarySmallSubmissions = _appSettings.librarySmallSubmissions;
              final List<String> _warningTags = _appSettings.warningTags;
              _warningTagList = TagList(_warningTags);
              return Center(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    // AudioLaunchOption setting
                    OptionSetting(
                        icon: Icons.play_circle_filled_outlined,
                        settingName:
                            'Choose your preferred audio playing method:',
                        spaceHead: 0.0,
                        options: [
                          _makeAudioLaunchOptionSettingOption(context,
                              value: AudioLaunchOptions.EavesDrop,
                              subtitle: "Use the in-app audio player."),
                          _makeAudioLaunchOptionSettingOption(context,
                              value: AudioLaunchOptions.ChromeCustomTabs,
                              subtitle:
                                  "Allows you to play audio while your phone is "
                                  "locked but, since it's Chrome, your activity "
                                  "will be saved in your Chrome history."),
                          _makeAudioLaunchOptionSettingOption(context,
                              value: AudioLaunchOptions.WebView,
                              subtitle:
                                  "Your activity will not be saved in your "
                                  "Chrome history but audio played while your "
                                  "phone is locked will be choppy and laggy (not "
                                  "a very pleasant experience).")
                        ],
                        explanation: SettingExplanation(
                          title: 'What is this?',
                          explanation:
                              "When you click on the large play button after opening a post, this setting tells the app which browser to open the audio link with.\n\n"
                              "**Chrome Custom Tabs** is the default option. It's downside is that your browsing history in it is automatically saved to your Chrome history.\n\n"
                              "**WebView** is the other option. It won't save your history to your chrome history but if you lock your phone while listening to the audio it will be choppy (this is because WebView uses an older method to handle background audio tasks. If you're using an older version of Android, it may not be choppy and actually be usable).\n"
                              "This is the reason the WakeLock button exists on there. I know it's a very invasive solution but it's genuinely the only solution I've managed to find and implement in time.\n\n"
                              "Unfortunately, these are the only ways I managed to find to launch web content.\n\n"
                              "In the future, I'd like to have a custom made player for posts built into the app. This would hopefully solve most of these issues.\n\n"
                              "Also, if you know of a better way we can do this where both downsides are nonexistent, please contribute to this project on GitHub!",
                        )),
                    // Action Button Size Setting
                    OptionSetting(
                        icon: Icons.aspect_ratio_outlined,
                        settingName: "Choose your action buttons' size:",
                        spacing: 15.0,
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
                    OptionSetting(
                        icon: Icons.grid_view_outlined,
                        settingName: "Choose your library's posts size:",
                        options: [
                          _makeLibrarySmallSubmissionsSettingOption(context,
                              title: 'Big', value: false),
                          _makeLibrarySmallSubmissionsSettingOption(context,
                              title: 'Small', value: true),
                        ]),
                    // Placeholders Options Setting.
                    OptionSetting(
                        icon: Icons.image_outlined,
                        settingName: "Choose your preview placeholders:",
                        spacing: 15.0,
                        options: [
                          _makePlaceholdersOptionsSettingOption(context,
                              value: PlaceholdersOptions.Gradients,
                              subtitle: 'A random gradient per preview from a '
                                  'gradient collection.'),
                          _makePlaceholdersOptionsSettingOption(context,
                              value: PlaceholdersOptions.Abstract,
                              subtitle:
                                  'A random abstract image per preview from an '
                                  'abstract images collection.'),
                          _makePlaceholdersOptionsSettingOption(context,
                              value: PlaceholdersOptions.GoneWildAudioLogo,
                              subtitle:
                                  'The GoneWildAudio subreddit image. Will be '
                                  'the same for all previews.')
                        ]),
                    WarningTagList(tagList: _warningTagList,),
                    LibraryListTags(
                      libraryListTags: _libraryListTags,
                      libraryListTagsCount: _libraryListTagsCount,
                    ),
                  ],
                ),
              ));
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
