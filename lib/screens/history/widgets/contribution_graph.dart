import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/daily_log_provider.dart';

/// GitHub-style contribution graph showing daily activity
class ContributionGraph extends StatelessWidget {
  final Function(DateTime)? onDayTap;
  final int weeksToShow;

  const ContributionGraph({
    super.key,
    this.onDayTap,
    this.weeksToShow = 16, // ~4 months
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DailyLogProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month labels
              _buildMonthLabels(),
              const SizedBox(height: 8),
              
              // Grid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day labels (Mon, Wed, Fri)
                  _buildDayLabels(),
                  const SizedBox(width: 8),
                  
                  // Contribution squares
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true, // Start from right (recent)
                      child: _buildGrid(provider),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthLabels() {
    final now = DateTime.now();
    final months = <String>[];
    final monthPositions = <int>[];
    
    int? lastMonth;
    for (int week = weeksToShow - 1; week >= 0; week--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (week * 7)));
      if (weekStart.month != lastMonth) {
        months.add(_getMonthAbbr(weekStart.month));
        monthPositions.add(weeksToShow - 1 - week);
        lastMonth = weekStart.month;
      }
    }

    return SizedBox(
      height: 16,
      child: Row(
        children: [
          const SizedBox(width: 24), // For day labels
          Expanded(
            child: Stack(
              children: [
                for (int i = 0; i < months.length; i++)
                  Positioned(
                    left: monthPositions[i] * 14.0,
                    child: Text(
                      months[i],
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayLabels() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const SizedBox(height: 2),
        _dayLabel(''),
        _dayLabel('Mon'),
        _dayLabel(''),
        _dayLabel('Wed'),
        _dayLabel(''),
        _dayLabel('Fri'),
        _dayLabel(''),
      ],
    );
  }

  Widget _dayLabel(String text) {
    return SizedBox(
      height: 12,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildGrid(DailyLogProvider provider) {
    final now = DateTime.now();
    final weeks = <List<_DayData>>[];

    for (int week = weeksToShow - 1; week >= 0; week--) {
      final weekDays = <_DayData>[];
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (week * 7)));
      
      for (int day = 0; day < 7; day++) {
        final date = weekStart.add(Duration(days: day));
        if (date.isAfter(now)) {
          weekDays.add(_DayData(date: date, score: -1)); // Future
        } else {
          final log = provider.getLogForDate(date);
          weekDays.add(_DayData(
            date: date,
            score: log?.showUpPercentage ?? 0,
            hasData: log != null,
          ));
        }
      }
      weeks.add(weekDays);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: weeks.map((week) {
        return Column(
          children: week.map((day) {
            return GestureDetector(
              onTap: day.score >= 0 ? () => onDayTap?.call(day.date) : null,
              child: Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: _getColorForScore(day.score, day.hasData),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Color _getColorForScore(int score, bool hasData) {
    if (score < 0) return Colors.transparent; // Future
    if (!hasData || score == 0) return AppColors.surfaceLight;
    if (score < 25) return AppColors.primary.withOpacity(0.2);
    if (score < 50) return AppColors.primary.withOpacity(0.4);
    if (score < 75) return AppColors.primary.withOpacity(0.7);
    return AppColors.primary;
  }

  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

class _DayData {
  final DateTime date;
  final int score;
  final bool hasData;

  _DayData({
    required this.date,
    required this.score,
    this.hasData = false,
  });
}
