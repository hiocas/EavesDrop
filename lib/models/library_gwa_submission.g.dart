// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_gwa_submission.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LibraryGwaSubmissionAdapter extends TypeAdapter<LibraryGwaSubmission> {
  @override
  final int typeId = 1;

  @override
  LibraryGwaSubmission read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LibraryGwaSubmission()
      ..title = fields[0] as String
      ..fullname = fields[1] as String
      ..thumbnailUrl = fields[2] as String
      ..lists = (fields[3] as List)?.cast<String>();
  }

  @override
  void write(BinaryWriter writer, LibraryGwaSubmission obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.fullname)
      ..writeByte(2)
      ..write(obj.thumbnailUrl)
      ..writeByte(3)
      ..write(obj.lists);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryGwaSubmissionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
