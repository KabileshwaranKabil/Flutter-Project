import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

/// A calm, minimal card component for system groups
class CalmCard extends StatelessWidget {
  final String? title;
  final Color? titleColor;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const CalmCard({
    super.key,
    this.title,
    this.titleColor,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppDimensions.paddingCard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A checkbox item for the checklist
class CheckboxItem extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final bool enabled;

  const CheckboxItem({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChanged?.call(!value) : null,
      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: enabled ? onChanged : null,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: enabled
                      ? (value ? AppColors.textPrimary : AppColors.textSecondary)
                      : AppColors.textHint,
                  decoration: value ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.textHint,
                ),
              ),
            ),
            if (value)
              const Icon(
                Icons.check_circle,
                size: 18,
                color: AppColors.success,
              ),
          ],
        ),
      ),
    );
  }
}

/// A segmented selector for DSA problems count
class DsaSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;

  const DsaSelector({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'DSA practice',
            style: TextStyle(
              fontSize: 15,
              color: value > 0 ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
        _buildOption(0, '0'),
        const SizedBox(width: 8),
        _buildOption(1, '1'),
        const SizedBox(width: 8),
        _buildOption(2, '2+'),
      ],
    );
  }

  Widget _buildOption(int optionValue, String label) {
    final isSelected = value == optionValue;
    return GestureDetector(
      onTap: () => onChanged?.call(optionValue),
      child: Container(
        width: 40,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.background : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// A minutes input field with increment/decrement
class MinutesInput extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int>? onChanged;
  final int step;
  final int max;

  const MinutesInput({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.step = 5,
    this.max = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: value > 0 ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
        _buildButton(Icons.remove, () {
          if (value > 0) {
            onChanged?.call((value - step).clamp(0, max));
          }
        }),
        Container(
          width: 50,
          alignment: Alignment.center,
          child: Text(
            '${value}m',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: value > 0 ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
        _buildButton(Icons.add, () {
          if (value < max) {
            onChanged?.call((value + step).clamp(0, max));
          }
        }),
      ],
    );
  }

  Widget _buildButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}

/// Section header with optional trailing widget
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Color? color;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        right: 4,
        top: AppDimensions.spacingM,
        bottom: AppDimensions.spacingS,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: color ?? AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color ?? AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          if (trailing != null) ...[
            const Spacer(),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Score indicator pill
class ScorePill extends StatelessWidget {
  final int percentage;
  final bool showLabel;

  const ScorePill({
    super.key,
    required this.percentage,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        showLabel ? '$percentage%' : percentage.toString(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getColor() {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 50) return AppColors.warning;
    return AppColors.error;
  }
}
