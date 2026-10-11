import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../models/exercise_config.dart';
import 'exercise_config_dialog.dart';

/// Seção com listagem (ListView) de todos os exercícios do treino.
/// Cada item exibe um resumo compacto e elegante dos parâmetros.
/// Ao clicar em qualquer exercício, uma caixa de diálogo é aberta
/// para ajustar velocidade/cadência, séries, tempo de descanso, etc.
class ExerciseListSection extends StatelessWidget {
  final List<ExerciseConfig> exercises;
  final ValueChanged<ExerciseConfig> onExerciseChanged;
  final ValueChanged<String> onDuplicateExercise;
  final ValueChanged<String> onDeleteExercise;
  final void Function(int oldIndex, int newIndex)? onReorderExercise;
  final VoidCallback onAddExercise;

  const ExerciseListSection({
    super.key,
    required this.exercises,
    required this.onExerciseChanged,
    required this.onDuplicateExercise,
    required this.onDeleteExercise,
    this.onReorderExercise,
    required this.onAddExercise,
  });

  void _openConfigDialog(BuildContext context, ExerciseConfig ex, int index) {
    ExerciseConfigDialog.show(
      context: context,
      exercise: ex,
      index: index,
      onSave: onExerciseChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = exercises.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cabeçalho da Seção de Exercícios
        _buildSectionHeader(context, isDark, total),

        const SizedBox(height: 10),

        // Lista de Exercícios (Cards compactos e clicáveis)
        if (total == 0)
          _buildEmptyState(context, isDark)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: total,
            itemBuilder: (context, index) {
              final ex = exercises[index];
              return _buildExerciseItemCard(
                context: context,
                exercise: ex,
                index: index + 1,
                total: total,
                isDark: isDark,
              );
            },
          ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, bool isDark, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.fitness_center_rounded,
                size: 17, color: AppColors.brandPrimary),
            const SizedBox(width: 8),
            Text(
              'EXERCÍCIOS DO TREINO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.brandPrimary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '$total ${total == 1 ? 'exercício' : 'exercícios'}',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandPrimary,
                ),
              ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: onAddExercise,
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text(
            'Novo',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.brandPrimary,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseItemCard({
    required BuildContext context,
    required ExerciseConfig exercise,
    required int index,
    required int total,
    required bool isDark,
  }) {
    final isCadence = exercise.workMode.isCadence;
    final cadence = exercise.cadenceInfo;
    final totalDuration = Duration(seconds: exercise.totalDurationSeconds);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openConfigDialog(context, exercise, index),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Topo do Card: Número, Nome e Badge do Modo
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.brandPrimary.withValues(alpha: 0.4),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$index',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.lightTextPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: isCadence
                                      ? AppColors.work.withValues(alpha: 0.12)
                                      : AppColors.brandSecondary
                                          .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  isCadence ? 'Cadência TUT' : 'Tempo Fixo',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isCadence
                                        ? AppColors.work
                                        : AppColors.brandSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Duração: ${DurationFormatter.format(totalDuration)}',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Botão de Configurar com Ícone de Ajustes
                    FilledButton.tonalIcon(
                      onPressed: () =>
                          _openConfigDialog(context, exercise, index),
                      icon: const Icon(Icons.tune_rounded, size: 15),
                      label: const Text(
                        'Ajustar',
                        style: TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.w800),
                      ),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        backgroundColor:
                            AppColors.brandPrimary.withValues(alpha: 0.15),
                        foregroundColor: AppColors.brandPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Linha de Parâmetros Compactos (Velocidade, Séries, Descansos)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkCardElevated
                        : AppColors.lightCardElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Velocidade / Cadência
                      Expanded(
                        child: _buildParamMetric(
                          icon: Icons.speed_rounded,
                          iconColor: isCadence
                              ? AppColors.work
                              : AppColors.brandSecondary,
                          label: isCadence ? 'Velocidade' : 'Trabalho',
                          value: isCadence
                              ? cadence.code
                              : '${exercise.workSeconds}s',
                          isDark: isDark,
                        ),
                      ),
                      _buildDivider(isDark),

                      // Repetições & Séries
                      Expanded(
                        child: _buildParamMetric(
                          icon: Icons.repeat_rounded,
                          iconColor: AppColors.brandPrimary,
                          label: 'Prescrição',
                          value: isCadence
                              ? '${cadence.targetReps} reps • ${exercise.sets}x'
                              : '${exercise.sets} séries',
                          isDark: isDark,
                        ),
                      ),
                      _buildDivider(isDark),

                      // Descanso entre séries
                      Expanded(
                        child: _buildParamMetric(
                          icon: Icons.bedtime_outlined,
                          iconColor: AppColors.restBetweenSets,
                          label: 'Descanso',
                          value: '${exercise.restBetweenSetsSeconds}s',
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ),

                // Rodapé do Card com Ações Secundárias e Dica de Clique
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.touch_app_outlined,
                              size: 13, color: Colors.grey),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Clique para configurar',
                              style: TextStyle(
                                fontSize: 10.5,
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
                    const SizedBox(width: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onReorderExercise != null && index > 1)
                          IconButton(
                            icon: const Icon(Icons.arrow_upward_rounded,
                                size: 15),
                            tooltip: 'Mover para cima',
                            constraints: const BoxConstraints(
                                minWidth: 26, minHeight: 26),
                            padding: const EdgeInsets.all(3),
                            visualDensity: VisualDensity.compact,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            onPressed: () =>
                                onReorderExercise!(index - 1, index - 2),
                          ),
                        if (onReorderExercise != null && index < total)
                          IconButton(
                            icon: const Icon(Icons.arrow_downward_rounded,
                                size: 15),
                            tooltip: 'Mover para baixo',
                            constraints: const BoxConstraints(
                                minWidth: 26, minHeight: 26),
                            padding: const EdgeInsets.all(3),
                            visualDensity: VisualDensity.compact,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            onPressed: () =>
                                onReorderExercise!(index - 1, index + 1),
                          ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 15),
                          tooltip: 'Duplicar Exercício',
                          constraints:
                              const BoxConstraints(minWidth: 26, minHeight: 26),
                          padding: const EdgeInsets.all(3),
                          visualDensity: VisualDensity.compact,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          onPressed: () => onDuplicateExercise(exercise.id),
                        ),
                        if (total > 1)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 16, color: AppColors.rest),
                            tooltip: 'Remover Exercício',
                            constraints: const BoxConstraints(
                                minWidth: 26, minHeight: 26),
                            padding: const EdgeInsets.all(3),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => onDeleteExercise(exercise.id),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParamMetric({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 24,
      width: 1,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.fitness_center_rounded,
              size: 40, color: Colors.grey),
          const SizedBox(height: 10),
          const Text(
            'Nenhum exercício configurado',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Adicione o primeiro exercício para iniciar o treino',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onAddExercise,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Adicionar Exercício'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
