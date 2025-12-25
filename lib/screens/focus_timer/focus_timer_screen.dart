import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/models/focus_session.dart';
import '../../providers/focus_timer_provider.dart';

/// Focus session timer screen
class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final initialNotes = context.read<FocusTimerProvider>().notes;
    _notesController = TextEditingController(text: initialNotes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _openFeynmanSheet(BuildContext context, FocusTimerProvider provider) {
    String _extract(String label, String source) {
      final regex = RegExp('$label:(.*?)(?=\n[A-Z][a-zA-Z ]+:|\$)', dotAll: true);
      final match = regex.firstMatch('$source\$');
      return match == null ? '' : match.group(1)!.trim();
    }

    final existing = provider.notes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppDimensions.paddingScreen,
            right: AppDimensions.paddingScreen,
            top: AppDimensions.spacingL,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppDimensions.spacingL,
          ),
          child: _FeynmanSheet(
            initialTopic: _extract('Topic', existing),
            initialTeach: _extract('Explain', existing),
            initialGaps: _extract('Gaps', existing),
            initialRefine: _extract('Refine', existing),
            onSave: (topic, teach, gaps, refine) {
              final buffer = StringBuffer();
              if (topic.isNotEmpty) buffer.writeln('Topic: $topic');
              if (teach.isNotEmpty) buffer.writeln('Explain: $teach');
              if (gaps.isNotEmpty) buffer.writeln('Gaps: $gaps');
              if (refine.isNotEmpty) buffer.writeln('Refine: $refine');
              final compiled = buffer.toString().trim();

              provider.setNotes(compiled);
              _notesController.text = compiled;
              _notesController.selection = TextSelection.fromPosition(
                TextPosition(offset: _notesController.text.length),
              );

              Navigator.of(sheetContext).pop();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FocusTimerProvider>(
      builder: (context, provider, child) {
        if (_notesController.text != provider.notes) {
          _notesController.text = provider.notes;
          _notesController.selection = TextSelection.fromPosition(
            TextPosition(offset: _notesController.text.length),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingScreen),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      Text(
                        AppStrings.timerTitle,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const Spacer(),
                      // Today's total
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${provider.getTodayTotalMinutes()} min today',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Timer display
                  _TimerDisplay(
                    formattedTime: provider.formattedTime,
                    progress: provider.progress,
                    isRunning: provider.isRunning,
                    category: provider.selectedCategory,
                  ),
                  
                  const SizedBox(height: AppDimensions.spacingXL),
                  
                  // Category selector (disabled when running)
                  if (!provider.isRunning) ...[
                    Text(
                      AppStrings.timerSelectCategory,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    _CategorySelector(
                      selectedCategory: provider.selectedCategory,
                      onChanged: provider.setCategory,
                    ),
                    
                    const SizedBox(height: AppDimensions.spacingXL),
                    
                    // Technique selector
                    Text(
                      AppStrings.timerSelectTechnique,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    _TechniqueSelector(
                      selectedTechnique: provider.selectedTechnique,
                      onChanged: provider.setTechnique,
                    ),

                    const SizedBox(height: AppDimensions.spacingXL),
                    
                    // Duration selector
                    Text(
                      AppStrings.timerSelectDuration,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    _DurationSelector(
                      selectedDuration: provider.selectedDuration,
                      onChanged: provider.setDuration,
                    ),
                  ] else ...[
                    // Show current category and technique when running
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                provider.selectedCategory.emoji,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                provider.selectedCategory.displayName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingM),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt_outlined, size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                provider.selectedTechnique.displayName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: AppDimensions.spacingL),

                  // Notes + Feynman helper
                  _NotesField(
                    controller: _notesController,
                    onChanged: provider.setNotes,
                    enabled: true,
                  ),
                  if (provider.selectedTechnique == FocusTechnique.feynman)
                    Padding(
                      padding: const EdgeInsets.only(top: AppDimensions.spacingS),
                      child: OutlinedButton.icon(
                        onPressed: () => _openFeynmanSheet(context, provider),
                        icon: const Icon(Icons.school_outlined),
                        label: const Text(AppStrings.timerFeynmanCta),
                      ),
                    ),
                  
                  const SizedBox(height: AppDimensions.spacingL),

                  // Start/Stop button
                  _ActionButton(
                    isRunning: provider.isRunning,
                    isCompleted: provider.currentSession?.completed ?? false,
                    onStart: provider.startSession,
                    onStop: provider.stopSession,
                    onReset: provider.reset,
                  ),
                  
                  const SizedBox(height: AppDimensions.spacingL),
                  
                  // Today's sessions
                  if (!provider.isRunning) _TodaysSessions(provider: provider),
                  
                  const SizedBox(height: AppDimensions.spacingM),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Circular timer display
class _TimerDisplay extends StatelessWidget {
  final String formattedTime;
  final double progress;
  final bool isRunning;
  final FocusCategory category;

  const _TimerDisplay({
    required this.formattedTime,
    required this.progress,
    required this.isRunning,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppDimensions.timerSize,
      height: AppDimensions.timerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: AppDimensions.timerSize,
            height: AppDimensions.timerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.border, width: 2),
            ),
          ),
          
          // Progress arc
          if (isRunning)
            CustomPaint(
              size: Size(AppDimensions.timerSize, AppDimensions.timerSize),
              painter: _ProgressPainter(
                progress: progress,
                color: AppColors.primary,
                strokeWidth: AppDimensions.timerStroke,
              ),
            ),
          
          // Time text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formattedTime,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textPrimary,
                  letterSpacing: 2,
                ),
              ),
              if (!isRunning)
                Text(
                  'minutes',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom painter for progress arc
class _ProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Category selector chips
class _CategorySelector extends StatelessWidget {
  final FocusCategory selectedCategory;
  final ValueChanged<FocusCategory> onChanged;

  const _CategorySelector({
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spacingS,
      runSpacing: AppDimensions.spacingS,
      alignment: WrapAlignment.center,
      children: FocusCategory.values.map((category) {
        final isSelected = category == selectedCategory;
        return GestureDetector(
          onTap: () => onChanged(category),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(category.emoji),
                const SizedBox(width: 6),
                Text(
                  category.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.background : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Technique selector chips
class _TechniqueSelector extends StatelessWidget {
  final FocusTechnique selectedTechnique;
  final ValueChanged<FocusTechnique> onChanged;

  const _TechniqueSelector({
    required this.selectedTechnique,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spacingS,
      runSpacing: AppDimensions.spacingS,
      alignment: WrapAlignment.center,
      children: FocusTechnique.values.map((technique) {
        final isSelected = technique == selectedTechnique;
        return GestureDetector(
          onTap: () => onChanged(technique),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  technique == FocusTechnique.feynman
                      ? Icons.school_outlined
                      : technique == FocusTechnique.srs_review
                          ? Icons.layers_outlined
                          : Icons.timer_outlined,
                  size: 18,
                  color: isSelected ? AppColors.background : AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      technique.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.background : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      technique.hint,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? AppColors.background.withOpacity(0.9) : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Duration selector chips
class _DurationSelector extends StatelessWidget {
  final int selectedDuration;
  final ValueChanged<int> onChanged;

  const _DurationSelector({
    required this.selectedDuration,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: FocusTimerProvider.availableDurations.map((duration) {
        final isSelected = duration == selectedDuration;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            onTap: () => onChanged(duration),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$duration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.background : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Notes field shared across techniques
class _NotesField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const _NotesField({
    required this.controller,
    required this.onChanged,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.timerNotesLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppDimensions.spacingS),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: AppStrings.timerNotesHint,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Guided Feynman flow
class _FeynmanSheet extends StatefulWidget {
  final String initialTopic;
  final String initialTeach;
  final String initialGaps;
  final String initialRefine;
  final void Function(String topic, String teach, String gaps, String refine) onSave;

  const _FeynmanSheet({
    required this.initialTopic,
    required this.initialTeach,
    required this.initialGaps,
    required this.initialRefine,
    required this.onSave,
  });

  @override
  State<_FeynmanSheet> createState() => _FeynmanSheetState();
}

class _FeynmanSheetState extends State<_FeynmanSheet> {
  late final TextEditingController _topicController;
  late final TextEditingController _teachController;
  late final TextEditingController _gapsController;
  late final TextEditingController _refineController;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController(text: widget.initialTopic);
    _teachController = TextEditingController(text: widget.initialTeach);
    _gapsController = TextEditingController(text: widget.initialGaps);
    _refineController = TextEditingController(text: widget.initialRefine);
  }

  @override
  void dispose() {
    _topicController.dispose();
    _teachController.dispose();
    _gapsController.dispose();
    _refineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_outlined, color: AppColors.primary),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                AppStrings.timerFeynmanCta,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          _FeynmanField(
            label: AppStrings.timerFeynmanTopic,
            controller: _topicController,
            hint: 'What are you trying to understand? (one sentence)',
          ),
          const SizedBox(height: AppDimensions.spacingM),
          _FeynmanField(
            label: AppStrings.timerFeynmanTeach,
            controller: _teachController,
            hint: 'Explain like you are teaching a friend. Keep it simple.',
          ),
          const SizedBox(height: AppDimensions.spacingM),
          _FeynmanField(
            label: AppStrings.timerFeynmanGaps,
            controller: _gapsController,
            hint: 'List places you hesitated or hand-waved.',
          ),
          const SizedBox(height: AppDimensions.spacingM),
          _FeynmanField(
            label: AppStrings.timerFeynmanRefine,
            controller: _refineController,
            hint: 'Use examples or analogies to patch the gaps.',
          ),
          const SizedBox(height: AppDimensions.spacingL),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(
                  _topicController.text.trim(),
                  _teachController.text.trim(),
                  _gapsController.text.trim(),
                  _refineController.text.trim(),
                );
              },
              child: const Text(AppStrings.timerSaveSteps),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeynmanField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _FeynmanField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppDimensions.spacingS),
        TextField(
          controller: controller,
          maxLines: null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Action button (Start/Stop/Reset)
class _ActionButton extends StatelessWidget {
  final bool isRunning;
  final bool isCompleted;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onReset;

  const _ActionButton({
    required this.isRunning,
    required this.isCompleted,
    required this.onStart,
    required this.onStop,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Column(
        children: [
          const Icon(
            Icons.check_circle,
            size: 48,
            color: AppColors.success,
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            AppStrings.timerComplete,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          TextButton(
            onPressed: onReset,
            child: const Text('Start another'),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isRunning ? onStop : onStart,
        style: ElevatedButton.styleFrom(
          backgroundColor: isRunning ? AppColors.error : AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          isRunning ? AppStrings.timerStop : AppStrings.timerStart,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Today's completed sessions
class _TodaysSessions extends StatelessWidget {
  final FocusTimerProvider provider;

  const _TodaysSessions({required this.provider});

  @override
  Widget build(BuildContext context) {
    final sessions = provider.getTodaySessions();
    final completedSessions = sessions.where((s) => s.completed).toList();
    
    if (completedSessions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s sessions',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: completedSessions.take(4).map((session) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(session.category.emoji, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '${session.durationMinutes}m',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.bolt_outlined, size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          session.technique.displayName,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    if (session.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        session.notes.length > 60
                            ? '${session.notes.substring(0, 60)}...'
                            : session.notes,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
