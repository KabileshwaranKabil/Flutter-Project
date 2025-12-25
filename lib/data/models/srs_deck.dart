import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'srs_deck.g.dart';

@HiveType(typeId: 11)
class SrsDeck extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  SrsDeck({
    required this.id,
    required this.name,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory SrsDeck.create(String name) {
    final now = DateTime.now();
    return SrsDeck(
      id: const Uuid().v4(),
      name: name,
      createdAt: now,
      updatedAt: now,
    );
  }

  SrsDeck copyWith({String? name, DateTime? updatedAt}) {
    return SrsDeck(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
