// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 2;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      credentials: fields[0] as String,
      audioLaunchOptions: fields[1] as AudioLaunchOptions,
      firstTime: fields[2] as bool,
      miniButtons: fields[3] as bool,
      librarySmallSubmissions: fields[4] as bool,
      placeholdersOptions: fields[5] as PlaceholdersOptions,
      warningTags: (fields[7] as List)?.cast<String>(),
      libraryListsTags: (fields[8] as List)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.credentials)
      ..writeByte(1)
      ..write(obj.audioLaunchOptions)
      ..writeByte(2)
      ..write(obj.firstTime)
      ..writeByte(3)
      ..write(obj.miniButtons)
      ..writeByte(4)
      ..write(obj.librarySmallSubmissions)
      ..writeByte(5)
      ..write(obj.placeholdersOptions)
      ..writeByte(7)
      ..write(obj.warningTags)
      ..writeByte(8)
      ..write(obj.libraryListsTags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
