import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/daily_log.dart';
import '../data/models/daily_reflection.dart';
import '../data/local/hive_service.dart';
import '../services/firebase_service.dart';

/// Service to sync local Hive data with Firestore
class SyncService {
  static final SyncService _instance = SyncService._internal();
  
  final FirebaseService _firebaseService = FirebaseService();
  bool _isSyncing = false;

  factory SyncService() {
    return _instance;
  }

  SyncService._internal();

  bool get isSyncing => _isSyncing;

  /// Sync all local data to Firestore
  Future<void> syncAllData() async {
    if (_isSyncing || !_firebaseService.isAuthenticated) return;
    
    _isSyncing = true;
    try {
      await Future.wait([
        _syncDailyLogs(),
        _syncDailyReflections(),
        _syncFocusSessions(),
      ]);
      print('✓ All data synced successfully');
    } catch (e) {
      print('✗ Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync daily logs from Hive to Firestore
  Future<void> _syncDailyLogs() async {
    try {
      final logsBox = HiveService.dailyLogs;
      
      for (final log in logsBox.values) {
        final data = {
          'id': log.id,
          'date': log.date.toIso8601String(),
          'focusSessionCount': log.focusSessionCount,
          'totalFocusMinutes': log.totalFocusMinutes,
          'moods': log.moods,
          'notes': log.notes,
          'createdAt': log.createdAt.toIso8601String(),
          'updatedAt': log.updatedAt.toIso8601String(),
        };
        
        await _firebaseService.setDailyLog(log.id, data);
      }
      print('✓ Daily logs synced');
    } catch (e) {
      print('✗ Error syncing daily logs: $e');
      rethrow;
    }
  }

  /// Sync daily reflections from Hive to Firestore
  Future<void> _syncDailyReflections() async {
    try {
      final reflectionsBox = HiveService.reflections;
      
      for (final reflection in reflectionsBox.values) {
        final data = {
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
        
        await _firebaseService.setDailyReflection(reflection.id, data);
      }
      print('✓ Daily reflections synced');
    } catch (e) {
      print('✗ Error syncing daily reflections: $e');
      rethrow;
    }
  }

  /// Sync focus sessions from Hive to Firestore
  Future<void> _syncFocusSessions() async {
    try {
      final sessionsBox = HiveService.focusSessions;
      
      for (final session in sessionsBox.values) {
        final data = {
          'id': session.id,
          'dailyLogId': session.dailyLogId,
          'category': session.category.name,
          'technique': session.technique.name,
          'startTime': session.startTime.toIso8601String(),
          'endTime': session.endTime?.toIso8601String(),
          'durationSeconds': session.durationSeconds,
          'notes': session.notes,
          'isCompleted': session.isCompleted,
        };
        
        await _firebaseService.setFocusSession(session.id, data);
      }
      print('✓ Focus sessions synced');
    } catch (e) {
      print('✗ Error syncing focus sessions: $e');
      rethrow;
    }
  }

  /// Fetch data from Firestore and update local Hive storage
  Future<void> fetchAndUpdateLocalData() async {
    try {
      await Future.wait([
        _fetchDailyLogs(),
        _fetchDailyReflections(),
        _fetchFocusSessions(),
      ]);
      print('✓ Local data updated from Firestore');
    } catch (e) {
      print('✗ Error fetching data: $e');
      rethrow;
    }
  }

  /// Fetch daily logs from Firestore
  Future<void> _fetchDailyLogs() async {
    try {
      final logsData = await _firebaseService.getDailyLogs();
      final logsBox = HiveService.dailyLogs;
      
      for (final data in logsData) {
        final log = DailyLog(
          id: data['id'] as String,
          date: DateTime.parse(data['date'] as String),
          focusSessionCount: data['focusSessionCount'] as int? ?? 0,
          totalFocusMinutes: data['totalFocusMinutes'] as int? ?? 0,
          moods: List<int>.from(data['moods'] as List? ?? []),
          notes: data['notes'] as String? ?? '',
          createdAt: DateTime.parse(data['createdAt'] as String),
          updatedAt: DateTime.parse(data['updatedAt'] as String),
        );
        
        await logsBox.put(log.id, log);
      }
    } catch (e) {
      print('✗ Error fetching daily logs: $e');
    }
  }

  /// Fetch daily reflections from Firestore
  Future<void> _fetchDailyReflections() async {
    try {
      final reflectionsData = await _firebaseService.getDailyReflections();
      final reflectionsBox = HiveService.reflections;
      
      for (final data in reflectionsData) {
        final reflection = DailyReflection(
          id: data['id'] as String,
          dailyLogId: data['dailyLogId'] as String,
          whatLearned: data['whatLearned'] as String? ?? '',
          whatWentWell: data['whatWentWell'] as String? ?? '',
          oneImprovement: data['oneImprovement'] as String? ?? '',
          createdAt: DateTime.parse(data['createdAt'] as String),
          updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt'] as String) : null,
          journal: data['journal'] as String? ?? '',
          mood: data['mood'] as int?,
          tags: List<String>.from(data['tags'] as List? ?? []),
          prompt: data['prompt'] as String?,
        );
        
        await reflectionsBox.put(reflection.id, reflection);
      }
    } catch (e) {
      print('✗ Error fetching daily reflections: $e');
    }
  }

  /// Fetch focus sessions from Firestore
  Future<void> _fetchFocusSessions() async {
    // Implement similar to other fetches
    // This is a placeholder; implement based on your FocusSession model
  }
}
