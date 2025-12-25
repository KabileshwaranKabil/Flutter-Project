import 'package:hive/hive.dart';

part 'daily_reflection.g.dart';

/// Daily reflection - end of day mini journal
@HiveType(typeId: 3)
class DailyReflection extends HiveObject {
  /// ID format: "YYYY-MM-DD"
  @HiveField(0)
  String id;

  /// Links to DailyLog ID (same as id)
  @HiveField(1)
  String dailyLogId;

  /// "What did I learn today?" (max 3 lines)
  @HiveField(2)
  String whatLearned;

  /// "What went well?" (max 3 lines)
  @HiveField(3)
  String whatWentWell;

  /// "One thing to improve tomorrow" (max 3 lines)
  @HiveField(4)
  String oneImprovement;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? updatedAt;

  /// Rich journal entry for the day
  @HiveField(7)
  String journal;

  /// Mood rating 1-5
  @HiveField(8)
  int? mood;

  /// Tags/categories for the entry
  @HiveField(9)
  List<String> tags;

  /// Prompt text used (if any)
  @HiveField(10)
  String? prompt;

  DailyReflection({
    required this.id,
    required this.dailyLogId,
    this.whatLearned = '',
    this.whatWentWell = '',
    this.oneImprovement = '',
    DateTime? createdAt,
    this.updatedAt,
    this.journal = '',
    this.mood,
    List<String>? tags,
    this.prompt,
  })  : tags = tags ?? <String>[],
        createdAt = createdAt ?? DateTime.now();

  /// Factory to create a new reflection for today
  factory DailyReflection.forToday() {
    final now = DateTime.now();
    final id = _formatDate(now);
    return DailyReflection(id: id, dailyLogId: id);
  }

  /// Factory to create a new reflection for a specific date
  factory DailyReflection.forDate(DateTime date) {
    final id = _formatDate(date);
    return DailyReflection(id: id, dailyLogId: id);
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Check if reflection has any content
  bool get hasContent {
    return journal.trim().isNotEmpty ||
      whatLearned.trim().isNotEmpty ||
      whatWentWell.trim().isNotEmpty ||
      oneImprovement.trim().isNotEmpty;
  }

  /// Check if reflection is complete (all fields filled)
  bool get isComplete {
    return journal.trim().isNotEmpty &&
      whatLearned.trim().isNotEmpty &&
      whatWentWell.trim().isNotEmpty &&
      oneImprovement.trim().isNotEmpty;
  }

  /// Copy with modifications
  DailyReflection copyWith({
    String? id,
    String? dailyLogId,
    String? whatLearned,
    String? whatWentWell,
    String? oneImprovement,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? journal,
    int? mood,
    List<String>? tags,
    String? prompt,
  }) {
    return DailyReflection(
      id: id ?? this.id,
      dailyLogId: dailyLogId ?? this.dailyLogId,
      whatLearned: whatLearned ?? this.whatLearned,
      whatWentWell: whatWentWell ?? this.whatWentWell,
      oneImprovement: oneImprovement ?? this.oneImprovement,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      journal: journal ?? this.journal,
      mood: mood ?? this.mood,
      tags: tags ?? List<String>.from(this.tags),
      prompt: prompt ?? this.prompt,
    );
  }
}
