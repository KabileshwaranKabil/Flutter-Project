import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/daily_log.dart';
import '../models/daily_reflection.dart';
import '../models/focus_session.dart';
import '../models/user_preferences.dart';
import '../models/user_profile.dart';
import '../models/srs_deck.dart';
import '../models/srs_card.dart';
import 'hive_service.dart';

class ExportService {
  /// Export all user data to a JSON file in the documents directory.
  static Future<File> exportAll() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}my_first_app_export.json');

    final payload = {
      'metadata': {
        'exportedAt': DateTime.now().toIso8601String(),
        'schemaVersion': 1,
      },
      'dailyLogs': HiveService.dailyLogs.values.map(_dailyLogToJson).toList(),
      'focusSessions': HiveService.focusSessions.values.map(_focusSessionToJson).toList(),
      'reflections': HiveService.reflections.values.map(_reflectionToJson).toList(),
      'preferences': _prefsToJson(HiveService.getUserPreferences()),
      'profile': _profileToJson(HiveService.settings.get('user_profile') as UserProfile?),
      'srsDecks': HiveService.srsDecks.values.map(_deckToJson).toList(),
      'srsCards': HiveService.srsCards.values.map(_cardToJson).toList(),
      'settings': HiveService.settings.toMap(),
    };

    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
    return file;
  }

  /// Export only profile data to a JSON file.
  static Future<File> exportProfile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}my_first_app_profile.json');

    final profile = HiveService.settings.get('user_profile') as UserProfile?;
    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': _profileToJson(profile),
    };

    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
    return file;
  }

  static Map<String, dynamic> _dailyLogToJson(DailyLog log) {
    return {
      'id': log.id,
      'date': log.date.toIso8601String(),
      'dsaProblems': log.dsaProblems,
      'aiStudyMinutes': log.aiStudyMinutes,
      'learningNotes': log.learningNotes,
      'techReading': log.techReading,
      'workedOnProject': log.workedOnProject,
      'todayLearning': log.todayLearning,
      'projectName': log.projectName,
      'projectNotebook': log.projectNotebook,
      'attendedLectures': log.attendedLectures,
      'notesCompleted': log.notesCompleted,
      'pendingTasksZero': log.pendingTasksZero,
      'weekendActivity': log.weekendActivity,
      'sleptWell': log.sleptWell,
      'exercised': log.exercised,
      'hygieneSelfCare': log.hygieneSelfCare,
      'meditationReflection': log.meditationReflection,
      'distractionRuleFollowed': log.distractionRuleFollowed,
      'wildIdeas': log.wildIdeas,
      'isMinimumViableDay': log.isMinimumViableDay,
      'createdAt': log.createdAt.toIso8601String(),
      'updatedAt': log.updatedAt?.toIso8601String(),
    };
  }

  static Map<String, dynamic> _focusSessionToJson(FocusSession session) {
    return {
      'id': session.id,
      'dailyLogId': session.dailyLogId,
      'category': session.category.name,
      'durationMinutes': session.durationMinutes,
      'startTime': session.startTime.toIso8601String(),
      'endTime': session.endTime?.toIso8601String(),
      'completed': session.completed,
      'technique': session.technique.name,
      'notes': session.notes,
    };
  }

  static Map<String, dynamic> _reflectionToJson(DailyReflection reflection) {
    return {
      'id': reflection.id,
      'dailyLogId': reflection.dailyLogId,
      'whatLearned': reflection.whatLearned,
      'whatWentWell': reflection.whatWentWell,
      'oneImprovement': reflection.oneImprovement,
      'createdAt': reflection.createdAt.toIso8601String(),
      'updatedAt': reflection.updatedAt?.toIso8601String(),
      'journal': reflection.journal,
      'mood': reflection.mood,
      'tags': reflection.tags,
      'prompt': reflection.prompt,
    };
  }

  static Map<String, dynamic> _prefsToJson(UserPreferences prefs) {
    return {
      'darkMode': prefs.darkMode,
      'dailyReminder': prefs.dailyReminder,
      'reminderTimeMinutes': prefs.reminderTimeMinutes,
      'minimumViableDayEnabled': prefs.minimumViableDayEnabled,
      'firstDayOfWeek': prefs.firstDayOfWeek,
    };
  }

  static Map<String, dynamic>? _profileToJson(UserProfile? profile) {
    if (profile == null) return null;
    return {
      'name': profile.name,
      'email': profile.email,
      'avatarUrl': profile.avatarUrl,
      'joinedDate': profile.joinedDate.toIso8601String(),
      'totalFocusMinutes': profile.totalFocusMinutes,
      'totalReflections': profile.totalReflections,
      'currentStreak': profile.currentStreak,
      'longestStreak': profile.longestStreak,
    };
  }

  static Map<String, dynamic> _deckToJson(SrsDeck deck) {
    return {
      'id': deck.id,
      'name': deck.name,
      'createdAt': deck.createdAt.toIso8601String(),
      'updatedAt': deck.updatedAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> _cardToJson(SrsCard card) {
    return {
      'id': card.id,
      'deckId': card.deckId,
      'front': card.front,
      'back': card.back,
      'ease': card.ease,
      'intervalDays': card.intervalDays,
      'due': card.due.toIso8601String(),
      'lapses': card.lapses,
      'createdAt': card.createdAt.toIso8601String(),
      'updatedAt': card.updatedAt.toIso8601String(),
    };
  }

  /// Import data from the latest export file in the documents directory.
  static Future<void> importLatest({bool clearExisting = true}) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}my_first_app_export.json');
    if (!await file.exists()) {
      throw Exception('Export file not found at ${file.path}');
    }

    final content = await file.readAsString();
    final map = jsonDecode(content) as Map<String, dynamic>;
    await _restoreFromMap(map, clearExisting: clearExisting);
  }

  /// Restore data from a decoded JSON payload.
  static Future<void> _restoreFromMap(Map<String, dynamic> data, {bool clearExisting = true}) async {
    if (clearExisting) {
      await HiveService.dailyLogs.clear();
      await HiveService.focusSessions.clear();
      await HiveService.reflections.clear();
      await HiveService.preferences.clear();
      await HiveService.srsDecks.clear();
      await HiveService.srsCards.clear();
      await HiveService.settings.clear();
    }

    for (final item in (data['dailyLogs'] as List? ?? const [])) {
      final log = _dailyLogFromJson(item as Map<String, dynamic>);
      await HiveService.dailyLogs.put(log.id, log);
    }

    for (final item in (data['focusSessions'] as List? ?? const [])) {
      final session = _focusSessionFromJson(item as Map<String, dynamic>);
      await HiveService.focusSessions.put(session.id, session);
    }

    for (final item in (data['reflections'] as List? ?? const [])) {
      final reflection = _reflectionFromJson(item as Map<String, dynamic>);
      await HiveService.reflections.put(reflection.id, reflection);
    }

    for (final item in (data['srsDecks'] as List? ?? const [])) {
      final deck = _deckFromJson(item as Map<String, dynamic>);
      await HiveService.srsDecks.put(deck.id, deck);
    }

    for (final item in (data['srsCards'] as List? ?? const [])) {
      final card = _cardFromJson(item as Map<String, dynamic>);
      await HiveService.srsCards.put(card.id, card);
    }

    final prefsMap = data['preferences'] as Map?;
    if (prefsMap != null) {
      final prefs = _prefsFromJson(prefsMap.cast<String, dynamic>());
      await HiveService.saveUserPreferences(prefs);
    }

    final profileMap = data['profile'] as Map?;
    if (profileMap != null) {
      final profile = _profileFromJson(profileMap.cast<String, dynamic>());
      await HiveService.settings.put('user_profile', profile);
    }

    final settings = data['settings'] as Map?;
    if (settings != null) {
      await HiveService.settings.putAll(settings);
    }
  }

  static DailyLog _dailyLogFromJson(Map<String, dynamic> json) {
    DateTime _parse(String? value) => value == null ? DateTime.now() : DateTime.tryParse(value) ?? DateTime.now();
    return DailyLog(
      id: json['id'] as String,
      date: _parse(json['date'] as String?),
      dsaProblems: (json['dsaProblems'] as num?)?.toInt() ?? 0,
      aiStudyMinutes: (json['aiStudyMinutes'] as num?)?.toInt() ?? 0,
      learningNotes: json['learningNotes'] as String? ?? '',
      techReading: json['techReading'] as bool? ?? false,
      workedOnProject: json['workedOnProject'] as bool? ?? false,
      todayLearning: json['todayLearning'] as String? ?? '',
      projectName: json['projectName'] as String? ?? '',
      projectNotebook: json['projectNotebook'] as String? ?? '',
      attendedLectures: json['attendedLectures'] as bool? ?? false,
      notesCompleted: json['notesCompleted'] as bool? ?? false,
      pendingTasksZero: json['pendingTasksZero'] as bool? ?? false,
      weekendActivity: json['weekendActivity'] as String? ?? '',
      sleptWell: json['sleptWell'] as bool? ?? false,
      exercised: json['exercised'] as bool? ?? false,
      hygieneSelfCare: json['hygieneSelfCare'] as bool? ?? false,
      meditationReflection: json['meditationReflection'] as bool? ?? false,
      distractionRuleFollowed: json['distractionRuleFollowed'] as bool? ?? false,
      wildIdeas: json['wildIdeas'] as String? ?? '',
      isMinimumViableDay: json['isMinimumViableDay'] as bool? ?? false,
      createdAt: _parse(json['createdAt'] as String?),
      updatedAt: json['updatedAt'] != null ? _parse(json['updatedAt'] as String?) : null,
    );
  }

  static FocusSession _focusSessionFromJson(Map<String, dynamic> json) {
    DateTime _parse(String? value) => value == null ? DateTime.now() : DateTime.tryParse(value) ?? DateTime.now();
    FocusTechnique technique = FocusTechnique.standard;
    final techName = json['technique'] as String?;
    if (techName != null) {
      technique = FocusTechnique.values.firstWhere(
        (t) => t.name == techName,
        orElse: () => FocusTechnique.standard,
      );
    }

    FocusCategory category = FocusCategory.dsa;
    final catName = json['category'] as String?;
    if (catName != null) {
      category = FocusCategory.values.firstWhere(
        (c) => c.name == catName,
        orElse: () => FocusCategory.dsa,
      );
    }

    return FocusSession(
      id: json['id'] as String,
      dailyLogId: json['dailyLogId'] as String? ?? '',
      category: category,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 25,
      startTime: _parse(json['startTime'] as String?),
      endTime: json['endTime'] != null ? _parse(json['endTime'] as String?) : null,
      completed: json['completed'] as bool? ?? false,
      technique: technique,
      notes: json['notes'] as String? ?? '',
    );
  }

  static DailyReflection _reflectionFromJson(Map<String, dynamic> json) {
    DateTime _parse(String? value) => value == null ? DateTime.now() : DateTime.tryParse(value) ?? DateTime.now();
    return DailyReflection(
      id: json['id'] as String,
      dailyLogId: json['dailyLogId'] as String? ?? '',
      whatLearned: json['whatLearned'] as String? ?? '',
      whatWentWell: json['whatWentWell'] as String? ?? '',
      oneImprovement: json['oneImprovement'] as String? ?? '',
      createdAt: _parse(json['createdAt'] as String?),
      updatedAt: json['updatedAt'] != null ? _parse(json['updatedAt'] as String?) : null,
      journal: json['journal'] as String? ?? '',
      mood: (json['mood'] as num?)?.toInt(),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? <String>[],
      prompt: json['prompt'] as String?,
    );
  }

  static UserPreferences _prefsFromJson(Map<String, dynamic> json) {
    return UserPreferences(
      darkMode: json['darkMode'] as bool? ?? true,
      dailyReminder: json['dailyReminder'] as bool? ?? false,
      reminderTimeMinutes: (json['reminderTimeMinutes'] as num?)?.toInt(),
      minimumViableDayEnabled: json['minimumViableDayEnabled'] as bool? ?? true,
      firstDayOfWeek: (json['firstDayOfWeek'] as num?)?.toInt() ?? 1,
    );
  }

  static UserProfile _profileFromJson(Map<String, dynamic> json) {
    DateTime _parse(String? value) => value == null ? DateTime.now() : DateTime.tryParse(value) ?? DateTime.now();
    return UserProfile(
      name: json['name'] as String? ?? 'Student',
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      joinedDate: _parse(json['joinedDate'] as String?),
      totalFocusMinutes: (json['totalFocusMinutes'] as num?)?.toInt() ?? 0,
      totalReflections: (json['totalReflections'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
    );
  }

  static SrsDeck _deckFromJson(Map<String, dynamic> json) {
    DateTime _parse(String? value) => value == null ? DateTime.now() : DateTime.tryParse(value) ?? DateTime.now();
    return SrsDeck(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Deck',
      createdAt: _parse(json['createdAt'] as String?),
      updatedAt: _parse(json['updatedAt'] as String?),
    );
  }

  static SrsCard _cardFromJson(Map<String, dynamic> json) {
    DateTime _parse(String? value) => value == null ? DateTime.now() : DateTime.tryParse(value) ?? DateTime.now();
    return SrsCard(
      id: json['id'] as String,
      deckId: json['deckId'] as String? ?? '',
      front: json['front'] as String? ?? '',
      back: json['back'] as String? ?? '',
      ease: (json['ease'] as num?)?.toDouble() ?? 2.0,
      intervalDays: (json['intervalDays'] as num?)?.toInt() ?? 1,
      due: _parse(json['due'] as String?),
      lapses: (json['lapses'] as num?)?.toInt() ?? 0,
      createdAt: _parse(json['createdAt'] as String?),
      updatedAt: _parse(json['updatedAt'] as String?),
    );
  }
}
