import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/github_provider.dart';
import 'contribution_cell.dart';

class GithubContributionChart extends StatelessWidget {
  final int weeksToShow;
  const GithubContributionChart({super.key, this.weeksToShow = 16});

  @override
  Widget build(BuildContext context) {
    return Consumer<GithubProvider>(builder: (context, gh, _) {
      final data = gh.contributionsByDate;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDayLabels(),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: _buildGrid(data),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDayLabels() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        SizedBox(height: 2),
        _DayLabel(''),
        _DayLabel('Mon'),
        _DayLabel(''),
        _DayLabel('Wed'),
        _DayLabel(''),
        _DayLabel('Fri'),
        _DayLabel(''),
      ],
    );
  }

  Widget _buildGrid(Map<String, int> contributions) {
    final now = DateTime.now();
    final weeks = <List<ContributionCell>>[];
    for (int w = weeksToShow - 1; w >= 0; w--) {
      final start = now.subtract(Duration(days: now.weekday - 1 + (w * 7)));
      final weekCells = <ContributionCell>[];
      for (int d = 0; d < 7; d++) {
        final date = start.add(Duration(days: d));
        final key = _key(date);
        final count = contributions[key] ?? 0;
        weekCells.add(ContributionCell(date: date, count: count));
      }
      weeks.add(weekCells);
    }

    final maxCount =  (contributions.isEmpty) ? 0 : (contributions.values.reduce((a, b) => a > b ? a : b));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: weeks.map<Widget>((List<ContributionCell> week) {
        return Column(
          children: week.map<Widget>((ContributionCell cell) {
            final color = _colorFor(cell.count, maxCount);
            return Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  String _key(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Color _colorFor(int count, int maxCount) {
    if (count <= 0) return AppColors.surfaceLight;
    if (maxCount <= 0) return AppColors.primary.withOpacity(0.2);
    // buckets: 1, 2-3, 4-6, 7+
    if (count == 1) return AppColors.primary.withOpacity(0.25);
    if (count <= 3) return AppColors.primary.withOpacity(0.45);
    if (count <= 6) return AppColors.primary.withOpacity(0.7);
    return AppColors.primary;
  }
}

class _DayLabel extends StatelessWidget {
  final String text;
  const _DayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: Text(text, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
    );
  }
}