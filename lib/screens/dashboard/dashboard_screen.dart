import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/daily_log_provider.dart';
import '../../providers/focus_timer_provider.dart';
import '../../providers/reflection_provider.dart';
import '../../providers/github_provider.dart';
import '../../providers/leetcode_provider.dart';
import '../../widgets/github_contribution_chart.dart';
import '../../widgets/leetcode_diagram.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingScreen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.dashboardTitle, style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 4),
                        Text(AppStrings.dashboardSubhead, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const _LiveClock(),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingL),

              _MetricsRow(),

              const SizedBox(height: AppDimensions.spacingXL),

              Row(
                children: [
                  const Icon(Icons.code, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text('GitHub Contributions', style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingS),
              const _GithubSection(),

              const SizedBox(height: AppDimensions.spacingXL),

              Row(
                children: [
                  const Icon(Icons.code, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text('LeetCode Progress', style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingS),
              const _LeetCodeSection(),

              const SizedBox(height: AppDimensions.spacingXL),

              Text(AppStrings.dashboardBadges, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppDimensions.spacingS),
              const _BadgesGrid(),

              const SizedBox(height: AppDimensions.spacingXL),

              Align(
                alignment: Alignment.center,
                child: Text(
                  'Keep showing up. Small steps compound.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final daily = context.watch<DailyLogProvider>();
    final focus = context.watch<FocusTimerProvider>();
    final reflection = context.watch<ReflectionProvider>();

    final todayMinutes = focus.getTodayTotalMinutes();
    final streak = daily.getDisciplineStreak();
    final reflectionRate = (reflection.getWeeklyReflectionRate() * 100).round();

    return Row(
      children: [
        _metricCard(context, label: 'Focus Today', value: '${todayMinutes}m', icon: Icons.timer),
        const SizedBox(width: AppDimensions.spacingM),
        _metricCard(context, label: 'Day Streak', value: '$streak', icon: Icons.local_fire_department, color: AppColors.warning),
        const SizedBox(width: AppDimensions.spacingM),
        _metricCard(context, label: 'Reflection Rate', value: '$reflectionRate%', icon: Icons.edit_note, color: AppColors.success),
      ],
    );
  }

  Widget _metricCard(BuildContext context, {required String label, required String value, required IconData icon, Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingCard),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.primary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color ?? AppColors.primary)),
                const SizedBox(height: 2),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgesGrid extends StatelessWidget {
  const _BadgesGrid();

  @override
  Widget build(BuildContext context) {
    final daily = context.watch<DailyLogProvider>();
    final focus = context.watch<FocusTimerProvider>();

    final badges = <_Badge>[
      _Badge(
        label: 'First Focus',
        icon: Icons.play_circle_fill,
        achieved: focus.getTodayTotalMinutes() > 0,
      ),
      _Badge(
        label: 'Pomodoro Pro',
        icon: Icons.av_timer,
        achieved: focus.getTodaySessions().where((s) => s.completed).length >= 4,
      ),
      _Badge(
        label: '7-Day Streak',
        icon: Icons.local_fire_department,
        achieved: daily.getDisciplineStreak() >= 7,
      ),
      _Badge(
        label: 'MVD Rescuer',
        icon: Icons.shield,
        achieved: daily.todayLog?.isMinimumViableDay == true,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.spacingM,
        mainAxisSpacing: AppDimensions.spacingM,
        childAspectRatio: 3,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final b = badges[index];
        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingCard),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(b.icon, color: b.achieved ? AppColors.success : AppColors.textHint),
              const SizedBox(width: 12),
              Text(
                b.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: b.achieved ? AppColors.success : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Badge {
  final String label;
  final IconData icon;
  final bool achieved;

  _Badge({required this.label, required this.icon, required this.achieved});
}

class _GithubSection extends StatefulWidget {
  const _GithubSection();

  @override
  State<_GithubSection> createState() => _GithubSectionState();
}

class _GithubSectionState extends State<_GithubSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final gh = context.read<GithubProvider>();
    _controller = TextEditingController(text: gh.username);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GithubProvider>(
      builder: (context, gh, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'GitHub username',
                      prefixIcon: const Icon(Icons.account_circle_outlined, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    onSubmitted: (v) => gh.setUsername(v),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: gh.loading ? null : gh.fetch,
                  icon: gh.loading
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh, size: 18),
                  label: const Text('Sync'),
                ),
              ],
            ),
            if (gh.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(gh.error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
              ),
            const SizedBox(height: 12),
            const GithubContributionChart(weeksToShow: 16),
          ],
        );
      },
    );
  }
}
class _LiveClock extends StatefulWidget {
  const _LiveClock();

  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}';
    final dateStr = '${_getDayName(_currentTime.weekday)}, ${_getMonthName(_currentTime.month)} ${_currentTime.day}';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          timeStr,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          dateStr,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
class _LeetCodeSection extends StatefulWidget {
  const _LeetCodeSection();

  @override
  State<_LeetCodeSection> createState() => _LeetCodeSectionState();
}

class _LeetCodeSectionState extends State<_LeetCodeSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final lc = context.read<LeetCodeProvider>();
    _controller = TextEditingController(text: lc.username);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeetCodeProvider>(
      builder: (context, lc, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'LeetCode username',
                      prefixIcon: const Icon(Icons.account_circle_outlined, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    onSubmitted: (v) => lc.setUsername(v),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: lc.loading ? null : lc.fetch,
                  icon: lc.loading
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh, size: 18),
                  label: const Text('Sync'),
                ),
              ],
            ),
            if (lc.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(lc.error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
              ),
            const SizedBox(height: 12),
            const LeetCodeDiagram(),
          ],
        );
      },
    );
  }
}