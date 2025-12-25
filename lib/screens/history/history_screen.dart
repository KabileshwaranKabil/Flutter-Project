import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/models/daily_log.dart';
import '../../providers/daily_log_provider.dart';
import 'widgets/contribution_graph.dart';
import 'widgets/monthly_chart.dart';
import 'widgets/day_detail_sheet.dart';

/// History screen with calendar, contribution graph, and charts
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedMonth = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    return Consumer<DailyLogProvider>(
      builder: (context, provider, child) {
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
                          'History',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your discipline journey',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),

                // GitHub-style Contribution Graph
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingScreen),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.grid_view, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              'Contribution Graph',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const Spacer(),
                            _buildStreakBadge(provider.getDisciplineStreak()),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingM),
                        ContributionGraph(
                          onDayTap: (date) => _showDayDetail(context, date, provider),
                        ),
                        const SizedBox(height: AppDimensions.spacingS),
                        _buildLegend(),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.spacingXL)),

                // Monthly Completion Chart
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingScreen),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bar_chart, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              'Monthly Progress',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingM),
                        MonthlyChart(
                          month: _selectedMonth,
                          onMonthChange: (month) => setState(() => _selectedMonth = month),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.spacingXL)),

                // Quick Access - Recent Days
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingScreen),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.history, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              'Recent Days',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingM),
                      ],
                    ),
                  ),
                ),

                // Recent days list
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingScreen),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final date = DateTime.now().subtract(Duration(days: index));
                        final log = provider.getLogForDate(date);
                        return _RecentDayCard(
                          date: date,
                          log: log,
                          onTap: () => _showDayDetail(context, date, provider),
                        );
                      },
                      childCount: 14, // Last 2 weeks
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.spacingXXL)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStreakBadge(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: streak > 0 ? AppColors.warning.withOpacity(0.15) : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 14,
            color: streak > 0 ? AppColors.warning : AppColors.textHint,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak day streak',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: streak > 0 ? AppColors.warning : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Less',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
        ),
        const SizedBox(width: 4),
        _legendBox(AppColors.surfaceLight),
        _legendBox(AppColors.primary.withOpacity(0.2)),
        _legendBox(AppColors.primary.withOpacity(0.4)),
        _legendBox(AppColors.primary.withOpacity(0.7)),
        _legendBox(AppColors.primary),
        const SizedBox(width: 4),
        Text(
          'More',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
        ),
      ],
    );
  }

  Widget _legendBox(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  void _showDayDetail(BuildContext context, DateTime date, DailyLogProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DayDetailSheet(
        date: date,
        log: provider.getLogForDate(date),
      ),
    );
  }
}

/// Card for recent day in the list
class _RecentDayCard extends StatelessWidget {
  final DateTime date;
  final DailyLog? log;
  final VoidCallback onTap;

  const _RecentDayCard({
    required this.date,
    required this.log,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(date);
    final isYesterday = _isYesterday(date);
    final score = log?.showUpPercentage ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: isToday ? AppColors.primary : AppColors.border,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingCard),
            child: Row(
              children: [
                // Date indicator
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getScoreColor(score).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _getScoreColor(score),
                        ),
                      ),
                      Text(
                        _getMonthAbbr(date.month),
                        style: TextStyle(
                          fontSize: 10,
                          color: _getScoreColor(score),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                
                // Day info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isToday ? 'Today' : (isYesterday ? 'Yesterday' : _getDayName(date)),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      if (log != null)
                        Text(
                          '${log!.completedSystemsCount}/5 systems • ${score}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      else
                        Text(
                          'No data logged',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textHint,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Score indicator
                if (log != null)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getScoreColor(score).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _getScoreColor(score),
                        ),
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    if (score > 0) return AppColors.error;
    return AppColors.textHint;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  String _getDayName(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  String _getMonthAbbr(int month) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
