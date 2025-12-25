import 'package:hive_flutter/hive_flutter.dart';
import '../models/daily_log.dart';
import '../models/focus_session.dart';
import '../models/daily_reflection.dart';
import '../models/user_preferences.dart';
import '../models/user_profile.dart';
import '../models/srs_deck.dart';
import '../models/srs_card.dart';

/// Service for managing Hive local database
class HiveService {
  static const String dailyLogsBox = 'daily_logs';
  static const String focusSessionsBox = 'focus_sessions';
  static const String reflectionsBox = 'reflections';
  static const String preferencesBox = 'preferences';
  static const String settingsBox = 'settings';
  static const String preferencesKey = 'user_prefs';
  static const String srsDecksBox = 'srs_decks';
  static const String srsCardsBox = 'srs_cards';

  /// Initialize Hive and register all adapters
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(DailyLogAdapter());
    Hive.registerAdapter(FocusSessionAdapter());
    Hive.registerAdapter(FocusCategoryAdapter());
    Hive.registerAdapter(FocusTechniqueAdapter());
    Hive.registerAdapter(DailyReflectionAdapter());
    Hive.registerAdapter(UserPreferencesAdapter());
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(SrsDeckAdapter());
    Hive.registerAdapter(SrsCardAdapter());

    // Open boxes
    await Hive.openBox<DailyLog>(dailyLogsBox);
    await Hive.openBox<FocusSession>(focusSessionsBox);
    await Hive.openBox<DailyReflection>(reflectionsBox);
    await Hive.openBox<UserPreferences>(preferencesBox);
    await Hive.openBox(settingsBox); // Generic box for settings
    await Hive.openBox<SrsDeck>(srsDecksBox);
    await Hive.openBox<SrsCard>(srsCardsBox);
  }

  /// Get daily logs box
  static Box<DailyLog> get dailyLogs => Hive.box<DailyLog>(dailyLogsBox);

  /// Get focus sessions box
  static Box<FocusSession> get focusSessions => Hive.box<FocusSession>(focusSessionsBox);

  /// Get reflections box
  static Box<DailyReflection> get reflections => Hive.box<DailyReflection>(reflectionsBox);

  /// Get preferences box
  static Box<UserPreferences> get preferences => Hive.box<UserPreferences>(preferencesBox);

  /// Get settings box (for generic storage)
  static Box get settings => Hive.box(settingsBox);

  /// SRS decks box
  static Box<SrsDeck> get srsDecks => Hive.box<SrsDeck>(srsDecksBox);

  /// SRS cards box
  static Box<SrsCard> get srsCards => Hive.box<SrsCard>(srsCardsBox);

  /// Get or create user preferences
  static UserPreferences getUserPreferences() {
    final prefs = preferences.get(preferencesKey);
    if (prefs == null) {
      final defaultPrefs = UserPreferences.defaults();
      preferences.put(preferencesKey, defaultPrefs);
      return defaultPrefs;
    }
    return prefs;
  }

  /// Save user preferences
  static Future<void> saveUserPreferences(UserPreferences prefs) async {
    await preferences.put(preferencesKey, prefs);
  }

  /// Close all boxes
  static Future<void> close() async {
    await Hive.close();
  }

  /// Clear all data (for testing/reset)
  static Future<void> clearAll() async {
    await dailyLogs.clear();
    await focusSessions.clear();
    await reflections.clear();
    await preferences.clear();
  }
}
