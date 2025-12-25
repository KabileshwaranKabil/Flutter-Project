import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/local/hive_service.dart';

class GithubProvider extends ChangeNotifier {
  static const _cacheKey = 'github_stats';

  String username;
  bool loading = false;
  String? error;

  int totalContributions = 0;
  int currentStreak = 0;
  int longestStreak = 0;
  DateTime? lastFetched;
  Map<String, int> contributionsByDate = {};

  GithubProvider({this.username = 'KabileshwaranKabil'}) {
    _loadCache();
  }

  Future<void> _loadCache() async {
    final map = HiveService.settings.get(_cacheKey) as Map?;
    if (map == null) return;
    username = map['username'] as String? ?? username;
    totalContributions = map['total'] as int? ?? 0;
    currentStreak = map['currentStreak'] as int? ?? 0;
    longestStreak = map['longestStreak'] as int? ?? 0;
    final lf = map['lastFetched'] as String?;
    if (lf != null) lastFetched = DateTime.tryParse(lf);
    final contrib = map['contributions'] as Map?;
    if (contrib != null) {
      contributionsByDate = contrib.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
    }
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
      final uri = Uri.parse('https://github-contributions-api.jogruber.de/v4/$username');
      final res = await http.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final contributions = <String, int>{};
      if (body['contributions'] is List) {
        for (final c in (body['contributions'] as List)) {
          final date = c['date'] as String?;
          final countVal = c['count'];
          final count = (countVal is num) ? countVal.toInt() : 0;
          if (date != null) contributions[date] = count;
        }
      }
      contributionsByDate = contributions;
      final totalVal = body['total'];
      totalContributions = (totalVal is num) ? totalVal.toInt() : _sum(contributions.values);
      final curStreakVal = body['currentStreak'];
      currentStreak = (curStreakVal is num) ? curStreakVal.toInt() : 0;
      final longStreakVal = body['longestStreak'];
      longestStreak = (longStreakVal is num) ? longStreakVal.toInt() : 0;
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

  int _sum(Iterable<int> v) => v.fold(0, (a, b) => a + b);

  Future<void> _persist() async {
    await HiveService.settings.put(_cacheKey, {
      'username': username,
      'total': totalContributions,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastFetched': lastFetched?.toIso8601String(),
      'contributions': contributionsByDate,
    });
  }
}
