import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/daily_log_provider.dart';

/// Monthly bar chart showing daily completion scores
class MonthlyChart extends StatelessWidget {
  final DateTime month;
  final Function(DateTime)? onMonthChange;

  const MonthlyChart({
    super.key,
    required this.month,
    this.onMonthChange,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DailyLogProvider>(
      builder: (context, provider, child) {
        final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
        final now = DateTime.now();
        
        // Calculate stats
        int totalDays = 0;
        int completedDays = 0;
        double totalScore = 0;
        
        final dailyScores = <int, int>{};
        for (int day = 1; day <= daysInMonth; day++) {
          final date = DateTime(month.year, month.month, day);
          if (date.isAfter(now)) continue;
          
          totalDays++;
          final log = provider.getLogForDate(date);
          final score = log?.showUpPercentage ?? 0;
          dailyScores[day] = score;
          totalScore += score;
          if (score >= 50) completedDays++;
        }
        
        final avgScore = totalDays > 0 ? (totalScore / totalDays).round() : 0;

        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingCard),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            children: [
              // Month selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    onPressed: () => onMonthChange?.call(
                      DateTime(month.year, month.month - 1),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: AppColors.textSecondary,
                  ),
                  Text(
                    _formatMonth(month),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    onPressed: month.year >= now.year && month.month >= now.month
                        ? null
                        : () => onMonthChange?.call(
                            DateTime(month.year, month.month + 1),
                          ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: month.year >= now.year && month.month >= now.month
                        ? AppColors.textHint
                        : AppColors.textSecondary,
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spacingM),
              
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'Avg Score',
                    value: '$avgScore%',
                    color: _getScoreColor(avgScore),
                  ),
                  _StatItem(
                    label: 'Good Days',
                    value: '$completedDays/$totalDays',
                    color: AppColors.success,
                  ),
                  _StatItem(
                    label: 'Consistency',
                    value: totalDays > 0 
                        ? '${((completedDays / totalDays) * 100).round()}%'
                        : '0%',
                    color: AppColors.primary,
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spacingL),
              
              // Bar chart
              SizedBox(
                height: 80,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(daysInMonth, (index) {
                    final day = index + 1;
                    final score = dailyScores[day] ?? 0;
                    final date = DateTime(month.year, month.month, day);
                    final isFuture = date.isAfter(now);
                    
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: isFuture ? 0 : (score / 100).clamp(0.05, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isFuture 
                                          ? Colors.transparent
                                          : _getScoreColor(score).withOpacity(0.8),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Show day labels for 1, 7, 14, 21, 28
                            if (day == 1 || day == 7 || day == 14 || day == 21 || day == 28)
                              Text(
                                '$day',
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: AppColors.textSecondary,
                                ),
                              )
                            else
                              const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    if (score > 0) return AppColors.error;
    return AppColors.textHint;
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
