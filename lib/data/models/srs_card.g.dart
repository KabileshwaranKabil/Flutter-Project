// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'srs_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SrsCardAdapter extends TypeAdapter<SrsCard> {
  @override
  final int typeId = 12;

  @override
  SrsCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SrsCard(
      id: (fields[0] as String?) ?? '',
      deckId: (fields[1] as String?) ?? '',
      front: (fields[2] as String?) ?? '',
      back: (fields[3] as String?) ?? '',
      ease: fields[4] as double,
      intervalDays: fields[5] as int,
      due: fields[6] as DateTime?,
      lapses: fields[7] as int,
      createdAt: fields[8] as DateTime?,
      updatedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SrsCard obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.deckId)
      ..writeByte(2)
      ..write(obj.front)
      ..writeByte(3)
      ..write(obj.back)
      ..writeByte(4)
      ..write(obj.ease)
      ..writeByte(5)
      ..write(obj.intervalDays)
      ..writeByte(6)
      ..write(obj.due)
      ..writeByte(7)
      ..write(obj.lapses)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SrsCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
