import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../providers/srs_provider.dart';
import '../../data/models/srs_card.dart';
import '../../data/models/srs_deck.dart';

class SrsScreen extends StatefulWidget {
  const SrsScreen({super.key});

  @override
  State<SrsScreen> createState() => _SrsScreenState();
}

class _SrsScreenState extends State<SrsScreen> {
  String? _selectedDeckId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spaced Repetition')),
      body: Consumer<SrsProvider>(
        builder: (context, provider, _) {
          final decks = provider.decks;
          _selectedDeckId ??= decks.isNotEmpty ? decks.first.id : null;
          final due = provider.dueCards
              .where((c) => _selectedDeckId == null || c.deckId == _selectedDeckId)
              .toList();

          return Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingScreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _DeckDropdown(decks: decks, selectedId: _selectedDeckId, onChanged: (id) => setState(() => _selectedDeckId = id))),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showAddDeck(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add deck'),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingL),
                Expanded(
                  child: due.isEmpty
                      ? Center(
                          child: Text('No cards due. Great job!', style: Theme.of(context).textTheme.titleMedium),
                        )
                      : _ReviewCard(card: due.first),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                if (_selectedDeckId != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _showAddCard(context, _selectedDeckId!),
                      icon: const Icon(Icons.note_add),
                      label: const Text('Add card'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddDeck(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New deck'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Deck name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (result == true && controller.text.trim().isNotEmpty) {
      await context.read<SrsProvider>().addDeck(controller.text.trim());
      setState(() {
        _selectedDeckId = context.read<SrsProvider>().decks.last.id;
      });
    }
  }

  Future<void> _showAddCard(BuildContext context, String deckId) async {
    final front = TextEditingController();
    final back = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: front, decoration: const InputDecoration(labelText: 'Front')),
            TextField(controller: back, decoration: const InputDecoration(labelText: 'Back')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (result == true && front.text.trim().isNotEmpty && back.text.trim().isNotEmpty) {
      await context.read<SrsProvider>().addCard(deckId: deckId, front: front.text.trim(), back: back.text.trim());
    }
  }
}

class _DeckDropdown extends StatelessWidget {
  final List<SrsDeck> decks;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const _DeckDropdown({required this.decks, required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedId,
      items: decks
          .map((d) => DropdownMenuItem<String>(
                value: d.id,
                child: Text(d.name),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(labelText: 'Deck'),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final SrsCard card;

  const _ReviewCard({required this.card});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _showBack = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SrsProvider>();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Due: ${widget.card.due.toLocal().toString().split(' ').first}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                _showBack ? widget.card.back : widget.card.front,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          TextButton(
            onPressed: () => setState(() => _showBack = !_showBack),
            child: Text(_showBack ? 'Show front' : 'Show back'),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Wrap(
            spacing: 8,
            children: [
              _gradeButton(context, 'Again', Colors.redAccent, () => provider.gradeCard(widget.card, ReviewGrade.again)),
              _gradeButton(context, 'Hard', Colors.orange, () => provider.gradeCard(widget.card, ReviewGrade.hard)),
              _gradeButton(context, 'Good', Colors.green, () => provider.gradeCard(widget.card, ReviewGrade.good)),
              _gradeButton(context, 'Easy', Colors.blue, () => provider.gradeCard(widget.card, ReviewGrade.easy)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gradeButton(BuildContext context, String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
      onPressed: onTap,
      child: Text(label),
    );
  }
}
