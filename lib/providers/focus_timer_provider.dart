import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/focus_session.dart';
import '../data/local/hive_service.dart';

/// Provider for managing focus timer sessions
class FocusTimerProvider extends ChangeNotifier {
  Timer? _timer;
  FocusSession? _currentSession;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  FocusCategory _selectedCategory = FocusCategory.dsa;
  int _selectedDuration = 25; // minutes
  FocusTechnique _selectedTechnique = FocusTechnique.standard;
  String _notes = '';

  // Available durations
  static const List<int> availableDurations = [10, 15, 20, 25, 30, 45];

  FocusSession? get currentSession => _currentSession;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  FocusCategory get selectedCategory => _selectedCategory;
  int get selectedDuration => _selectedDuration;
  FocusTechnique get selectedTechnique => _selectedTechnique;
  String get notes => _notes;

  /// Formatted time display (MM:SS)
  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Progress value (0.0 to 1.0)
  double get progress {
    if (_currentSession == null) return 0.0;
    final totalSeconds = _currentSession!.durationMinutes * 60;
    return 1.0 - (_remainingSeconds / totalSeconds);
  }

  /// Get today's date as ID format
  String get _todayId {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Set selected category
  void setCategory(FocusCategory category) {
    if (!_isRunning) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  void setTechnique(FocusTechnique technique) {
    if (!_isRunning) {
      _selectedTechnique = technique;
      notifyListeners();
    }
  }

  void setNotes(String value) {
    _notes = value;
    notifyListeners();
  }

  void clearNotes() {
    _notes = '';
    notifyListeners();
  }

  /// Set selected duration
  void setDuration(int minutes) {
    if (!_isRunning && availableDurations.contains(minutes)) {
      _selectedDuration = minutes;
      _remainingSeconds = minutes * 60;
      notifyListeners();
    }
  }

  /// Start a new focus session
  Future<void> startSession() async {
    if (_isRunning) return;

    final uuid = const Uuid();
    _currentSession = FocusSession.create(
      id: uuid.v4(),
      dailyLogId: _todayId,
      category: _selectedCategory,
      durationMinutes: _selectedDuration,
      technique: _selectedTechnique,
    );

    _remainingSeconds = _selectedDuration * 60;
    _isRunning = true;

    // Save session
    await HiveService.focusSessions.put(_currentSession!.id, _currentSession!);

    // Start countdown
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    notifyListeners();
  }

  void _tick(Timer timer) {
    if (_remainingSeconds > 0) {
      _remainingSeconds--;
      notifyListeners();
    } else {
      _completeSession();
    }
  }

  /// Complete the session successfully
  Future<void> _completeSession() async {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;

    if (_currentSession != null) {
      final completedSession = _currentSession!.markComplete().copyWith(notes: _notes);
      await HiveService.focusSessions.put(completedSession.id, completedSession);
      _currentSession = completedSession;
    }

    notifyListeners();
  }

  /// Stop/abandon the current session
  Future<void> stopSession() async {
    if (!_isRunning) return;

    _timer?.cancel();
    _timer = null;
    _isRunning = false;

    if (_currentSession != null) {
      final abandonedSession = _currentSession!.markAbandoned().copyWith(notes: _notes);
      await HiveService.focusSessions.put(abandonedSession.id, abandonedSession);
    }

    _currentSession = null;
    _remainingSeconds = _selectedDuration * 60;
    _notes = '';
    notifyListeners();
  }

  /// Reset after completed session
  void reset() {
    _currentSession = null;
    _remainingSeconds = _selectedDuration * 60;
    _notes = '';
    notifyListeners();
  }

  /// Get today's focus sessions
  List<FocusSession> getTodaySessions() {
    final box = HiveService.focusSessions;
    return box.values
        .where((session) => session.dailyLogId == _todayId)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  /// Get total focus minutes for today
  int getTodayTotalMinutes() {
    final sessions = getTodaySessions();
    int total = 0;
    for (final session in sessions) {
      if (session.completed) {
        total += session.durationMinutes;
      }
    }
    return total;
  }

  /// Get session count by category for today
  Map<FocusCategory, int> getTodaySessionsByCategory() {
    final sessions = getTodaySessions();
    final result = <FocusCategory, int>{};
    
    for (final category in FocusCategory.values) {
      result[category] = sessions
          .where((s) => s.category == category && s.completed)
          .length;
    }
    
    return result;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
