// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FocusSessionAdapter extends TypeAdapter<FocusSession> {
  @override
  final int typeId = 1;

  @override
  FocusSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FocusSession(
      id: (fields[0] as String?) ?? '',
      dailyLogId: (fields[1] as String?) ?? '',
      category: fields[2] as FocusCategory,
      durationMinutes: fields[3] as int,
      startTime: fields[4] as DateTime,
      endTime: fields[5] as DateTime?,
      completed: fields[6] as bool,
      technique: fields[7] as FocusTechnique,
      notes: (fields[8] as String?) ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, FocusSession obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dailyLogId)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.completed)
      ..writeByte(7)
      ..write(obj.technique)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FocusCategoryAdapter extends TypeAdapter<FocusCategory> {
  @override
  final int typeId = 2;

  @override
  FocusCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FocusCategory.dsa;
      case 1:
        return FocusCategory.projects;
      case 2:
        return FocusCategory.reading;
      case 3:
        return FocusCategory.study;
      default:
        return FocusCategory.dsa;
    }
  }

  @override
  void write(BinaryWriter writer, FocusCategory obj) {
    switch (obj) {
      case FocusCategory.dsa:
        writer.writeByte(0);
        break;
      case FocusCategory.projects:
        writer.writeByte(1);
        break;
      case FocusCategory.reading:
        writer.writeByte(2);
        break;
      case FocusCategory.study:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FocusTechniqueAdapter extends TypeAdapter<FocusTechnique> {
  @override
  final int typeId = 13;

  @override
  FocusTechnique read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FocusTechnique.standard;
      case 1:
        return FocusTechnique.feynman;
      case 2:
        return FocusTechnique.srs_review;
      default:
        return FocusTechnique.standard;
    }
  }

  @override
  void write(BinaryWriter writer, FocusTechnique obj) {
    switch (obj) {
      case FocusTechnique.standard:
        writer.writeByte(0);
        break;
      case FocusTechnique.feynman:
        writer.writeByte(1);
        break;
      case FocusTechnique.srs_review:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusTechniqueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
