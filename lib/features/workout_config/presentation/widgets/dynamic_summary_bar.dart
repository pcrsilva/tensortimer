import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../models/workout_config.dart';

class DynamicSummaryBar extends StatelessWidget {
  final WorkoutConfig config;

  const DynamicSummaryBar({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardElevated : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            context: context,
            icon: Icons.timer_outlined,
            iconColor: AppColors.brandPrimary,
            title: 'Tempo Total',
            value: DurationFormatter.format(config.totalDuration),
            highlight: true,
          ),
          _buildDivider(isDark),
          _buildSummaryItem(
            context: context,
            icon: Icons.fitness_center_rounded,
            iconColor: AppColors.prepare,
            title: 'Exercícios',
            value: '${config.totalExercises}',
            subtitle: config.totalExercises == 1 ? 'exercício' : 'exercícios',
          ),
          _buildDivider(isDark),
          _buildSummaryItem(
            context: context,
            icon: Icons.repeat_rounded,
            iconColor: AppColors.restBetweenSets,
            title: 'Séries Totais',
            value: '${config.totalSets}',
            subtitle: '${config.totalIntervals} blocos',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    String? subtitle,
    bool highlight = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 20 : 18,
              fontWeight: FontWeight.w900,
              color: highlight
                  ? AppColors.brandPrimary
                  : (isDark ? Colors.white : AppColors.lightTextPrimary),
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 32,
      width: 1,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }
}
