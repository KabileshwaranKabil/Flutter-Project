// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyLogAdapter extends TypeAdapter<DailyLog> {
  @override
  final int typeId = 0;

  @override
  DailyLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyLog(
      id: (fields[0] as String?) ?? '',
      date: (fields[1] as DateTime?) ?? DateTime.now(),
      dsaProblems: (fields[2] as int?) ?? 0,
      aiStudyMinutes: (fields[3] as int?) ?? 0,
      learningNotes: (fields[19] as String?) ?? '',
      techReading: (fields[4] as bool?) ?? false,
      workedOnProject: (fields[5] as bool?) ?? false,
      todayLearning: (fields[6] as String?) ?? '',
      projectName: (fields[20] as String?) ?? '',
      projectNotebook: (fields[21] as String?) ?? '',
      attendedLectures: (fields[7] as bool?) ?? false,
      notesCompleted: (fields[8] as bool?) ?? false,
      pendingTasksZero: (fields[9] as bool?) ?? false,
      weekendActivity: (fields[18] as String?) ?? '',
      sleptWell: (fields[10] as bool?) ?? false,
      exercised: (fields[11] as bool?) ?? false,
      hygieneSelfCare: (fields[12] as bool?) ?? false,
      meditationReflection: (fields[13] as bool?) ?? false,
      distractionRuleFollowed: (fields[14] as bool?) ?? false,
      wildIdeas: (fields[22] as String?) ?? '',
      isMinimumViableDay: (fields[15] as bool?) ?? false,
      createdAt: fields[16] as DateTime?,
      updatedAt: fields[17] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyLog obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.dsaProblems)
      ..writeByte(3)
      ..write(obj.aiStudyMinutes)
      ..writeByte(19)
      ..write(obj.learningNotes)
      ..writeByte(4)
      ..write(obj.techReading)
      ..writeByte(5)
      ..write(obj.workedOnProject)
      ..writeByte(6)
      ..write(obj.todayLearning)
      ..writeByte(20)
      ..write(obj.projectName)
      ..writeByte(21)
      ..write(obj.projectNotebook)
      ..writeByte(7)
      ..write(obj.attendedLectures)
      ..writeByte(8)
      ..write(obj.notesCompleted)
      ..writeByte(9)
      ..write(obj.pendingTasksZero)
      ..writeByte(18)
      ..write(obj.weekendActivity)
      ..writeByte(10)
      ..write(obj.sleptWell)
      ..writeByte(11)
      ..write(obj.exercised)
      ..writeByte(12)
      ..write(obj.hygieneSelfCare)
      ..writeByte(13)
      ..write(obj.meditationReflection)
      ..writeByte(14)
      ..write(obj.distractionRuleFollowed)
      ..writeByte(22)
      ..write(obj.wildIdeas)
      ..writeByte(15)
      ..write(obj.isMinimumViableDay)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
