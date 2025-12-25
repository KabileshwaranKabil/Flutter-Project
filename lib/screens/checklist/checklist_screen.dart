import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';
import '../../providers/daily_log_provider.dart';
import '../../widgets/common_widgets.dart';
import '../settings/settings_screen.dart';

/// Main daily systems checklist screen
class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DailyLogProvider>(
      builder: (context, provider, child) {
        final log = provider.todayLog;
        
        if (provider.isLoading || log == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

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
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.today,
                                    style: Theme.of(context).textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(log.date),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Score indicator
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ScorePill(percentage: log.showUpPercentage),
                                const SizedBox(height: 4),
                                Text(
                                  '${log.completedSystemsCount}/5 systems',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            // Settings button
                            IconButton(
                              icon: const Icon(Icons.settings_outlined),
                              color: AppColors.textSecondary,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SettingsScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingM),
                        // MVD Mode toggle
                        if (context.read<DailyLogProvider>().todayLog?.isMinimumViableDay == false)
                          _buildMvdToggle(context, provider, log.isMinimumViableDay),
                      ],
                    ),
                  ),
                ),
                
                // Systems list
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingScreen),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Learning System
                      SectionHeader(
                        title: AppStrings.systemLearning,
                        color: AppColors.learning,
                        trailing: log.learningCompleted
                            ? const Icon(Icons.check_circle, size: 16, color: AppColors.success)
                            : null,
                      ),
                      CalmCard(
                        child: Column(
                          children: [
                            DsaSelector(
                              value: log.dsaProblems,
                              onChanged: (value) => provider.updateDsaProblems(value),
                            ),
                            const SizedBox(height: AppDimensions.spacingS),
                            MinutesInput(
                              label: AppStrings.aiStudy,
                              value: log.aiStudyMinutes,
                              onChanged: (value) => provider.updateAiStudyMinutes(value),
                            ),
                            const SizedBox(height: AppDimensions.spacingXS),
                            CheckboxItem(
                              label: AppStrings.techReading,
                              value: log.techReading,
                              onChanged: (_) => provider.toggleTechReading(),
                            ),
                            const SizedBox(height: AppDimensions.spacingS),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'What did I learn today?',
                                hintText: 'Capture key takeaways, insights, or links',
                                hintStyle: TextStyle(fontSize: 14),
                              ),
                              maxLines: 3,
                              maxLength: 300,
                              style: const TextStyle(fontSize: 14),
                              controller: TextEditingController(text: log.learningNotes),
                              onChanged: (value) => provider.updateLearningNotes(value),
                            ),
                          ],
                        ),
                      ),

                      // Projects System
                      SectionHeader(
                        title: AppStrings.systemProjects,
                        color: AppColors.projects,
                        trailing: log.projectsCompleted
                            ? const Icon(Icons.check_circle, size: 16, color: AppColors.success)
                            : null,
                      ),
                      CalmCard(
                        child: Column(
                          children: [
                            CheckboxItem(
                              label: AppStrings.workedOnProject,
                              value: log.workedOnProject,
                              onChanged: (_) => provider.toggleWorkedOnProject(),
                            ),
                            const SizedBox(height: AppDimensions.spacingS),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Project name',
                                hintText: 'Which project did you touch?',
                                hintStyle: TextStyle(fontSize: 14),
                              ),
                              maxLines: 1,
                              maxLength: 80,
                              style: const TextStyle(fontSize: 14),
                              controller: TextEditingController(text: log.projectName),
                              onChanged: (value) => provider.updateProjectName(value),
                            ),
                            const SizedBox(height: AppDimensions.spacingS),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Project learnings',
                                hintText: 'What did you learn while building?',
                                hintStyle: TextStyle(fontSize: 14),
                              ),
                              maxLines: 2,
                              maxLength: 250,
                              style: const TextStyle(fontSize: 14),
                              controller: TextEditingController(text: log.todayLearning),
                              onChanged: (value) => provider.updateTodayLearning(value),
                            ),
                            const SizedBox(height: AppDimensions.spacingS),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Developer notebook',
                                hintText: 'Decisions, blockers, links, commands...',
                                hintStyle: TextStyle(fontSize: 14),
                              ),
                              maxLines: 4,
                              maxLength: 500,
                              style: const TextStyle(fontSize: 14),
                              controller: TextEditingController(text: log.projectNotebook),
                              onChanged: (value) => provider.updateProjectNotebook(value),
                            ),
                          ],
                        ),
                      ),

                      // Academics System
                      SectionHeader(
                        title: AppStrings.systemAcademics,
                        color: AppColors.academics,
                        trailing: log.academicsCompleted
                            ? const Icon(Icons.check_circle, size: 16, color: AppColors.success)
                            : null,
                      ),
                      CalmCard(
                        child: Column(
                          children: [
                            // Show weekend alternative on Sat/Sun, lectures on weekdays
                            if (log.isWeekend)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Weekend Alternative Activity',
                                    hintText: 'e.g., Online course, side project, reading...',
                                    hintStyle: TextStyle(fontSize: 14),
                                  ),
                                  maxLines: 2,
                                  maxLength: 100,
                                  style: const TextStyle(fontSize: 14),
                                  controller: TextEditingController(text: log.weekendActivity),
                                  onChanged: (value) => provider.updateWeekendActivity(value),
                                ),
                              )
                            else
                              CheckboxItem(
                                label: AppStrings.attendedLectures,
                                value: log.attendedLectures,
                                onChanged: (_) => provider.toggleAttendedLectures(),
                              ),
                            CheckboxItem(
                              label: AppStrings.notesCompleted,
                              value: log.notesCompleted,
                              onChanged: (_) => provider.toggleNotesCompleted(),
                            ),
                            CheckboxItem(
                              label: AppStrings.pendingTasksZero,
                              value: log.pendingTasksZero,
                              onChanged: (_) => provider.togglePendingTasksZero(),
                            ),
                          ],
                        ),
                      ),

                      // Health System
                      SectionHeader(
                        title: AppStrings.systemHealth,
                        color: AppColors.health,
                        trailing: log.healthCompleted
                            ? const Icon(Icons.check_circle, size: 16, color: AppColors.success)
                            : null,
                      ),
                      CalmCard(
                        child: Column(
                          children: [
                            CheckboxItem(
                              label: AppStrings.sleptWell,
                              value: log.sleptWell,
                              onChanged: (_) => provider.toggleSleptWell(),
                            ),
                            CheckboxItem(
                              label: AppStrings.exercised,
                              value: log.exercised,
                              onChanged: (_) => provider.toggleExercised(),
                            ),
                            CheckboxItem(
                              label: AppStrings.hygiene,
                              value: log.hygieneSelfCare,
                              onChanged: (_) => provider.toggleHygieneSelfCare(),
                            ),
                          ],
                        ),
                      ),

                      // Mind & Discipline System
                      SectionHeader(
                        title: AppStrings.systemMind,
                        color: AppColors.mind,
                        trailing: log.mindCompleted
                            ? const Icon(Icons.check_circle, size: 16, color: AppColors.success)
                            : null,
                      ),
                      CalmCard(
                        child: Column(
                          children: [
                            CheckboxItem(
                              label: AppStrings.meditation,
                              value: log.meditationReflection,
                              onChanged: (_) => provider.toggleMeditationReflection(),
                            ),
                            CheckboxItem(
                              label: AppStrings.distractionRule,
                              value: log.distractionRuleFollowed,
                              onChanged: (_) => provider.toggleDistractionRuleFollowed(),
                            ),
                          ],
                        ),
                      ),

                      // Ideas & Questions
                      SectionHeader(
                        title: 'Ideas & Questions',
                        color: AppColors.primary,
                        trailing: log.wildIdeas.trim().isNotEmpty
                            ? const Icon(Icons.bolt, size: 16, color: AppColors.primary)
                            : null,
                      ),
                      CalmCard(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Capture crazy ideas and unanswered questions',
                            hintText: 'Brain dumps, experiments to try, questions to research',
                            hintStyle: TextStyle(fontSize: 14),
                          ),
                          maxLines: 5,
                          maxLength: 600,
                          style: const TextStyle(fontSize: 14),
                          controller: TextEditingController(text: log.wildIdeas),
                          onChanged: (value) => provider.updateWildIdeas(value),
                        ),
                      ),

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

  Widget _buildMvdToggle(BuildContext context, DailyLogProvider provider, bool isActive) {
    return GestureDetector(
      onTap: () => provider.toggleMinimumViableDay(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.warning.withOpacity(0.15) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.warning : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.battery_saver : Icons.battery_full,
              size: 16,
              color: isActive ? AppColors.warning : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              AppStrings.mvdMode,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.warning : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}
