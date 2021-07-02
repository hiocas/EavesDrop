import 'package:hive/hive.dart';

part 'placeholders_options.g.dart';

@HiveType(typeId: 4)
enum PlaceholdersOptions {
  @HiveField(0)
  Abstract,

  @HiveField(1)
  Gradients,

  @HiveField(2)
  GoneWildAudioLogo,
}
