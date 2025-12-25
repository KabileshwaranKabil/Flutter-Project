import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/daily_log.dart';

/// Bottom sheet showing details for a specific day
class DayDetailSheet extends StatelessWidget {
  final DateTime date;
  final DailyLog? log;

  const DayDetailSheet({
    super.key,
    required this.date,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textHint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingScreen),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _getScoreColor(log?.showUpPercentage ?? 0).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: _getScoreColor(log?.showUpPercentage ?? 0),
                            ),
                          ),
                          Text(
                            _getMonthAbbr(date.month),
                            style: TextStyle(
                              fontSize: 11,
                              color: _getScoreColor(log?.showUpPercentage ?? 0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(date),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          if (log != null)
                            Text(
                              '${log!.completedSystemsCount}/5 systems completed',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          else
                            Text(
                              'No data logged',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: AppColors.textHint,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (log != null)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getScoreColor(log!.showUpPercentage).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${log!.showUpPercentage}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _getScoreColor(log!.showUpPercentage),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              const Divider(color: AppColors.divider, height: 1),
              
              // Content
              Expanded(
                child: log == null
                    ? _buildEmptyState(context)
                    : SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(AppDimensions.paddingScreen),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Learning
                            _buildSystemSection(
                              context,
                              title: AppStrings.systemLearning,
                              color: AppColors.learning,
                              completed: log!.learningCompleted,
                              items: [
                                _buildItem('DSA problems', log!.dsaProblems > 0, value: '${log!.dsaProblems}'),
                                _buildItem('AI/Systems study', log!.aiStudyMinutes > 0, value: '${log!.aiStudyMinutes}m'),
                                _buildItem('Tech reading', log!.techReading),
                                if (log!.learningNotes.isNotEmpty)
                                  _buildTextItem('Learned', log!.learningNotes),
                              ],
                            ),
                            
                            // Projects
                            _buildSystemSection(
                              context,
                              title: AppStrings.systemProjects,
                              color: AppColors.projects,
                              completed: log!.projectsCompleted,
                              items: [
                                _buildItem('Worked on project', log!.workedOnProject),
                                if (log!.projectName.isNotEmpty)
                                  _buildTextItem('Project', log!.projectName),
                                if (log!.todayLearning.isNotEmpty)
                                  _buildTextItem('Learned', log!.todayLearning),
                                if (log!.projectNotebook.isNotEmpty)
                                  _buildTextItem('Notebook', log!.projectNotebook),
                              ],
                            ),
                            
                            // Academics
                            _buildSystemSection(
                              context,
                              title: AppStrings.systemAcademics,
                              color: AppColors.academics,
                              completed: log!.academicsCompleted,
                              items: [
                                if (log!.isWeekend)
                                  _buildTextItem('Weekend alternative', log!.weekendActivity)
                                else
                                  _buildItem('Attended lectures', log!.attendedLectures),
                                _buildItem('Notes completed', log!.notesCompleted),
                                _buildItem('Pending tasks = 0', log!.pendingTasksZero),
                              ],
                            ),
                            
                            // Health
                            _buildSystemSection(
                              context,
                              title: AppStrings.systemHealth,
                              color: AppColors.health,
                              completed: log!.healthCompleted,
                              items: [
                                _buildItem('Slept ≥ 7 hours', log!.sleptWell),
                                _buildItem('Exercise', log!.exercised),
                                _buildItem('Hygiene & self-care', log!.hygieneSelfCare),
                              ],
                            ),
                            
                            // Mind
                            _buildSystemSection(
                              context,
                              title: AppStrings.systemMind,
                              color: AppColors.mind,
                              completed: log!.mindCompleted,
                              items: [
                                _buildItem('Meditation/reflection', log!.meditationReflection),
                                _buildItem('Distraction rule', log!.distractionRuleFollowed),
                              ],
                            ),

                            if (log!.wildIdeas.isNotEmpty) ...[
                              const SizedBox(height: AppDimensions.spacingM),
                              _buildSystemSection(
                                context,
                                title: 'Ideas & Questions',
                                color: AppColors.primary,
                                completed: true,
                                items: [
                                  _buildTextItem('Brain dump', log!.wildIdeas),
                                ],
                              ),
                            ],
                            
                            const SizedBox(height: AppDimensions.spacingL),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 48,
            color: AppColors.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No data for this day',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start tracking to see your progress',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSection(
    BuildContext context, {
    required String title,
    required Color color,
    required bool completed,
    required List<Widget> items,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const Spacer(),
              if (completed)
                const Icon(Icons.check_circle, size: 16, color: AppColors.success),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String label, bool completed, {String? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: completed ? AppColors.success : AppColors.textHint,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: completed ? AppColors.textPrimary : AppColors.textSecondary,
              decoration: completed ? TextDecoration.lineThrough : null,
              decorationColor: AppColors.textHint,
            ),
          ),
          if (value != null && completed) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextItem(String label, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    if (score > 0) return AppColors.error;
    return AppColors.textHint;
  }

  String _formatDate(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
