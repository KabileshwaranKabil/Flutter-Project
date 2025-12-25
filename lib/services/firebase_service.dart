import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to handle all Firestore operations and syncing
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  /// Get current user ID
  String? get userId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Initialize offline persistence
  Future<void> initializeOfflinePersistence() async {
    try {
      // Enable offline persistence for Firestore
      await _firestore.disableNetwork();
      await _firestore.enableNetwork();
    } catch (e) {
      print('Error initializing offline persistence: $e');
    }
  }

  /// Sign in with Google (Firebase Auth)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider = FirebaseAuthProvider();
      return await _auth.signInWithProvider(GoogleAuthProvider);
    } catch (e) {
      print('Google sign-in error: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // ==================== DailyLog Operations ====================

  /// Create or update a daily log
  Future<void> setDailyLog(String logId, Map<String, dynamic> data) async {
    if (userId == null) throw Exception('User not authenticated');
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_logs')
          .doc(logId)
          .set(
            {
              ...data,
              'synced_at': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
    } catch (e) {
      print('Error setting daily log: $e');
      rethrow;
    }
  }

  /// Get a single daily log
  Future<Map<String, dynamic>?> getDailyLog(String logId) async {
    if (userId == null) throw Exception('User not authenticated');
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_logs')
          .doc(logId)
          .get();
      return doc.data();
    } catch (e) {
      print('Error getting daily log: $e');
      return null;
    }
  }

  /// Get all daily logs
  Future<List<Map<String, dynamic>>> getDailyLogs() async {
    if (userId == null) throw Exception('User not authenticated');
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_logs')
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting daily logs: $e');
      return [];
    }
  }

  /// Stream daily logs (real-time updates)
  Stream<List<Map<String, dynamic>>> streamDailyLogs() {
    if (userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_logs')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Delete a daily log
  Future<void> deleteDailyLog(String logId) async {
    if (userId == null) throw Exception('User not authenticated');
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_logs')
          .doc(logId)
          .delete();
    } catch (e) {
      print('Error deleting daily log: $e');
      rethrow;
    }
  }

  // ==================== Daily Reflection Operations ====================

  /// Create or update a daily reflection
  Future<void> setDailyReflection(String reflectionId, Map<String, dynamic> data) async {
    if (userId == null) throw Exception('User not authenticated');
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('reflections')
          .doc(reflectionId)
          .set(
            {
              ...data,
              'synced_at': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
    } catch (e) {
      print('Error setting daily reflection: $e');
      rethrow;
    }
  }

  /// Get a single daily reflection
  Future<Map<String, dynamic>?> getDailyReflection(String reflectionId) async {
    if (userId == null) throw Exception('User not authenticated');
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('reflections')
          .doc(reflectionId)
          .get();
      return doc.data();
    } catch (e) {
      print('Error getting daily reflection: $e');
      return null;
    }
  }

  /// Get all daily reflections
  Future<List<Map<String, dynamic>>> getDailyReflections() async {
    if (userId == null) throw Exception('User not authenticated');
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('reflections')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting daily reflections: $e');
      return [];
    }
  }

  /// Stream daily reflections (real-time updates)
  Stream<List<Map<String, dynamic>>> streamDailyReflections() {
    if (userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('reflections')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Delete a daily reflection
  Future<void> deleteDailyReflection(String reflectionId) async {
    if (userId == null) throw Exception('User not authenticated');
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('reflections')
          .doc(reflectionId)
          .delete();
    } catch (e) {
      print('Error deleting daily reflection: $e');
      rethrow;
    }
  }

  // ==================== Focus Session Operations ====================

  /// Create or update a focus session
  Future<void> setFocusSession(String sessionId, Map<String, dynamic> data) async {
    if (userId == null) throw Exception('User not authenticated');
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('focus_sessions')
          .doc(sessionId)
          .set(
            {
              ...data,
              'synced_at': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
    } catch (e) {
      print('Error setting focus session: $e');
      rethrow;
    }
  }

  /// Get all focus sessions
  Future<List<Map<String, dynamic>>> getFocusSessions() async {
    if (userId == null) throw Exception('User not authenticated');
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('focus_sessions')
          .orderBy('startTime', descending: true)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting focus sessions: $e');
      return [];
    }
  }

  /// Delete a focus session
  Future<void> deleteFocusSession(String sessionId) async {
    if (userId == null) throw Exception('User not authenticated');
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('focus_sessions')
          .doc(sessionId)
          .delete();
    } catch (e) {
      print('Error deleting focus session: $e');
      rethrow;
    }
  }

  // ==================== Batch Operations ====================

  /// Batch sync local data to Firestore
  Future<void> batchSyncData(List<BatchOperation> operations) async {
    if (userId == null) throw Exception('User not authenticated');
    try {
      final batch = _firestore.batch();
      
      for (final op in operations) {
        final ref = _firestore
            .collection('users')
            .doc(userId)
            .collection(op.collection)
            .doc(op.docId);

        if (op.isDelete) {
          batch.delete(ref);
        } else {
          batch.set(
            ref,
            {
              ...op.data,
              'synced_at': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        }
      }

      await batch.commit();
    } catch (e) {
      print('Error in batch sync: $e');
      rethrow;
    }
  }
}

/// Represents a batch operation for syncing
class BatchOperation {
  final String collection;
  final String docId;
  final Map<String, dynamic> data;
  final bool isDelete;

  BatchOperation({
    required this.collection,
    required this.docId,
    required this.data,
    this.isDelete = false,
  });
}
