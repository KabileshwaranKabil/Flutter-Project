import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';
import '../../providers/daily_log_provider.dart';
import '../../providers/reflection_provider.dart';
import '../../widgets/common_widgets.dart';

/// Weekly review dashboard screen
class WeeklyReviewScreen extends StatelessWidget {
  const WeeklyReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<DailyLogProvider, ReflectionProvider>(
      builder: (context, logProvider, reflectionProvider, child) {
        final weeklyConsistency = logProvider.getWeeklyConsistency();
        final systemConsistencies = logProvider.getSystemConsistencies();
        final weakestSystem = logProvider.getWeakestSystem();
        final disciplineStreak = logProvider.getDisciplineStreak();
        final reflectionRate = reflectionProvider.getWeeklyReflectionRate();

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
                        Text(
                          AppStrings.weeklyTitle,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getWeekRange(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingScreen),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Overall consistency card
                      _OverallConsistencyCard(
                        percentage: (weeklyConsistency * 100).round(),
                        streak: disciplineStreak,
                      ),

                      const SizedBox(height: AppDimensions.spacingL),

                      // System breakdown
                      SectionHeader(
                        title: 'SYSTEM BREAKDOWN',
                        color: AppColors.textSecondary,
                      ),
                      CalmCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingCard,
                          vertical: AppDimensions.spacingS,
                        ),
                        child: Column(
                          children: [
                            _SystemRow(
                              name: 'Learning',
                              color: AppColors.learning,
                              percentage: (systemConsistencies['learning']! * 100).round(),
                            ),
                            _SystemRow(
                              name: 'Projects',
                              color: AppColors.projects,
                              percentage: (systemConsistencies['projects']! * 100).round(),
                            ),
                            _SystemRow(
                              name: 'Academics',
                              color: AppColors.academics,
                              percentage: (systemConsistencies['academics']! * 100).round(),
                            ),
                            _SystemRow(
                              name: 'Health',
                              color: AppColors.health,
                              percentage: (systemConsistencies['health']! * 100).round(),
                            ),
                            _SystemRow(
                              name: 'Mind & Discipline',
                              color: AppColors.mind,
                              percentage: (systemConsistencies['mind']! * 100).round(),
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingL),

                      // Reflection rate
                      SectionHeader(
                        title: 'REFLECTION RATE',
                        color: AppColors.textSecondary,
                      ),
                      CalmCard(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit_note,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: AppDimensions.spacingM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daily Reflections',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    '${(reflectionRate * 7).round()} of 7 days completed',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            ScorePill(percentage: (reflectionRate * 100).round()),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingL),

                      // Weakest system
                      if (weakestSystem != null) ...[
                        SectionHeader(
                          title: 'FOCUS FOR NEXT WEEK',
                          color: AppColors.textSecondary,
                        ),
                        _FocusCard(systemName: weakestSystem),
                      ],

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

  String _getWeekRange() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[startOfWeek.month - 1]} ${startOfWeek.day} - ${months[endOfWeek.month - 1]} ${endOfWeek.day}';
  }
}

/// Overall consistency card with circular indicator
class _OverallConsistencyCard extends StatelessWidget {
  final int percentage;
  final int streak;

  const _OverallConsistencyCard({
    required this.percentage,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 6,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor: AlwaysStoppedAnimation<Color>(_getColor()),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _getColor(),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: AppDimensions.spacingL),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.weeklyConsistency,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Days with ≥50% completion',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: streak > 0 ? AppColors.warning : AppColors.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$streak day streak',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: streak > 0 ? AppColors.warning : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 50) return AppColors.warning;
    return AppColors.error;
  }
}

/// System row in breakdown
class _SystemRow extends StatelessWidget {
  final String name;
  final Color color;
  final int percentage;
  final bool isLast;

  const _SystemRow({
    required this.name,
    required this.color,
    required this.percentage,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.8)),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 40,
            child: Text(
              '$percentage%',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _getColor(percentage),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(int pct) {
    if (pct >= 70) return AppColors.success;
    if (pct >= 40) return AppColors.warning;
    return AppColors.error;
  }
}

/// Focus card for weakest system
class _FocusCard extends StatelessWidget {
  final String systemName;

  const _FocusCard({required this.systemName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingCard),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.warning.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.lightbulb_outline,
              color: AppColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Improve: ${_formatSystemName(systemName)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'This system needs more attention this week',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatSystemName(String name) {
    switch (name) {
      case 'learning':
        return 'Learning';
      case 'projects':
        return 'Projects';
      case 'academics':
        return 'Academics';
      case 'health':
        return 'Health';
      case 'mind':
        return 'Mind & Discipline';
      default:
        return name;
    }
  }
}
