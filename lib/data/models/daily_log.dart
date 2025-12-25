import 'package:hive/hive.dart';

part 'daily_log.g.dart';

/// Main entity tracking each day's checklist completion.
/// ID format: "YYYY-MM-DD"
@HiveType(typeId: 0)
class DailyLog extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  // ==================== LEARNING SYSTEM ====================
  
  /// DSA problems solved: 0, 1, or 2+
  @HiveField(2)
  int dsaProblems;

  /// AI / Systems study duration in minutes
  @HiveField(3)
  int aiStudyMinutes;

  /// What did I learn today (notes)
  @HiveField(19)
  String learningNotes;

  /// Tech reading completed (Yes/No)
  @HiveField(4)
  bool techReading;

  // ==================== PROJECTS SYSTEM ====================
  
  /// Worked on a project today? (Yes/No)
  @HiveField(5)
  bool workedOnProject;

  /// "What did I learn today?" (1-3 lines)
  @HiveField(6)
  String todayLearning;

  /// Which project did I touch today?
  @HiveField(20)
  String projectName;

  /// Developer notebook for the project
  @HiveField(21)
  String projectNotebook;

  // ==================== ACADEMICS SYSTEM ====================
  
  /// Attended all lectures? (Yes/No)
  @HiveField(7)
  bool attendedLectures;

  /// Notes completed? (Yes/No)
  @HiveField(8)
  bool notesCompleted;

  /// Pending tasks = 0? (Yes/No)
  @HiveField(9)
  bool pendingTasksZero;

  /// Weekend alternative activity (for Sat/Sun when no lectures)
  @HiveField(18)
  String weekendActivity;

  // ==================== HEALTH SYSTEM ====================
  
  /// Slept ≥ 7 hours? (Yes/No)
  @HiveField(10)
  bool sleptWell;

  /// Exercise? (Yes/No)
  @HiveField(11)
  bool exercised;

  /// Hygiene & self-care? (Yes/No)
  @HiveField(12)
  bool hygieneSelfCare;

  // ==================== MIND & DISCIPLINE SYSTEM ====================
  
  /// Meditation / reflection? (Yes/No)
  @HiveField(13)
  bool meditationReflection;

  /// Distraction rule followed? (Yes/No)
  @HiveField(14)
  bool distractionRuleFollowed;

  /// Crazy ideas / unanswered questions
  @HiveField(22)
  String wildIdeas;

  // ==================== METADATA ====================
  
  /// Whether this is a Minimum Viable Day
  @HiveField(15)
  bool isMinimumViableDay;

  @HiveField(16)
  DateTime createdAt;

  @HiveField(17)
  DateTime? updatedAt;

  DailyLog({
    required this.id,
    required this.date,
    this.dsaProblems = 0,
    this.aiStudyMinutes = 0,
    this.learningNotes = '',
    this.techReading = false,
    this.workedOnProject = false,
    this.todayLearning = '',
    this.projectName = '',
    this.projectNotebook = '',
    this.attendedLectures = false,
    this.notesCompleted = false,
    this.pendingTasksZero = false,
    this.weekendActivity = '',
    this.sleptWell = false,
    this.exercised = false,
    this.hygieneSelfCare = false,
    this.meditationReflection = false,
    this.distractionRuleFollowed = false,
    this.wildIdeas = '',
    this.isMinimumViableDay = false,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Factory to create a new log for today
  factory DailyLog.forToday() {
    final now = DateTime.now();
    final id = _formatDate(now);
    return DailyLog(id: id, date: now);
  }

  /// Factory to create a new log for a specific date
  factory DailyLog.forDate(DateTime date) {
    final id = _formatDate(date);
    return DailyLog(id: id, date: date);
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Calculate the show-up score for this day (0.0 - 1.0)
  double get showUpScore {
    int systemsCompleted = 0;
    const totalSystems = 5;

    // Learning: any one of dsaProblems > 0, aiStudyMinutes > 0, techReading
    if (dsaProblems > 0 || aiStudyMinutes > 0 || techReading) {
      systemsCompleted++;
    }

    // Projects: workedOnProject OR any project details provided
    if (workedOnProject || todayLearning.trim().isNotEmpty || projectName.trim().isNotEmpty || projectNotebook.trim().isNotEmpty) {
      systemsCompleted++;
    }

    // Academics: 2+ of 3 items checked
    // Weekends: weekendActivity + 1 other task; Weekdays: standard logic
    int academicsCount = 0;
    if (isWeekend) {
      if (weekendActivity.trim().isNotEmpty) academicsCount++;
    } else {
      if (attendedLectures) academicsCount++;
    }
    if (notesCompleted) academicsCount++;
    if (pendingTasksZero) academicsCount++;
    if (academicsCount >= 2) {
      systemsCompleted++;
    }

    // Health: 2+ of 3 items checked
    int healthCount = 0;
    if (sleptWell) healthCount++;
    if (exercised) healthCount++;
    if (hygieneSelfCare) healthCount++;
    if (healthCount >= 2) {
      systemsCompleted++;
    }

    // Mind: 1+ of 2 items checked
    if (meditationReflection || distractionRuleFollowed) {
      systemsCompleted++;
    }

    return systemsCompleted / totalSystems;
  }

  /// Get the percentage score (0 - 100)
  int get showUpPercentage => (showUpScore * 100).round();

  /// Whether each system is completed
  bool get learningCompleted => dsaProblems > 0 || aiStudyMinutes > 0 || techReading || learningNotes.trim().isNotEmpty;
  bool get projectsCompleted => workedOnProject || todayLearning.trim().isNotEmpty || projectName.trim().isNotEmpty || projectNotebook.trim().isNotEmpty;
  bool get academicsCompleted {
    // Weekends: weekendActivity + 1 other task; Weekdays: standard logic
    int count = 0;
    if (isWeekend) {
      if (weekendActivity.trim().isNotEmpty) count++;
    } else {
      if (attendedLectures) count++;
    }
    if (notesCompleted) count++;
    if (pendingTasksZero) count++;
    return count >= 2;
  }
  
  /// Is today a weekend (Saturday or Sunday)?
  bool get isWeekend => date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  bool get healthCompleted {
    int count = 0;
    if (sleptWell) count++;
    if (exercised) count++;
    if (hygieneSelfCare) count++;
    return count >= 2;
  }
  bool get mindCompleted => meditationReflection || distractionRuleFollowed;

  /// Count of completed systems
  int get completedSystemsCount {
    int count = 0;
    if (learningCompleted) count++;
    if (projectsCompleted) count++;
    if (academicsCompleted) count++;
    if (healthCompleted) count++;
    if (mindCompleted) count++;
    return count;
  }

  /// Copy with modifications
  DailyLog copyWith({
    String? id,
    DateTime? date,
    int? dsaProblems,
    int? aiStudyMinutes,
    String? learningNotes,
    bool? techReading,
    bool? workedOnProject,
    String? todayLearning,
    String? projectName,
    String? projectNotebook,
    bool? attendedLectures,
    bool? notesCompleted,
    bool? pendingTasksZero,
    String? weekendActivity,
    bool? sleptWell,
    bool? exercised,
    bool? hygieneSelfCare,
    bool? meditationReflection,
    bool? distractionRuleFollowed,
    String? wildIdeas,
    bool? isMinimumViableDay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyLog(
      id: id ?? this.id,
      date: date ?? this.date,
      dsaProblems: dsaProblems ?? this.dsaProblems,
      aiStudyMinutes: aiStudyMinutes ?? this.aiStudyMinutes,
      learningNotes: learningNotes ?? this.learningNotes,
      techReading: techReading ?? this.techReading,
      workedOnProject: workedOnProject ?? this.workedOnProject,
      todayLearning: todayLearning ?? this.todayLearning,
      projectName: projectName ?? this.projectName,
      projectNotebook: projectNotebook ?? this.projectNotebook,
      attendedLectures: attendedLectures ?? this.attendedLectures,
      notesCompleted: notesCompleted ?? this.notesCompleted,
      pendingTasksZero: pendingTasksZero ?? this.pendingTasksZero,
      weekendActivity: weekendActivity ?? this.weekendActivity,
      sleptWell: sleptWell ?? this.sleptWell,
      exercised: exercised ?? this.exercised,
      hygieneSelfCare: hygieneSelfCare ?? this.hygieneSelfCare,
      meditationReflection: meditationReflection ?? this.meditationReflection,
      distractionRuleFollowed: distractionRuleFollowed ?? this.distractionRuleFollowed,
      wildIdeas: wildIdeas ?? this.wildIdeas,
      isMinimumViableDay: isMinimumViableDay ?? this.isMinimumViableDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
