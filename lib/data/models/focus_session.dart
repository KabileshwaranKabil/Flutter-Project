import 'package:hive/hive.dart';

part 'focus_session.g.dart';

/// Focus session categories
@HiveType(typeId: 2)
enum FocusCategory {
  @HiveField(0)
  dsa,
  
  @HiveField(1)
  projects,
  
  @HiveField(2)
  reading,
  
  @HiveField(3)
  study,
}

@HiveType(typeId: 13)
enum FocusTechnique {
  @HiveField(0)
  standard,
  @HiveField(1)
  feynman,
  @HiveField(2)
  srs_review,
}

extension FocusTechniqueExtension on FocusTechnique {
  String get displayName {
    switch (this) {
      case FocusTechnique.standard:
        return 'Standard';
      case FocusTechnique.feynman:
        return 'Feynman';
      case FocusTechnique.srs_review:
        return 'SRS review';
    }
  }

  String get hint {
    switch (this) {
      case FocusTechnique.standard:
        return 'Stay on task and avoid context switching.';
      case FocusTechnique.feynman:
        return 'Explain it simply, find gaps, refine with examples.';
      case FocusTechnique.srs_review:
        return 'Use spaced repetition decks during this block.';
    }
  }
}

extension FocusCategoryExtension on FocusCategory {
  String get displayName {
    switch (this) {
      case FocusCategory.dsa:
        return 'DSA';
      case FocusCategory.projects:
        return 'Projects';
      case FocusCategory.reading:
        return 'Reading';
      case FocusCategory.study:
        return 'Study';
    }
  }
  
  String get emoji {
    switch (this) {
      case FocusCategory.dsa:
        return '🧮';
      case FocusCategory.projects:
        return '🔨';
      case FocusCategory.reading:
        return '📚';
      case FocusCategory.study:
        return '📖';
    }
  }
}

/// Focus session - tracks timed work blocks
@HiveType(typeId: 1)
class FocusSession extends HiveObject {
  @HiveField(0)
  String id;

  /// Links to DailyLog ID (YYYY-MM-DD)
  @HiveField(1)
  String dailyLogId;

  @HiveField(2)
  FocusCategory category;

  /// Duration in minutes (10, 15, 20, 25)
  @HiveField(3)
  int durationMinutes;

  @HiveField(4)
  DateTime startTime;

  @HiveField(5)
  DateTime? endTime;

  /// Did user complete the full session?
  @HiveField(6)
  bool completed;

  /// Technique used for this focus session
  @HiveField(7)
  FocusTechnique technique;

  /// Notes (e.g., Feynman explanation, gaps, refinements)
  @HiveField(8)
  String notes;

  FocusSession({
    required this.id,
    required this.dailyLogId,
    required this.category,
    required this.durationMinutes,
    required this.startTime,
    this.endTime,
    this.completed = false,
    this.technique = FocusTechnique.standard,
    this.notes = '',
  });

  /// Factory to create a new session
  factory FocusSession.create({
    required String id,
    required String dailyLogId,
    required FocusCategory category,
    required int durationMinutes,
    FocusTechnique technique = FocusTechnique.standard,
  }) {
    return FocusSession(
      id: id,
      dailyLogId: dailyLogId,
      category: category,
      durationMinutes: durationMinutes,
      technique: technique,
      startTime: DateTime.now(),
    );
  }

  /// Get the actual duration in minutes (if session ended)
  int get actualDurationMinutes {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inMinutes;
  }

  /// Mark session as complete
  FocusSession markComplete() {
    return FocusSession(
      id: id,
      dailyLogId: dailyLogId,
      category: category,
      durationMinutes: durationMinutes,
      startTime: startTime,
      endTime: DateTime.now(),
      completed: true,
      technique: technique,
      notes: notes,
    );
  }

  /// Mark session as abandoned
  FocusSession markAbandoned() {
    return FocusSession(
      id: id,
      dailyLogId: dailyLogId,
      category: category,
      durationMinutes: durationMinutes,
      startTime: startTime,
      endTime: DateTime.now(),
      completed: false,
      technique: technique,
      notes: notes,
    );
  }

  FocusSession copyWith({
    FocusTechnique? technique,
    String? notes,
  }) {
    return FocusSession(
      id: id,
      dailyLogId: dailyLogId,
      category: category,
      durationMinutes: durationMinutes,
      startTime: startTime,
      endTime: endTime,
      completed: completed,
      technique: technique ?? this.technique,
      notes: notes ?? this.notes,
    );
  }
}
