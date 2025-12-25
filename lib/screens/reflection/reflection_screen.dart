import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';
import '../../providers/reflection_provider.dart';
import '../../widgets/common_widgets.dart';

const List<String> _prompts = [
  'What energized me today?',
  'What drained my focus?',
  'What did I learn that surprised me?',
  'Where did I get stuck and how did I resolve it?',
  'One small win I’m proud of is...',
];

const List<String> _tagOptions = [
  'work',
  'study',
  'health',
  'relationships',
  'mindset',
  'gratitude',
  'ideas',
];

/// Daily reflection screen with 3 questions
class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({super.key});

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  late TextEditingController _whatLearnedController;
  late TextEditingController _whatWentWellController;
  late TextEditingController _oneImprovementController;
  late TextEditingController _journalController;
  bool _hasChanges = false;
  int _mood = 3;
  String? _selectedPrompt;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _whatLearnedController = TextEditingController();
    _whatWentWellController = TextEditingController();
    _oneImprovementController = TextEditingController();
    _journalController = TextEditingController();

    // Load initial values after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReflection();
    });
  }

  void _loadReflection() {
    final provider = context.read<ReflectionProvider>();
    final reflection = provider.todayReflection;
    if (reflection != null) {
      _whatLearnedController.text = reflection.whatLearned;
      _whatWentWellController.text = reflection.whatWentWell;
      _oneImprovementController.text = reflection.oneImprovement;
      _journalController.text = reflection.journal;
      _mood = reflection.mood ?? 3;
      _selectedPrompt = reflection.prompt;
      _tags = List<String>.from(reflection.tags);
    }
  }

  @override
  void dispose() {
    _whatLearnedController.dispose();
    _whatWentWellController.dispose();
    _oneImprovementController.dispose();
    _journalController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<ReflectionProvider>();
    await provider.updateReflection(
      whatLearned: _whatLearnedController.text,
      whatWentWell: _whatWentWellController.text,
      oneImprovement: _oneImprovementController.text,
      journal: _journalController.text,
      mood: _mood,
      tags: _tags,
      prompt: _selectedPrompt,
    );
    setState(() => _hasChanges = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reflection saved'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReflectionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingScreen),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppStrings.reflectionTitle,
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            if (provider.isComplete)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 24,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.reflectionHint,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),

                // Questions
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingScreen),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Mood selector
                      _MoodSlider(
                        value: _mood,
                        onChanged: (v) => setState(() {
                          _mood = v;
                          _hasChanges = true;
                        }),
                      ),

                      const SizedBox(height: AppDimensions.spacingL),

                      // Prompt picker
                      _PromptPicker(
                        prompts: _prompts,
                        selected: _selectedPrompt,
                        onSelect: (p) => setState(() {
                          _selectedPrompt = p;
                          _hasChanges = true;
                          if (_journalController.text.isEmpty && p != null) {
                            _journalController.text = '$p\n';
                          }
                        }),
                      ),

                      const SizedBox(height: AppDimensions.spacingL),

                      // Journal area
                      _JournalField(
                        controller: _journalController,
                        onChanged: (_) => setState(() => _hasChanges = true),
                      ),

                      const SizedBox(height: AppDimensions.spacingL),

                      // Tags
                      _TagSelector(
                        options: _tagOptions,
                        selected: _tags,
                        onToggle: (tag) => setState(() {
                          if (_tags.contains(tag)) {
                            _tags = List<String>.from(_tags)..remove(tag);
                          } else {
                            _tags = [..._tags, tag];
                          }
                          _hasChanges = true;
                        }),
                      ),

                      const SizedBox(height: AppDimensions.spacingXL),

                      // Question 1
                      _ReflectionQuestion(
                        number: 1,
                        question: AppStrings.reflectionQ1,
                        controller: _whatLearnedController,
                        onChanged: (value) => setState(() => _hasChanges = true),
                      ),

                      const SizedBox(height: AppDimensions.spacingL),

                      // Question 2
                      _ReflectionQuestion(
                        number: 2,
                        question: AppStrings.reflectionQ2,
                        controller: _whatWentWellController,
                        onChanged: (value) => setState(() => _hasChanges = true),
                      ),

                      const SizedBox(height: AppDimensions.spacingL),

                      // Question 3
                      _ReflectionQuestion(
                        number: 3,
                        question: AppStrings.reflectionQ3,
                        controller: _oneImprovementController,
                        onChanged: (value) => setState(() => _hasChanges = true),
                      ),

                      const SizedBox(height: AppDimensions.spacingXL),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _hasChanges ? _save : null,
                          child: const Text(AppStrings.save),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingXL),

                      // Completion rate
                      CalmCard(
                        title: 'WEEKLY REFLECTION RATE',
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'You\'ve reflected ${(provider.getWeeklyReflectionRate() * 7).round()} out of 7 days this week',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            ScorePill(
                              percentage: (provider.getWeeklyReflectionRate() * 100).round(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingXXL),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MoodSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _MoodSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mood', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Low'),
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: _label(value),
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
            Text(_label(value)),
          ],
        ),
      ],
    );
  }

  static String _label(int v) {
    switch (v) {
      case 1:
        return '😔';
      case 2:
        return '🙁';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }
}

class _PromptPicker extends StatelessWidget {
  final List<String> prompts;
  final String? selected;
  final ValueChanged<String?> onSelect;

  const _PromptPicker({required this.prompts, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Prompt (optional)', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selected,
          decoration: const InputDecoration(hintText: 'Choose a prompt'),
          items: prompts
              .map((p) => DropdownMenuItem<String>(value: p, child: Text(p)))
              .toList(),
          onChanged: onSelect,
          isExpanded: true,
        ),
      ],
    );
  }
}

class _JournalField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const _JournalField({required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Journal', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 8,
          maxLength: 2000,
          onChanged: onChanged,
          decoration: const InputDecoration(hintText: 'Write freely about your day...'),
        ),
      ],
    );
  }
}

class _TagSelector extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const _TagSelector({required this.options, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((tag) {
            final isSelected = selected.contains(tag);
            return ChoiceChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (_) => onToggle(tag),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Single reflection question component
class _ReflectionQuestion extends StatelessWidget {
  final int number;
  final String question;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const _ReflectionQuestion({
    required this.number,
    required this.question,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Expanded(
              child: Text(
                question,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingS),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: 3,
          maxLength: 200,
          decoration: const InputDecoration(
            hintText: 'Write a few words...',
          ),
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
