import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/local/hive_service.dart';

class LeetCodeProvider extends ChangeNotifier {
  static const _cacheKey = 'leetcode_stats';
  static const _endpoint = 'https://leetcode.com/graphql';

  String username;
  bool loading = false;
  String? error;

  int solvedEasy = 0;
  int solvedMedium = 0;
  int solvedHard = 0;
  int get solvedTotal => solvedEasy + solvedMedium + solvedHard;
  DateTime? lastFetched;

  LeetCodeProvider({this.username = 'Kabileshwaran1896'}) {
    _loadCache();
  }

  Future<void> _loadCache() async {
    final map = HiveService.settings.get(_cacheKey) as Map?;
    if (map == null) return;
    username = map['username'] as String? ?? username;
    solvedEasy = map['easy'] as int? ?? 0;
    solvedMedium = map['medium'] as int? ?? 0;
    solvedHard = map['hard'] as int? ?? 0;
    final lf = map['lastFetched'] as String?;
    if (lf != null) lastFetched = DateTime.tryParse(lf);
    notifyListeners();
  }

  Future<void> setUsername(String value) async {
    username = value.trim();
    await _persist();
    notifyListeners();
  }

  Future<void> fetch() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final query = r'''
      query userProblemsSolved($username: String!) {
        matchedUser(username: $username) {
          submitStats {
            acSubmissionNum { difficulty count }
          }
        }
      }
      ''';
      final body = jsonEncode({
        'operationName': 'userProblemsSolved',
        'variables': {'username': username},
        'query': query,
      });
      final res = await http
          .post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: body,
      )
          .timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final stats = ((data['data'] as Map?)?['matchedUser'] as Map?)?['submitStats'] as Map?;
      final list = (stats?['acSubmissionNum'] as List?) ?? [];
      int easy = 0, medium = 0, hard = 0;
      for (final item in list) {
        final diff = item['difficulty'] as String?;
        final countVal = item['count'];
        final count = (countVal is num) ? countVal.toInt() : 0;
        switch (diff) {
          case 'Easy':
            easy = count;
            break;
          case 'Medium':
            medium = count;
            break;
          case 'Hard':
            hard = count;
            break;
        }
      }
      solvedEasy = easy;
      solvedMedium = medium;
      solvedHard = hard;
      lastFetched = DateTime.now();
      await _persist();
    } on TimeoutException {
      error = 'Request timed out. Please try again.';
    } catch (e) {
      error = 'Failed to fetch: ${e.toString()}';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    await HiveService.settings.put(_cacheKey, {
      'username': username,
      'easy': solvedEasy,
      'medium': solvedMedium,
      'hard': solvedHard,
      'lastFetched': lastFetched?.toIso8601String(),
    });
  }
}
