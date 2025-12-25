import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'srs_card.g.dart';

@HiveType(typeId: 12)
class SrsCard extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String deckId;

  @HiveField(2)
  String front;

  @HiveField(3)
  String back;

  @HiveField(4)
  double ease;

  @HiveField(5)
  int intervalDays;

  @HiveField(6)
  DateTime due;

  @HiveField(7)
  int lapses;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  SrsCard({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.ease = 2.0,
    this.intervalDays = 1,
    DateTime? due,
    this.lapses = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : due = due ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory SrsCard.create({required String deckId, required String front, required String back}) {
    final now = DateTime.now();
    return SrsCard(
      id: const Uuid().v4(),
      deckId: deckId,
      front: front,
      back: back,
      ease: 2.0,
      intervalDays: 1,
      due: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  SrsCard copyWith({
    String? front,
    String? back,
    double? ease,
    int? intervalDays,
    DateTime? due,
    int? lapses,
  }) {
    return SrsCard(
      id: id,
      deckId: deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      ease: ease ?? this.ease,
      intervalDays: intervalDays ?? this.intervalDays,
      due: due ?? this.due,
      lapses: lapses ?? this.lapses,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
