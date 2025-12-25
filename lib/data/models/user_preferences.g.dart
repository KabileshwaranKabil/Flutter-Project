// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesAdapter extends TypeAdapter<UserPreferences> {
  @override
  final int typeId = 4;

  @override
  UserPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferences(
      darkMode: fields[0] as bool,
      dailyReminder: fields[1] as bool,
      reminderTimeMinutes: fields[2] as int?,
      minimumViableDayEnabled: fields[3] as bool,
      firstDayOfWeek: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferences obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.darkMode)
      ..writeByte(1)
      ..write(obj.dailyReminder)
      ..writeByte(2)
      ..write(obj.reminderTimeMinutes)
      ..writeByte(3)
      ..write(obj.minimumViableDayEnabled)
      ..writeByte(4)
      ..write(obj.firstDayOfWeek);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
