import 'package:hive/hive.dart';

part 'user_preferences.g.dart';

/// User preferences for the app
@HiveType(typeId: 4)
class UserPreferences extends HiveObject {
  /// Whether dark mode is enabled (always true for now)
  @HiveField(0)
  bool darkMode;

  /// Whether daily reminder notification is enabled
  @HiveField(1)
  bool dailyReminder;

  /// Time for daily reminder (hour * 60 + minute)
  @HiveField(2)
  int? reminderTimeMinutes;

  /// Whether Minimum Viable Day mode is quickly accessible
  @HiveField(3)
  bool minimumViableDayEnabled;

  /// First day of the week (0 = Sunday, 1 = Monday)
  @HiveField(4)
  int firstDayOfWeek;

  UserPreferences({
    this.darkMode = true,
    this.dailyReminder = false,
    this.reminderTimeMinutes,
    this.minimumViableDayEnabled = true,
    this.firstDayOfWeek = 1, // Monday
  });

  /// Factory for default preferences
  factory UserPreferences.defaults() {
    return UserPreferences(
      darkMode: true,
      dailyReminder: false,
      reminderTimeMinutes: 21 * 60, // 9:00 PM
      minimumViableDayEnabled: true,
      firstDayOfWeek: 1,
    );
  }

  /// Get reminder time as hours and minutes
  (int hours, int minutes)? get reminderTime {
    if (reminderTimeMinutes == null) return null;
    return (reminderTimeMinutes! ~/ 60, reminderTimeMinutes! % 60);
  }

  /// Set reminder time from hours and minutes
  void setReminderTime(int hours, int minutes) {
    reminderTimeMinutes = hours * 60 + minutes;
  }

  /// Copy with modifications
  UserPreferences copyWith({
    bool? darkMode,
    bool? dailyReminder,
    int? reminderTimeMinutes,
    bool? minimumViableDayEnabled,
    int? firstDayOfWeek,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      reminderTimeMinutes: reminderTimeMinutes ?? this.reminderTimeMinutes,
      minimumViableDayEnabled: minimumViableDayEnabled ?? this.minimumViableDayEnabled,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
    );
  }
}
