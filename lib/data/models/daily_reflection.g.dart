// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_reflection.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyReflectionAdapter extends TypeAdapter<DailyReflection> {
  @override
  final int typeId = 3;

  @override
  DailyReflection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyReflection(
      id: (fields[0] as String?) ?? '',
      dailyLogId: (fields[1] as String?) ?? '',
      whatLearned: (fields[2] as String?) ?? '',
      whatWentWell: (fields[3] as String?) ?? '',
      oneImprovement: (fields[4] as String?) ?? '',
      createdAt: fields[5] as DateTime?,
      updatedAt: fields[6] as DateTime?,
      // Older records may have null journal; default to empty string
      journal: (fields[7] as String?) ?? '',
      mood: fields[8] as int?,
      // Ensure tags is never null to avoid cast errors on legacy data
      tags: (fields[9] as List?)?.cast<String>() ?? const <String>[],
      prompt: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyReflection obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dailyLogId)
      ..writeByte(2)
      ..write(obj.whatLearned)
      ..writeByte(3)
      ..write(obj.whatWentWell)
      ..writeByte(4)
      ..write(obj.oneImprovement)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.journal)
      ..writeByte(8)
      ..write(obj.mood)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.prompt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyReflectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
