import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../workout_execution/presentation/screens/workout_execution_screen.dart';
import '../../models/workout_phase.dart';
import '../../providers/workout_config_provider.dart';
import '../widgets/config_field_card.dart';
import '../widgets/dynamic_summary_bar.dart';
import '../widgets/exercise_card.dart';
import '../widgets/preset_selector_sheet.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/weekday_schedule_bar.dart';

class WorkoutConfigScreen extends ConsumerStatefulWidget {
  const WorkoutConfigScreen({super.key});

  @override
  ConsumerState<WorkoutConfigScreen> createState() =>
      _WorkoutConfigScreenState();
}

class _WorkoutConfigScreenState extends ConsumerState<WorkoutConfigScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: ref.read(workoutConfigProvider).name,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = ref.watch(workoutConfigProvider);
    final notifier = ref.read(workoutConfigProvider.notifier);

    if (_nameController.text != config.name) {
      _nameController.text = config.name;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.timer_rounded,
                color: AppColors.brandPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'TensionTimer',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Configurações de Som e Vibração',
          onPressed: () => SettingsDialog.show(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmarks_outlined),
            tooltip: 'Rotinas & Presets',
            onPressed: () => PresetSelectorSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Restaurar Padrão',
            onPressed: () {
              notifier.resetToDefault();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configurações restauradas para o padrão!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Resumo Dinâmico Fixo no Topo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DynamicSummaryBar(config: config),
          ),

          // Lista de Configuração do Treino
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // 1. Barra de Cronograma Semanal (Seg, Ter, Qua, Qui, Sex, Sáb, Dom)
                const WeekdayScheduleBar(),

                // 2. Nome do Treino Geral
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkCardElevated
                        : AppColors.lightCardElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fitness_center_rounded,
                          color: AppColors.brandPrimary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nome do Treino (ex: Peito & Bíceps)',
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: notifier.setWorkoutName,
                        ),
                      ),
                      const Icon(Icons.edit_rounded, size: 16, color: Colors.grey),
                    ],
                  ),
                ),

                // 3. Prepare (Preparação Inicial Geral)
                ConfigFieldCard(
                  title: 'Preparação Inicial (Prepare)',
                  subtitle: 'Tempo antes de iniciar o 1º exercício',
                  value: config.prepareSeconds,
                  isDurationSeconds: true,
                  icon: WorkoutPhase.prepare.icon,
                  themeColor: WorkoutPhase.prepare.primaryColor,
                  step: 5,
                  minValue: 0,
                  maxValue: 300,
                  quickAddSteps: const [5, 10, 15],
                  onChanged: notifier.setPrepareSeconds,
                ),

                const SizedBox(height: 12),

                // 4. Cabeçalho da Seção de Exercícios
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'EXERCÍCIOS DO TREINO (${config.exercises.length})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => notifier.addExercise(),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Adicionar'),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: AppColors.brandPrimary,
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // 5. Lista de Exercícios (Cards Expansíveis)
                ...List.generate(config.exercises.length, (index) {
                  final ex = config.exercises[index];
                  return ExerciseCard(
                    key: ValueKey(ex.id),
                    index: index + 1,
                    totalExercises: config.exercises.length,
                    exercise: ex,
                    onChanged: notifier.updateExercise,
                    onDuplicate: () => notifier.duplicateExercise(ex.id),
                    onDelete: () => notifier.removeExercise(ex.id),
                  );
                }),

                // Botão de Adicionar Exercício Grande
                Container(
                  margin: const EdgeInsets.only(top: 4, bottom: 12),
                  child: OutlinedButton.icon(
                    onPressed: () => notifier.addExercise(),
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        size: 20),
                    label: const Text(
                      'ADICIONAR OUTRO EXERCÍCIO',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.brandPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: AppColors.brandPrimary.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                // 6. Cool down (Volta à Calma Final Geral)
                ConfigFieldCard(
                  title: 'Volta à Calma Final (Cool down)',
                  subtitle: 'Alongamento e relaxamento ao término de tudo',
                  value: config.coolDownSeconds,
                  isDurationSeconds: true,
                  icon: WorkoutPhase.coolDown.icon,
                  themeColor: WorkoutPhase.coolDown.primaryColor,
                  step: 5,
                  minValue: 0,
                  maxValue: 600,
                  quickAddSteps: const [10, 30, 60],
                  onChanged: notifier.setCoolDownSeconds,
                ),

                const SizedBox(height: 80), // Espaço para o rodapé fixo
              ],
            ),
          ),
        ],
      ),

      // Rodapé Fixo com Botão START e Presets
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Botão Presets
            OutlinedButton.icon(
              onPressed: () => PresetSelectorSheet.show(context),
              icon: const Icon(Icons.list_alt_rounded, size: 20),
              label: const Text('Presets'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Botão Principal START
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => WorkoutExecutionScreen.start(context, config),
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                label: const Text(
                  'INICIAR TREINO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 4,
                  shadowColor: AppColors.brandPrimary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
