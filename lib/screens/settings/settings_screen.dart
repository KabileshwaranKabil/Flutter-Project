import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/daily_log_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/security_provider.dart';
import '../../data/local/hive_service.dart';
import '../../data/local/export_service.dart';
import '../profile/profile_screen.dart';
import '../integrations/integrations_screen.dart';
import '../srs/srs_screen.dart';

const List<Color> _presetColors = [
  Color(0xFF4DB6AC), // teal (default)
  Color(0xFF7C4DFF), // purple
  Color(0xFF42A5F5), // blue
  Color(0xFFFFB74D), // amber
  Color(0xFFEF5350), // red
];

/// Settings screen for app preferences
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferencesProvider>(
      builder: (context, prefsProvider, child) {
        final prefs = prefsProvider.preferences;
        
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: AppColors.background,
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingScreen),
            children: [
              // App Info Section
              _buildSectionHeader(context, 'APP INFO'),
              _buildInfoCard(context),
              
              const SizedBox(height: AppDimensions.spacingL),

              // Security Section
              _buildSectionHeader(context, 'SECURITY'),
              Consumer<SecurityProvider>(
                builder: (context, security, _) {
                  return _SettingsCard(
                    children: [
                      _SettingsAction(
                        title: security.hasPin ? 'Change PIN' : 'Set PIN',
                        subtitle: security.hasPin
                            ? 'Update your unlock code'
                            : 'Add a PIN to lock the app',
                        icon: Icons.lock,
                        onTap: () => _setPin(context),
                      ),
                      const Divider(color: AppColors.divider, height: 1),
                      _SettingsAction(
                        title: 'Remove PIN',
                        subtitle: 'Disable app lock',
                        icon: Icons.lock_open,
                        isDestructive: true,
                        onTap: security.hasPin ? () => _removePin(context) : null,
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: AppDimensions.spacingL),
              
              // Appearance Section
              _buildSectionHeader(context, 'APPEARANCE'),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return _SettingsCard(
                    children: [
                      _SettingsToggle(
                        title: 'Dark Mode',
                        subtitle: 'Switch between light and dark theme',
                        value: themeProvider.isDarkMode,
                        onChanged: (_) => themeProvider.toggleTheme(),
                      ),
                      const Divider(color: AppColors.divider, height: 1),
                      Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingCard),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Accent Color', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: _presetColors.map((c) {
                                final selected = themeProvider.seedColor.value == c.value;
                                return ChoiceChip(
                                  label: const SizedBox(width: 12, height: 12),
                                  selected: selected,
                                  selectedColor: c,
                                  backgroundColor: c.withOpacity(0.2),
                                  shape: StadiumBorder(side: BorderSide(color: selected ? c : AppColors.border)),
                                  onSelected: (_) => themeProvider.setSeedColor(c),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: AppDimensions.spacingL),
              
              // Notifications Section
              _buildSectionHeader(context, 'NOTIFICATIONS'),
              _SettingsCard(
                children: [
                  _SettingsToggle(
                    title: 'Daily Reminder',
                    subtitle: 'Get reminded to log your day',
                    value: prefs.dailyReminder,
                    onChanged: (_) => prefsProvider.toggleDailyReminder(),
                  ),
                  if (prefs.dailyReminder) ...[
                    const Divider(color: AppColors.divider, height: 1),
                    _SettingsTimePicker(
                      title: 'Reminder Time',
                      time: prefs.reminderTime,
                      onChanged: (hours, minutes) => 
                        prefsProvider.setReminderTime(hours, minutes),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: AppDimensions.spacingL),
              
              // Preferences Section
              _buildSectionHeader(context, 'PREFERENCES'),
              _SettingsCard(
                children: [
                  _SettingsToggle(
                    title: 'Minimum Viable Day',
                    subtitle: 'Show MVD toggle on checklist',
                    value: prefs.minimumViableDayEnabled,
                    onChanged: (_) => prefsProvider.toggleMvdEnabled(),
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  _SettingsDropdown(
                    title: 'First Day of Week',
                    value: prefs.firstDayOfWeek,
                    options: const {0: 'Sunday', 1: 'Monday'},
                    onChanged: (value) => prefsProvider.setFirstDayOfWeek(value),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spacingL),
              
              // Profile Section
              _buildSectionHeader(context, 'PROFILE'),
              _SettingsCard(
                children: [
                  _SettingsAction(
                    title: 'Edit Profile',
                    subtitle: 'Update your profile information',
                    icon: Icons.person,
                    onTap: () => _navigateToProfile(context),
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  _SettingsAction(
                    title: 'Spaced Repetition',
                    subtitle: 'Review study cards',
                    icon: Icons.style,
                    onTap: () => _navigateToSrs(context),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spacingL),
              
              // Data Section
              _buildSectionHeader(context, 'DATA'),
              _SettingsCard(
                children: [
                  _SettingsAction(
                    title: 'Export Data',
                    subtitle: 'Save your data as JSON',
                    icon: Icons.download,
                    onTap: () => _exportData(context),
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  _SettingsAction(
                    title: AppStrings.dataImport,
                    subtitle: AppStrings.dataImportSubtitle,
                    icon: Icons.upload,
                    onTap: () => _importData(context),
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  _SettingsAction(
                    title: 'Clear All Data',
                    subtitle: 'Delete all logs and settings',
                    icon: Icons.delete_forever,
                    isDestructive: true,
                    onTap: () => _showClearDataDialog(context),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spacingL),
              
              // Stats Section
              _buildSectionHeader(context, 'STATISTICS'),
              _buildStatsCard(context),
              
              const SizedBox(height: AppDimensions.spacingXXL),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingCard),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.track_changes,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.appName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.appTagline,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Consumer<DailyLogProvider>(
      builder: (context, provider, child) {
        final streak = provider.getDisciplineStreak();
        final totalDays = HiveService.dailyLogs.length;
        final weeklyConsistency = (provider.getWeeklyConsistency() * 100).round();
        
        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingCard),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatColumn(
                value: '$totalDays',
                label: 'Days Logged',
                icon: Icons.calendar_today,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.divider,
              ),
              _StatColumn(
                value: '$streak',
                label: 'Day Streak',
                icon: Icons.local_fire_department,
                color: AppColors.warning,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.divider,
              ),
              _StatColumn(
                value: '$weeklyConsistency%',
                label: 'This Week',
                icon: Icons.trending_up,
                color: AppColors.success,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final file = await ExportService.exportAll();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported to ${file.path}'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      await ExportService.importLatest(clearExisting: true);
      if (!context.mounted) return;
      // Refresh providers likely impacted by import
      await context.read<DailyLogProvider>().init();
      await context.read<PreferencesProvider>().init();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Imported data from last export file.'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  void _navigateToIntegrations(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const IntegrationsScreen()),
    );
  }

  void _navigateToSrs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SrsScreen()),
    );
  }

  Future<void> _showClearDataDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your logs, reflections, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await HiveService.clearAll();
      if (context.mounted) {
        // Reinitialize providers
        context.read<DailyLogProvider>().init();
        context.read<PreferencesProvider>().init();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _setPin(BuildContext context) async {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Set PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinController,
                decoration: const InputDecoration(
                  labelText: 'Enter new PIN',
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              TextField(
                controller: confirmController,
                decoration: const InputDecoration(
                  labelText: 'Confirm PIN',
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != true || !context.mounted) return;

    final pin = pinController.text.trim();
    final confirm = confirmController.text.trim();
    if (pin.length < 4 || pin != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PINs must match and be at least 4 digits.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await context.read<SecurityProvider>().setPin(pin);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN set. App will lock on next launch.')),
    );
  }

  Future<void> _removePin(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remove PIN?'),
        content: const Text('Anyone opening the app will have access without a PIN.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<SecurityProvider>().clearPin();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN removed.')),
      );
    }
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SettingsToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingCard),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingsTimePicker extends StatelessWidget {
  final String title;
  final (int, int)? time;
  final Function(int hours, int minutes)? onChanged;

  const _SettingsTimePicker({
    required this.title,
    required this.time,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hours = time?.$1 ?? 21;
    final minutes = time?.$2 ?? 0;
    
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: hours, minute: minutes),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.primary,
                  surface: AppColors.surface,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onChanged?.call(picked.hour, picked.minute);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingCard),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SettingsDropdown extends StatelessWidget {
  final String title;
  final int value;
  final Map<int, String> options;
  final ValueChanged<int>? onChanged;

  const _SettingsDropdown({
    required this.title,
    required this.value,
    required this.options,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingCard),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<int>(
              value: value,
              underline: const SizedBox(),
              dropdownColor: AppColors.surface,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              items: options.entries.map((e) {
                return DropdownMenuItem(value: e.key, child: Text(e.value));
              }).toList(),
              onChanged: (v) => onChanged?.call(v ?? value),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsAction extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingCard),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? color;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color ?? AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.primary,
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
