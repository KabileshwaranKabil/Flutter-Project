import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/leetcode_provider.dart';

class LeetCodeDiagram extends StatelessWidget {
  const LeetCodeDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LeetCodeProvider>(
      builder: (context, lc, _) {
        final total = lc.solvedTotal;
        final easy = lc.solvedEasy;
        final medium = lc.solvedMedium;
        final hard = lc.solvedHard;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Total: $total',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _DifficultyBar(
                label: 'Easy',
                count: easy,
                color: AppColors.success,
              ),
              const SizedBox(height: 8),
              _DifficultyBar(
                label: 'Medium',
                count: medium,
                color: AppColors.warning,
              ),
              const SizedBox(height: 8),
              _DifficultyBar(
                label: 'Hard',
                count: hard,
                color: AppColors.error,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DifficultyBar extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _DifficultyBar({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              if (count > 0)
                Container(
                  height: 24,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
