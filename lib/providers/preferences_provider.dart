import 'package:flutter/foundation.dart';
import '../data/models/user_preferences.dart';
import '../data/local/hive_service.dart';

/// Provider for managing user preferences
class PreferencesProvider extends ChangeNotifier {
  UserPreferences _preferences = UserPreferences.defaults();
  bool _isLoading = false;

  UserPreferences get preferences {
    if (!_initialized && !_isLoading) {
      init();
    }
    return _preferences;
  }
  
  bool get isLoading => _isLoading;
  bool get darkMode => _preferences.darkMode;
  bool get dailyReminder => _preferences.dailyReminder;
  bool get mvdEnabled => _preferences.minimumViableDayEnabled;
  
  bool _initialized = false;

  /// Initialize and load preferences
  Future<void> init() async {
    if (_initialized) return;
    
    _isLoading = true;
    _initialized = true;
    notifyListeners();

    _preferences = HiveService.getUserPreferences();

    _isLoading = false;
    notifyListeners();
  }

  /// Update preferences
  Future<void> updatePreferences(UserPreferences prefs) async {
    _preferences = prefs;
    await HiveService.saveUserPreferences(prefs);
    notifyListeners();
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    await updatePreferences(_preferences.copyWith(darkMode: !_preferences.darkMode));
  }

  /// Toggle daily reminder
  Future<void> toggleDailyReminder() async {
    await updatePreferences(_preferences.copyWith(dailyReminder: !_preferences.dailyReminder));
  }

  /// Set reminder time
  Future<void> setReminderTime(int hours, int minutes) async {
    final prefs = _preferences.copyWith(reminderTimeMinutes: hours * 60 + minutes);
    await updatePreferences(prefs);
  }

  /// Toggle MVD mode availability
  Future<void> toggleMvdEnabled() async {
    await updatePreferences(_preferences.copyWith(
      minimumViableDayEnabled: !_preferences.minimumViableDayEnabled,
    ));
  }

  /// Set first day of week
  Future<void> setFirstDayOfWeek(int day) async {
    await updatePreferences(_preferences.copyWith(firstDayOfWeek: day));
  }
}
