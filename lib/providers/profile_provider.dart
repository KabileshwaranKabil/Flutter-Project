import 'package:flutter/foundation.dart';
import '../data/models/user_profile.dart';
import '../data/local/hive_service.dart';

/// Provider for managing user profile
class ProfileProvider extends ChangeNotifier {
  static const String _profileKey = 'user_profile';
  UserProfile? _profile;

  UserProfile? get profile => _profile;
  bool get hasProfile => _profile != null;

  ProfileProvider() {
    _loadProfile();
  }

  /// Load profile from storage
  Future<void> _loadProfile() async {
    _profile = HiveService.settings.get(_profileKey);
    if (_profile == null) {
      // Create default profile
      _profile = UserProfile.createDefault();
      await _saveProfile();
    }
    notifyListeners();
  }

  /// Save profile to storage
  Future<void> _saveProfile() async {
    if (_profile != null) {
      await HiveService.settings.put(_profileKey, _profile);
    }
  }

  /// Update profile name
  Future<void> updateName(String name) async {
    if (_profile != null && name.isNotEmpty) {
      _profile!.name = name;
      await _saveProfile();
      notifyListeners();
    }
  }

  /// Update profile email
  Future<void> updateEmail(String? email) async {
    if (_profile != null) {
      _profile!.email = email;
      await _saveProfile();
      notifyListeners();
    }
  }

  /// Update avatar URL
  Future<void> updateAvatar(String? avatarUrl) async {
    if (_profile != null) {
      _profile!.avatarUrl = avatarUrl;
      await _saveProfile();
      notifyListeners();
    }
  }

  /// Convenience for local file paths
  Future<void> updateAvatarFilePath(String path) async {
    await updateAvatar(path);
  }

  /// Link Google account data into profile
  Future<void> linkGoogleAccount({required String displayName, required String email, String? photoUrl}) async {
    if (_profile != null) {
      _profile!.name = displayName;
      _profile!.email = email;
      if (photoUrl != null && photoUrl.isNotEmpty) {
        _profile!.avatarUrl = photoUrl;
      }
      await _saveProfile();
      notifyListeners();
    }
  }

  /// Increment total focus minutes
  Future<void> addFocusMinutes(int minutes) async {
    if (_profile != null) {
      _profile!.totalFocusMinutes += minutes;
      await _saveProfile();
      notifyListeners();
    }
  }

  /// Increment total reflections
  Future<void> incrementReflections() async {
    if (_profile != null) {
      _profile!.totalReflections += 1;
      await _saveProfile();
      notifyListeners();
    }
  }

  /// Update streak
  Future<void> updateStreak(int streak) async {
    if (_profile != null) {
      _profile!.currentStreak = streak;
      if (streak > _profile!.longestStreak) {
        _profile!.longestStreak = streak;
      }
      await _saveProfile();
      notifyListeners();
    }
  }
}
