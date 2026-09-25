import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../models/workout_preset.dart';
import '../../providers/presets_provider.dart';
import '../../providers/workout_config_provider.dart';

class WeekdayScheduleBar extends StatefulWidget {
  const WeekdayScheduleBar({super.key});

  @override
  State<WeekdayScheduleBar> createState() => _WeekdayScheduleBarState();
}

class _WeekdayScheduleBarState extends State<WeekdayScheduleBar> {
  late int _selectedWeekday;

  @override
  void initState() {
    super.initState();
    _selectedWeekday = DateTime.now().weekday; // 1 = Seg, ..., 7 = Dom
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now().weekday;

    return Consumer(
      builder: (context, ref, _) {
        final presets = ref.watch(presetsProvider);
        final activeConfig = ref.watch(workoutConfigProvider);

        // Encontra os treinos agendados para o dia selecionado
        final scheduledForSelectedDay =
            presets.where((p) => p.isScheduledForDay(_selectedWeekday)).toList();

        final isTodaySelected = _selectedWeekday == today;
        final selectedDayName =
            WorkoutPreset.dayFullNames[_selectedWeekday] ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho da barra semanal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded,
                            size: 15, color: AppColors.brandPrimary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'CRONOGRAMA SEMANAL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isTodaySelected) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.brandPrimary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Text(
                        'HOJE',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),

              // Pílulas dos 7 Dias da Semana
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final weekday = index + 1;
                  final isCurrentDay = weekday == today;
                  final isSelected = weekday == _selectedWeekday;
                  final shortName = WorkoutPreset.dayShortNames[weekday] ?? '';

                  // Verifica se tem treino agendado neste dia
                  final hasScheduled =
                      presets.any((p) => p.isScheduledForDay(weekday));

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedWeekday = weekday;
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.brandPrimary
                                : (isCurrentDay
                                    ? AppColors.brandPrimary.withValues(alpha: 0.15)
                                    : (isDark
                                        ? AppColors.darkCardElevated
                                        : AppColors.lightCardElevated)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.brandPrimary
                                  : (isCurrentDay
                                      ? AppColors.brandPrimary
                                      : (isDark
                                          ? AppColors.darkBorder
                                          : AppColors.lightBorder)),
                              width: isCurrentDay ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                shortName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.white
                                      : (isCurrentDay
                                          ? AppColors.brandPrimary
                                          : (isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.lightTextPrimary)),
                                ),
                              ),
                              const SizedBox(height: 3),
                              // Pontinho indicador de treino cadastrado
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: hasScheduled
                                      ? (isSelected
                                          ? Colors.white
                                          : AppColors.brandPrimary)
                                      : Colors.transparent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),

              // Card informativo do treino do dia selecionado
              if (scheduledForSelectedDay.isNotEmpty) ...[
                ...scheduledForSelectedDay.map((preset) {
                  final isLoaded = activeConfig.id == preset.config.id ||
                      activeConfig.name == preset.name;

                  return Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkCardElevated
                          : AppColors.lightCardElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isLoaded
                            ? AppColors.brandPrimary
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                        width: isLoaded ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          preset.iconEmoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      preset.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.lightTextPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isLoaded) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: AppColors.brandPrimary
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'CARREGADO',
                                        style: TextStyle(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.brandPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                '${preset.config.totalExercises} exercícios • ${DurationFormatter.format(preset.config.totalDuration)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLoaded)
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(workoutConfigProvider.notifier)
                                  .loadFromPreset(preset.config);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Treino "${preset.name}" de $selectedDayName carregado!',
                                  ),
                                  backgroundColor: AppColors.brandPrimary,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              visualDensity: VisualDensity.compact,
                              textStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Carregar'),
                          ),
                      ],
                    ),
                  );
                }),
              ] else ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkCardElevated.withValues(alpha: 0.5)
                        : AppColors.lightCardElevated.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 15, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Nenhum treino agendado para $selectedDayName.',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
