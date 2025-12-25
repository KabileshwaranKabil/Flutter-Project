import 'package:flutter/foundation.dart';
import '../data/models/daily_reflection.dart';
import '../data/local/hive_service.dart';

/// Provider for managing daily reflections
class ReflectionProvider extends ChangeNotifier {
  DailyReflection? _todayReflection;
  bool _isLoading = false;

  DailyReflection? get todayReflection {
    if (_todayReflection == null && !_isLoading && !_initialized) {
      init();
    }
    return _todayReflection;
  }
  
  bool get isLoading => _isLoading;
  bool get hasReflection => _todayReflection?.hasContent ?? false;
  bool get isComplete => _todayReflection?.isComplete ?? false;
  
  bool _initialized = false;

  /// Get today's date as ID format
  String get _todayId {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Initialize and load today's reflection
  Future<void> init() async {
    if (_initialized) return;
    
    _isLoading = true;
    _initialized = true;
    notifyListeners();

    await loadTodayReflection();

    _isLoading = false;
    notifyListeners();
  }

  /// Load or create today's reflection
  Future<void> loadTodayReflection() async {
    final box = HiveService.reflections;
    _todayReflection = box.get(_todayId);

    if (_todayReflection == null) {
      _todayReflection = DailyReflection.forToday();
      await box.put(_todayId, _todayReflection!);
    }

    notifyListeners();
  }

  /// Get reflection for a specific date
  DailyReflection? getReflectionForDate(DateTime date) {
    final id = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return HiveService.reflections.get(id);
  }

  /// Update today's reflection
  Future<void> updateReflection({
    String? whatLearned,
    String? whatWentWell,
    String? oneImprovement,
    String? journal,
    int? mood,
    List<String>? tags,
    String? prompt,
  }) async {
    if (_todayReflection == null) {
      _todayReflection = DailyReflection.forToday();
    }

    _todayReflection = _todayReflection!.copyWith(
      whatLearned: whatLearned ?? _todayReflection!.whatLearned,
      whatWentWell: whatWentWell ?? _todayReflection!.whatWentWell,
      oneImprovement: oneImprovement ?? _todayReflection!.oneImprovement,
      journal: journal ?? _todayReflection!.journal,
      mood: mood ?? _todayReflection!.mood,
      tags: tags ?? _todayReflection!.tags,
      prompt: prompt ?? _todayReflection!.prompt,
      updatedAt: DateTime.now(),
    );

    await HiveService.reflections.put(_todayId, _todayReflection!);
    notifyListeners();
  }

  /// Save the complete reflection
  Future<void> saveReflection(DailyReflection reflection) async {
    _todayReflection = reflection.copyWith(updatedAt: DateTime.now());
    await HiveService.reflections.put(_todayId, _todayReflection!);
    notifyListeners();
  }

  /// Get reflections completion rate for last 7 days
  double getWeeklyReflectionRate() {
    final box = HiveService.reflections;
    final now = DateTime.now();
    int completedDays = 0;

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final id = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final reflection = box.get(id);
      if (reflection != null && reflection.isComplete) {
        completedDays++;
      }
    }

    return completedDays / 7;
  }
}
