import 'package:flutter/foundation.dart';
import '../data/models/daily_log.dart';
import '../data/local/hive_service.dart';

/// Provider for managing daily logs
class DailyLogProvider extends ChangeNotifier {
  DailyLog? _todayLog;
  List<DailyLog> _recentLogs = [];
  bool _isLoading = false;
  bool _initialized = false;

  DailyLogProvider() {
    init();
  }

  DailyLog? get todayLog => _todayLog;
  List<DailyLog> get recentLogs => _recentLogs;
  bool get isLoading => _isLoading;
  
  /// Get today's date as ID format
  String get _todayId {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Initialize and load today's log
  Future<void> init() async {
    if (_initialized) return;
    
    _isLoading = true;
    _initialized = true;

    await loadTodayLog();
    await loadRecentLogs();

    _isLoading = false;
    notifyListeners();
    notifyListeners();
  }

  /// Load or create today's log
  Future<void> loadTodayLog() async {
    final box = HiveService.dailyLogs;
    _todayLog = box.get(_todayId);

    if (_todayLog == null) {
      _todayLog = DailyLog.forToday();
      await box.put(_todayId, _todayLog!);
    }

    notifyListeners();
  }

  /// Load recent logs (last 7 days)
  Future<void> loadRecentLogs({int days = 7}) async {
    final box = HiveService.dailyLogs;
    final now = DateTime.now();
    _recentLogs = [];

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final id = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final log = box.get(id);
      if (log != null) {
        _recentLogs.add(log);
      }
    }

    notifyListeners();
  }

  /// Get log for a specific date
  DailyLog? getLogForDate(DateTime date) {
    final id = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return HiveService.dailyLogs.get(id);
  }

  /// Update today's log
  Future<void> updateTodayLog(DailyLog updatedLog) async {
    _todayLog = updatedLog.copyWith(updatedAt: DateTime.now());
    await HiveService.dailyLogs.put(_todayId, _todayLog!);
    notifyListeners();
  }

  /// Quick update methods for individual fields
  Future<void> updateDsaProblems(int value) async {
    if (_todayLog == null) return;
    await updateTodayLog(_todayLog!.copyWith(dsaProblems: value));
  }

  Future<void> updateAiStudyMinutes(int value) async {
    if (_todayLog == null) return;
    await updateTodayLog(_todayLog!.copyWith(aiStudyMinutes: value));
  }

  Future<void> toggleTechReading() async {
    if (_todayLog == null) return;
    await updateTodayLog(_todayLog!.copyWith(techReading: !_todayLog!.techReading));
  }

  Future<void> toggleWorkedOnProject() async {
    if (_todayLog == null) return;
    await updateTodayLog(_todayLog!.copyWith(workedOnProject: !_todayLog!.workedOnProject));
  }

  Future<void> updateTodayLearning(String value) async {
    if (_todayLog == null) return;
    await updateTodayLog(_todayLog!.copyWith(todayLearning: value));
  }

  Future<void> updateLearningNotes(String value) async {
    if (_todayLog == null) return;
    await updateTodayLog(_todayLog!.copyWith(learningNotes: value));
  }

  Future<void> updateProjectName(String value) async {
    if (_todayLog == null) return;
    await updateTodayLog(_todayLog!.copyWith(projectName: value));
  }

  Future<void> updateProjectNotebook(String value) async {
    if (_todayLog == null) return;
    await updateTodayLog(_todayLog!.copyWith(projectNotebook: value));
  }

  Future<void> toggleAttendedLectures() async {
    if (_todayLog == null) return;
    await updateTodayLog(_todayLog!.copyWith(attendedLectures: !_todayLog!.attendedLectures));
  }

  Future<void> toggleNotesCompleted() async {
    if (_todayLog == null) return;
    await updateTodayLog(_todayLog!.copyWith(notesCompleted: !_todayLog!.notesCompleted));
  }

  Future<void> togglePendingTasksZero() async {
    if (_todayLog == null) return;
    await updateTodayLog(_todayLog!.copyWith(pendingTasksZero: !_todayLog!.pendingTasksZero));
  }

  Future<void> updateWeekendActivity(String value) async {
    if (_todayLog == null) return;
    await updateTodayLog(_todayLog!.copyWith(weekendActivity: value));
  }

  Future<void> updateWildIdeas(String value) async {
    if (_todayLog == null) return;
    await updateTodayLog(_todayLog!.copyWith(wildIdeas: value));
  }

  Future<void> toggleSleptWell() async {
    if (_todayLog == null) return;
    await updateTodayLog(_todayLog!.copyWith(sleptWell: !_todayLog!.sleptWell));
  }

  Future<void> toggleExercised() async {
    if (_todayLog == null) return;
    await updateTodayLog(_todayLog!.copyWith(exercised: !_todayLog!.exercised));
  }

  Future<void> toggleHygieneSelfCare() async {
    if (_todayLog == null) return;
    await updateTodayLog(_todayLog!.copyWith(hygieneSelfCare: !_todayLog!.hygieneSelfCare));
  }

  Future<void> toggleMeditationReflection() async {
    if (_todayLog == null) return;
    await updateTodayLog(_todayLog!.copyWith(meditationReflection: !_todayLog!.meditationReflection));
  }

  Future<void> toggleDistractionRuleFollowed() async {
    if (_todayLog == null) return;
    await updateTodayLog(_todayLog!.copyWith(distractionRuleFollowed: !_todayLog!.distractionRuleFollowed));
  }

  Future<void> toggleMinimumViableDay() async {
    if (_todayLog == null) return;
    await updateTodayLog(_todayLog!.copyWith(isMinimumViableDay: !_todayLog!.isMinimumViableDay));
  }

  /// Get weekly consistency score (last 7 days)
  double getWeeklyConsistency() {
    if (_recentLogs.isEmpty) return 0.0;
    
    int daysWithGoodScore = 0;
    for (final log in _recentLogs) {
      if (log.showUpScore >= 0.5) {
        daysWithGoodScore++;
      }
    }
    
    return daysWithGoodScore / 7;
  }

  /// Get system-level consistency for the week
  Map<String, double> getSystemConsistencies() {
    if (_recentLogs.isEmpty) {
      return {
        'learning': 0.0,
        'projects': 0.0,
        'academics': 0.0,
        'health': 0.0,
        'mind': 0.0,
      };
    }

    int learningDays = 0;
    int projectsDays = 0;
    int academicsDays = 0;
    int healthDays = 0;
    int mindDays = 0;

    for (final log in _recentLogs) {
      if (log.learningCompleted) learningDays++;
      if (log.projectsCompleted) projectsDays++;
      if (log.academicsCompleted) academicsDays++;
      if (log.healthCompleted) healthDays++;
      if (log.mindCompleted) mindDays++;
    }

    final totalDays = _recentLogs.length;
    return {
      'learning': learningDays / totalDays,
      'projects': projectsDays / totalDays,
      'academics': academicsDays / totalDays,
      'health': healthDays / totalDays,
      'mind': mindDays / totalDays,
    };
  }

  /// Get the weakest system this week
  String? getWeakestSystem() {
    final consistencies = getSystemConsistencies();
    if (consistencies.isEmpty) return null;

    String? weakest;
    double lowestScore = 1.0;

    consistencies.forEach((system, score) {
      if (score < lowestScore) {
        lowestScore = score;
        weakest = system;
      }
    });

    return weakest;
  }

  /// Get current discipline streak (consecutive days with any log)
  int getDisciplineStreak() {
    final box = HiveService.dailyLogs;
    int streak = 0;
    DateTime current = DateTime.now();

    while (true) {
      final id = '${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}';
      final log = box.get(id);
      
      if (log == null) {
        // If not today and no log, break streak
        if (streak > 0) break;
        // If today and no log yet, continue checking
        if (_isSameDay(current, DateTime.now())) {
          current = current.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
      
      streak++;
      current = current.subtract(const Duration(days: 1));
    }

    return streak;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
