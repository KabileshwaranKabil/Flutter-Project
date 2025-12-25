import 'package:flutter/foundation.dart';

import '../data/local/hive_service.dart';
import '../data/models/srs_card.dart';
import '../data/models/srs_deck.dart';

enum ReviewGrade { again, hard, good, easy }

class SrsProvider extends ChangeNotifier {
  bool loading = false;
  List<SrsDeck> decks = [];
  List<SrsCard> dueCards = [];

  SrsProvider() {
    _load();
  }

  Future<void> _load() async {
    loading = true;
    notifyListeners();
    decks = HiveService.srsDecks.values.toList();
    _refreshDue();
    loading = false;
    notifyListeners();
  }

  void _refreshDue() {
    final now = DateTime.now();
    dueCards = HiveService.srsCards.values
        .where((c) => !c.isInBox || c.due.isBefore(now) || _sameDay(c.due, now))
        .toList()
      ..sort((a, b) => a.due.compareTo(b.due));
  }

  Future<void> addDeck(String name) async {
    final deck = SrsDeck.create(name);
    await HiveService.srsDecks.put(deck.id, deck);
    decks = HiveService.srsDecks.values.toList();
    notifyListeners();
  }

  Future<void> addCard({required String deckId, required String front, required String back}) async {
    final card = SrsCard.create(deckId: deckId, front: front, back: back);
    await HiveService.srsCards.put(card.id, card);
    _refreshDue();
    notifyListeners();
  }

  Future<void> gradeCard(SrsCard card, ReviewGrade grade) async {
    final updated = _applyGrade(card, grade);
    await HiveService.srsCards.put(updated.id, updated);
    _refreshDue();
    notifyListeners();
  }

  SrsCard _applyGrade(SrsCard card, ReviewGrade grade) {
    final now = DateTime.now();
    double ease = card.ease;
    int interval = card.intervalDays;
    int lapses = card.lapses;

    switch (grade) {
      case ReviewGrade.again:
        ease = (ease - 0.2).clamp(1.3, 2.5);
        interval = 1;
        lapses += 1;
        break;
      case ReviewGrade.hard:
        ease = (ease - 0.05).clamp(1.3, 2.5);
        interval = (interval * 0.9).round().clamp(1, 3650);
        break;
      case ReviewGrade.good:
        interval = (interval * ease).round().clamp(1, 3650);
        break;
      case ReviewGrade.easy:
        ease = (ease + 0.1).clamp(1.3, 2.5);
        interval = (interval * (ease + 0.15)).round().clamp(1, 3650);
        break;
    }

    return card.copyWith(
      ease: ease,
      intervalDays: interval,
      due: now.add(Duration(days: interval)),
      lapses: lapses,
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
