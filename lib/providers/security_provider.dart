import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../data/local/hive_service.dart';

/// Lightweight PIN-based lock for app privacy.
class SecurityProvider extends ChangeNotifier {
  static const String _pinHashKey = 'pin_hash';
  static const String _pinSaltKey = 'pin_salt';

  bool _locked = false;
  bool _hasPin = false;
  bool _loading = false;

  bool get locked => _hasPin && _locked;
  bool get hasPin => _hasPin;
  bool get loading => _loading;

  SecurityProvider() {
    _load();
  }

  Future<void> _load() async {
    _loading = true;
    notifyListeners();

    final box = HiveService.settings;
    _hasPin = box.containsKey(_pinHashKey) && box.containsKey(_pinSaltKey);
    _locked = _hasPin;

    _loading = false;
    notifyListeners();
  }

  /// Set or replace PIN; unlocks immediately after setting.
  Future<void> setPin(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);

    final box = HiveService.settings;
    await box.put(_pinHashKey, hash);
    await box.put(_pinSaltKey, salt);

    _hasPin = true;
    _locked = false;
    notifyListeners();
  }

  /// Verify input PIN; unlocks on success.
  Future<bool> verifyPin(String pin) async {
    if (!_hasPin) {
      _locked = false;
      notifyListeners();
      return true;
    }

    final box = HiveService.settings;
    final salt = box.get(_pinSaltKey) as String?;
    final storedHash = box.get(_pinHashKey) as String?;
    if (salt == null || storedHash == null) {
      _hasPin = false;
      _locked = false;
      notifyListeners();
      return true;
    }

    final candidate = _hashPin(pin, salt);
    final ok = constantTimeBytesEquality(
      base64Decode(candidate),
      base64Decode(storedHash),
    );

    if (ok) {
      _locked = false;
      notifyListeners();
    }
    return ok;
  }

  /// Relock the app (e.g., on resume/background).
  void lock() {
    if (_hasPin) {
      _locked = true;
      notifyListeners();
    }
  }

  /// Remove PIN protection.
  Future<void> clearPin() async {
    final box = HiveService.settings;
    await box.delete(_pinHashKey);
    await box.delete(_pinSaltKey);
    _hasPin = false;
    _locked = false;
    notifyListeners();
  }

  String _hashPin(String pin, String salt) {
    // Simple iterative SHA-256 hash with salt; enough for on-device PIN use.
    List<int> data = utf8.encode('$pin|$salt');
    Digest digest = sha256.convert(data);
    for (int i = 0; i < 9999; i++) {
      digest = sha256.convert(<int>[...digest.bytes, ...utf8.encode(salt)]);
    }
    return base64Encode(digest.bytes);
  }

  String _generateSalt({int length = 16}) {
    final rand = Random.secure();
    final bytes = List<int>.generate(length, (_) => rand.nextInt(256));
    return base64Encode(bytes);
  }

  bool constantTimeBytesEquality(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    int diff = 0;
    for (int i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
