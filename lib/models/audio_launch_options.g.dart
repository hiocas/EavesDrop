// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_launch_options.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AudioLaunchOptionsAdapter extends TypeAdapter<AudioLaunchOptions> {
  @override
  final int typeId = 3;

  @override
  AudioLaunchOptions read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AudioLaunchOptions.ChromeCustomTabs;
      case 1:
        return AudioLaunchOptions.WebView;
      case 2:
        return AudioLaunchOptions.EavesDrop;
      default:
        return AudioLaunchOptions.ChromeCustomTabs;
    }
  }

  @override
  void write(BinaryWriter writer, AudioLaunchOptions obj) {
    switch (obj) {
      case AudioLaunchOptions.ChromeCustomTabs:
        writer.writeByte(0);
        break;
      case AudioLaunchOptions.WebView:
        writer.writeByte(1);
        break;
      case AudioLaunchOptions.EavesDrop:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioLaunchOptionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
