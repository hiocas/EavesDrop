// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'placeholders_options.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaceholdersOptionsAdapter extends TypeAdapter<PlaceholdersOptions> {
  @override
  final int typeId = 4;

  @override
  PlaceholdersOptions read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PlaceholdersOptions.Abstract;
      case 1:
        return PlaceholdersOptions.Gradients;
      case 2:
        return PlaceholdersOptions.GoneWildAudioLogo;
      default:
        return PlaceholdersOptions.Abstract;
    }
  }

  @override
  void write(BinaryWriter writer, PlaceholdersOptions obj) {
    switch (obj) {
      case PlaceholdersOptions.Abstract:
        writer.writeByte(0);
        break;
      case PlaceholdersOptions.Gradients:
        writer.writeByte(1);
        break;
      case PlaceholdersOptions.GoneWildAudioLogo:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceholdersOptionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
