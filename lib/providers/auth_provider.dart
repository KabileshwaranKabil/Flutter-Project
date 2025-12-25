import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

/// Handles Firebase authentication and exposes user data.
class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get signedIn => _user != null;
  String? get userId => _user?.uid;

  AuthProvider() {
    // Listen for auth state changes
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signIn() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // Sign in with Google
      final GoogleAuthProvider = google.GoogleAuthProvider();
      final result = await _firebaseAuth.signInWithProvider(GoogleAuthProvider);
      _user = result.user;
      
      // Initialize offline persistence after sign-in
      await _firebaseService.initializeOfflinePersistence();
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Authentication failed';
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _loading = true;
    notifyListeners();
    try {
      await _firebaseAuth.signOut();
      _user = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
