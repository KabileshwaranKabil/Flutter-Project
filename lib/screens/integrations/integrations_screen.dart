import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../providers/github_provider.dart';
import '../../providers/leetcode_provider.dart';
import '../../widgets/github_contribution_chart.dart';

class IntegrationsScreen extends StatelessWidget {
  const IntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Integrations')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingScreen),
        children: const [
          _GithubCard(),
          SizedBox(height: AppDimensions.spacingL),
          _LeetCodeCard(),
        ],
      ),
    );
  }
}

class _GithubCard extends StatefulWidget {
  const _GithubCard();

  @override
  State<_GithubCard> createState() => _GithubCardState();
}

class _GithubCardState extends State<_GithubCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final provider = context.read<GithubProvider>();
    _controller = TextEditingController(text: provider.username);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GithubProvider>(
      builder: (context, provider, _) {
        return _CardContainer(
          title: 'GitHub Contributions',
          trailing: ElevatedButton(
            onPressed: provider.loading ? null : provider.fetch,
            child: provider.loading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Refresh'),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.account_circle_outlined),
                ),
                onSubmitted: (v) => provider.setUsername(v),
              ),
              const SizedBox(height: 12),
              if (provider.error != null)
                Text(
                  provider.error!,
                  style: const TextStyle(color: AppColors.error),
                ),
              _StatRow(label: 'Total (12m)', value: provider.totalContributions.toString()),
              _StatRow(label: 'Current streak', value: '${provider.currentStreak}'),
              _StatRow(label: 'Longest streak', value: '${provider.longestStreak}'),
              if (provider.lastFetched != null)
                _StatRow(label: 'Last synced', value: provider.lastFetched!.toLocal().toString()),
              const SizedBox(height: 12),
              const GithubContributionChart(weeksToShow: 12),
            ],
          ),
        );
      },
    );
  }
}

class _LeetCodeCard extends StatefulWidget {
  const _LeetCodeCard();

  @override
  State<_LeetCodeCard> createState() => _LeetCodeCardState();
}

class _LeetCodeCardState extends State<_LeetCodeCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final provider = context.read<LeetCodeProvider>();
    _controller = TextEditingController(text: provider.username);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeetCodeProvider>(
      builder: (context, provider, _) {
        return _CardContainer(
          title: 'LeetCode Progress',
          trailing: ElevatedButton(
            onPressed: provider.loading ? null : provider.fetch,
            child: provider.loading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Refresh'),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.account_circle_outlined),
                ),
                onSubmitted: (v) => provider.setUsername(v),
              ),
              const SizedBox(height: 12),
              if (provider.error != null)
                Text(
                  provider.error!,
                  style: const TextStyle(color: AppColors.error),
                ),
              _StatRow(label: 'Solved total', value: '${provider.solvedTotal}'),
              _StatRow(label: 'Easy', value: '${provider.solvedEasy}'),
              _StatRow(label: 'Medium', value: '${provider.solvedMedium}'),
              _StatRow(label: 'Hard', value: '${provider.solvedHard}'),
              if (provider.lastFetched != null)
                _StatRow(label: 'Last synced', value: provider.lastFetched!.toLocal().toString()),
            ],
          ),
        );
      },
    );
  }
}

class _CardContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _CardContainer({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
