import 'package:gwa_app/models/audio_launch_options.dart';
import 'package:gwa_app/models/placeholders_options.dart';
import 'package:gwa_app/screens/first_time_screen/first_time_screen.dart';
import 'package:hive/hive.dart';
import 'package:gwa_app/models/library_gwa_submission.dart';
import 'package:gwa_app/models/app_settings.dart';
import 'package:flutter/material.dart';

class HiveBoxes {
  static List<String> listTags = ['Favorites', 'Planned'];

  static void initHive() {
    Hive.registerAdapter(LibraryGwaSubmissionAdapter());

    Hive.registerAdapter(AppSettingsAdapter());

    Hive.registerAdapter(AudioLaunchOptionsAdapter());

    Hive.registerAdapter(PlaceholdersOptionsAdapter());
  }

  static Future<void> checkFirstTime(BuildContext context) async {
    final settingsBox = await HiveBoxes.openAppSettingsBox();
    if (settingsBox.isEmpty) {
      await HiveBoxes.addAppSettings();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FirstTimeScreen(),
        ),
      );
    } else {
      if (settingsBox.getAt(0).firstTime) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FirstTimeScreen(),
          ),
        );
      }
    }
    settingsBox.close();
  }

  static Box<LibraryGwaSubmission> getLibraryBox() =>
      Hive.box<LibraryGwaSubmission>('library');

  static Future<Box<LibraryGwaSubmission>> openLibraryBox() async {
    return Hive.openBox<LibraryGwaSubmission>('library');
  }

  static Box<AppSettings> getAppSettingsBox() =>
      Hive.box<AppSettings>('settings');

  static Future<Box<AppSettings>> openAppSettingsBox() async {
    return Hive.openBox<AppSettings>('settings');
  }

  /// Returns the user's library list (consisting of [LibraryGwaSubmission]
  /// entries) and then closes the library box.
  /// If there are no app settings, returns an empty list.
  static Future<List<LibraryGwaSubmission>>
      getLibraryGwaSubmissionList() async {
    final libraryBox = await HiveBoxes.openLibraryBox();
    if (libraryBox.isNotEmpty) {
      final List<LibraryGwaSubmission> libraryList =
          libraryBox.values.toList().cast<LibraryGwaSubmission>();
      return libraryList;
    }
    return [];
  }

  /// Returns the user's [AppSettings] and then closes their box.
  /// If there are no app settings, returns null.
  static Future<AppSettings> getAppSettings() async {
    final settingsBox = await HiveBoxes.openAppSettingsBox();
    if (settingsBox.isNotEmpty) {
      final AppSettings appSettings = settingsBox.getAt(0);
      settingsBox.close();
      return appSettings;
    }
    return null;
  }

  static Future<LibraryGwaSubmission> addLibrarySubmission(String title,
      String fullname, String thumbnailUrl, List<String> lists) async {
    final box = await HiveBoxes.openLibraryBox();
    final LibraryGwaSubmission libraryGwaSubmission = LibraryGwaSubmission()
      ..title = title
      ..fullname = fullname
      ..thumbnailUrl = thumbnailUrl
      ..lists = lists;
    box.add(libraryGwaSubmission);
    return libraryGwaSubmission;
  }

  static editLibrarySubmission(LibraryGwaSubmission submission,
      [String title,
      String fullname,
      String thumbnailUrl,
      List<String> lists]) {
    final box = HiveBoxes.getLibraryBox();
    if (!box.isOpen) {
      HiveBoxes.openLibraryBox();
    }
    if (title != null && title.isNotEmpty) submission.title = title;
    if (fullname != null && fullname.isNotEmpty) submission.fullname = fullname;
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
      submission.thumbnailUrl = thumbnailUrl;
    if (lists != null) submission.lists = lists;
    submission.save();
  }

  static Future<AppSettings> addAppSettings(
      {String credentials,
      AudioLaunchOptions audioLaunchOptions =
          AudioLaunchOptions.ChromeCustomTabs,
      bool miniButtons = false,
      bool librarySmallSubmissions = false,
      PlaceholdersOptions placeholdersOptions =
          PlaceholdersOptions.Gradients}) async {
    final AppSettings settings = AppSettings(
        credentials: credentials,
        audioLaunchOptions: audioLaunchOptions,
        firstTime: false,
        miniButtons: miniButtons,
        librarySmallSubmissions: librarySmallSubmissions,
        placeholdersOptions: placeholdersOptions);
    final box = await HiveBoxes.openAppSettingsBox();
    await box.add(settings);
    return Future.value(settings);
  }

  static editAppSettings({
    String credentials,
    AudioLaunchOptions audioLaunchOptions,
    bool firstTime,
    bool miniButtons,
    bool librarySmallSubmissions,
    PlaceholdersOptions placeholdersOptions,
  }) async {
    final box = await HiveBoxes.openAppSettingsBox();
    if (box.isNotEmpty) {
      final AppSettings settings = box.getAt(0);
      if (credentials != null) {
        settings.credentials = credentials;
      }
      if (audioLaunchOptions != null) {
        settings.audioLaunchOptions = audioLaunchOptions;
      }
      if (firstTime != null) {
        settings.firstTime = firstTime;
      }
      if (miniButtons != null) {
        settings.miniButtons = miniButtons;
      }
      if (librarySmallSubmissions != null) {
        settings.librarySmallSubmissions = librarySmallSubmissions;
      }
      if (placeholdersOptions != null) {
        settings.placeholdersOptions = placeholdersOptions;
      }
      await settings.save();
    }
  }

  static clearLibrary() async {
    final box = await openLibraryBox();
    await box.clear();
    box.close();
  }

  static clearAppSettings() async {
    final box = await openAppSettingsBox();
    await box.clear();
    box.close();
  }
}
