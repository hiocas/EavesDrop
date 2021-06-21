import 'package:hive/hive.dart';

part 'audio_launch_options.g.dart';

@HiveType(typeId: 3)
enum AudioLaunchOptions {
  @HiveField(0)
  ChromeCustomTabs,

  @HiveField(1)
  WebView,
}
