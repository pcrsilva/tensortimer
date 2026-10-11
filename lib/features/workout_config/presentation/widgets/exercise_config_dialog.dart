import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../models/cadence_info.dart';
import '../../models/cadence_sub_phase.dart';
import '../../models/exercise_config.dart';
import '../../models/work_mode.dart';

/// Caixa de diálogo modal moderna e intuitiva para configuração completa dos
/// parâmetros de velocidade, cadência TUT, séries e descansos de um exercício.
class ExerciseConfigDialog extends StatefulWidget {
  final ExerciseConfig exercise;
  final int index;
  final ValueChanged<ExerciseConfig> onSave;

  const ExerciseConfigDialog({
    super.key,
    required this.exercise,
    required this.index,
    required this.onSave,
  });

  /// Exibe a caixa de diálogo modal para configuração do exercício
  static Future<void> show({
    required BuildContext context,
    required ExerciseConfig exercise,
    required int index,
    required ValueChanged<ExerciseConfig> onSave,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ExerciseConfigDialog(
        exercise: exercise,
        index: index,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ExerciseConfigDialog> createState() => _ExerciseConfigDialogState();
}

class _ExerciseConfigDialogState extends State<ExerciseConfigDialog> {
  late ExerciseConfig _currentExercise;
  late TextEditingController _nameController;
  late TextEditingController _notesController;

  static const List<String> _commonExercises = [
    'Supino Reto',
    'Supino Inclinado',
    'Crucifixo',
    'Rosca Bíceps',
    'Agachamento',
    'Leg Press',
    'Puxada Alta',
    'Remada Curvada',
    'Tríceps Testa',
    'Tríceps Corda',
    'Elevação Lateral',
    'Desenvolvimento',
    'Prancha',
    'Burpees',
  ];

  @override
  void initState() {
    super.initState();
    _currentExercise = widget.exercise;
    _nameController = TextEditingController(text: widget.exercise.name);
    _notesController = TextEditingController(text: widget.exercise.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final finalName = _nameController.text.trim().isEmpty
        ? 'Exercício ${widget.index}'
        : _nameController.text.trim();
    final finalNotes =
        _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    final updated = _currentExercise.copyWith(
      name: finalName,
      notes: finalNotes,
    );

    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCadence = _currentExercise.workMode.isCadence;
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 540,
          maxHeight: size.height * 0.90,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Cabeçalho do Diálogo
            _buildDialogHeader(isDark),

            const Divider(height: 1),

            // 2. Conteúdo de Configuração com Scroll
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome do Exercício
                    _buildNameSection(isDark),
                    const SizedBox(height: 16),

                    // Modo de Trabalho (Cadência TUT vs Tempo Fixo)
                    _buildModeToggle(isDark),
                    const SizedBox(height: 16),

                    // Velocidade / Cadência TUT ou Tempo Fixo
                    if (isCadence)
                      _buildCadenceSpeedSection(isDark)
                    else
                      _buildFixedTimeSection(isDark),
                    const SizedBox(height: 16),

                    // Séries e Descansos
                    _buildSetsAndRestSection(isDark),
                    const SizedBox(height: 16),

                    // Anotações Opcionais
                    _buildNotesSection(isDark),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            // 3. Rodapé com Resumo Dinâmico e Botões de Ação
            _buildDialogFooter(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.brandPrimary.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              '#${widget.index}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.brandPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configurar Exercício',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Ajuste velocidade, repetições, séries e descansos',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            tooltip: 'Fechar sem salvar',
            visualDensity: VisualDensity.compact,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildNameSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          title: 'NOME DO EXERCÍCIO',
          icon: Icons.edit_note_rounded,
          isDark: isDark,
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _nameController,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Ex: Supino Reto, Crucifixo, Rosca...',
            prefixIcon: const Icon(Icons.fitness_center_rounded, size: 18),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            filled: true,
            fillColor: isDark
                ? AppColors.darkCardElevated
                : AppColors.lightCardElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
          onChanged: (val) {
            setState(() {
              _currentExercise = _currentExercise.copyWith(
                name: val.trim().isEmpty ? 'Exercício ${widget.index}' : val,
              );
            });
          },
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _commonExercises.map((sug) {
              final isSelected = _currentExercise.name == sug;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(sug, style: const TextStyle(fontSize: 11.5)),
                  selected: isSelected,
                  visualDensity: VisualDensity.compact,
                  onSelected: (sel) {
                    if (sel) {
                      _nameController.text = sug;
                      setState(() {
                        _currentExercise = _currentExercise.copyWith(name: sug);
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildModeToggle(bool isDark) {
    final isCadence = _currentExercise.workMode.isCadence;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleOption(
              icon: Icons.speed_rounded,
              title: 'Cadência TUT',
              subtitle: 'Velocidade 4 dígitos (Ex: 3030)',
              isSelected: isCadence,
              selectedColor: AppColors.work,
              onTap: () {
                setState(() {
                  _currentExercise =
                      _currentExercise.copyWith(workMode: WorkMode.cadence);
                });
              },
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildToggleOption(
              icon: Icons.timer_outlined,
              title: 'Tempo Fixo',
              subtitle: 'Duração contínua (Ex: 40s)',
              isSelected: !isCadence,
              selectedColor: AppColors.brandSecondary,
              onTap: () {
                setState(() {
                  _currentExercise =
                      _currentExercise.copyWith(workMode: WorkMode.time);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? selectedColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: selectedColor, width: 1.5)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? selectedColor : Colors.grey,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? selectedColor : Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: isSelected
                          ? selectedColor.withValues(alpha: 0.8)
                          : Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCadenceSpeedSection(bool isDark) {
    final cadence = _currentExercise.cadenceInfo;
    const presets = ['3030', '2020', '4020', '3130', '5010'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.work.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.work.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            title: 'VELOCIDADE DO MOVIMENTO (CADÊNCIA TUT)',
            icon: Icons.speed_rounded,
            color: AppColors.work,
            isDark: isDark,
          ),
          const SizedBox(height: 6),

          // Padrões Rápidos de Velocidade
          Row(
            children: [
              Text(
                'Padrões Rápidos:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: presets.map((code) {
                      final isSel = cadence.code == code;
                      return Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: ActionChip(
                          label: Text(code),
                          backgroundColor: isSel
                              ? AppColors.work
                              : (isDark
                                  ? Colors.white10
                                  : Colors.black.withValues(alpha: 0.05)),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isSel ? Colors.white : null,
                          ),
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            setState(() {
                              _currentExercise = _currentExercise.copyWith(
                                cadenceInfo: CadenceInfo.parse(code,
                                    targetReps: cadence.targetReps),
                              );
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4 Dígitos da Cadência TUT
          Row(
            children: [
              _buildDigitControl(
                title: '1º Excêntrica',
                subtitle: 'Descida',
                seconds: cadence.eccentricSeconds,
                color: CadenceSubPhase.eccentric.color,
                onChanged: (val) {
                  setState(() {
                    _currentExercise = _currentExercise.copyWith(
                      cadenceInfo: cadence.copyWith(eccentricSeconds: val),
                    );
                  });
                },
              ),
              const SizedBox(width: 6),
              _buildDigitControl(
                title: '2º Isometria',
                subtitle: 'Pausa Baixo',
                seconds: cadence.isometric1Seconds,
                color: CadenceSubPhase.isometric1.color,
                onChanged: (val) {
                  setState(() {
                    _currentExercise = _currentExercise.copyWith(
                      cadenceInfo: cadence.copyWith(isometric1Seconds: val),
                    );
                  });
                },
              ),
              const SizedBox(width: 6),
              _buildDigitControl(
                title: '3º Concêntrica',
                subtitle: 'Subida',
                seconds: cadence.concentricSeconds,
                color: CadenceSubPhase.concentric.color,
                onChanged: (val) {
                  setState(() {
                    _currentExercise = _currentExercise.copyWith(
                      cadenceInfo: cadence.copyWith(concentricSeconds: val),
                    );
                  });
                },
              ),
              const SizedBox(width: 6),
              _buildDigitControl(
                title: '4º Isometria',
                subtitle: 'Pausa Cima',
                seconds: cadence.isometric2Seconds,
                color: CadenceSubPhase.isometric2.color,
                onChanged: (val) {
                  setState(() {
                    _currentExercise = _currentExercise.copyWith(
                      cadenceInfo: cadence.copyWith(isometric2Seconds: val),
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Card explicativo do TUT da série
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.work.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 14, color: AppColors.work),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'Código: ${cadence.code} (${cadence.repDurationSeconds}s/rep)',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'TUT: ${cadence.totalWorkSeconds}s/série',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.work,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Meta de Repetições
          _buildNumericRowControl(
            title: 'Repetições por Série',
            subtitle: 'Quantidade de execuções com a cadência acima',
            value: cadence.targetReps,
            unit: 'reps',
            minValue: 1,
            maxValue: 100,
            step: 1,
            color: AppColors.work,
            quickValues: const [6, 8, 10, 12, 15],
            onChanged: (val) {
              setState(() {
                _currentExercise = _currentExercise.copyWith(
                  cadenceInfo: cadence.copyWith(targetReps: val),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDigitControl({
    required String title,
    required String subtitle,
    required int seconds,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 8,
                color: color.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${seconds}s',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: seconds > 0 ? () => onChanged(seconds - 1) : null,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: seconds > 0 ? color.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.remove, size: 12, color: seconds > 0 ? color : Colors.grey),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: seconds < 30 ? () => onChanged(seconds + 1) : null,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, size: 12, color: color),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedTimeSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.brandSecondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.brandSecondary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            title: 'TEMPO DE TRABALHO POR SÉRIE',
            icon: Icons.timer_outlined,
            color: AppColors.brandSecondary,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildNumericRowControl(
            title: 'Duração sob Tensão',
            subtitle: 'Tempo fixo em segundos para cada série',
            value: _currentExercise.workSeconds,
            unit: 's',
            minValue: 5,
            maxValue: 600,
            step: 5,
            color: AppColors.brandSecondary,
            quickValues: const [20, 30, 40, 45, 60],
            onChanged: (val) {
              setState(() {
                _currentExercise = _currentExercise.copyWith(workSeconds: val);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSetsAndRestSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            title: 'SÉRIES & TEMPOS DE DESCANSO',
            icon: Icons.tune_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Número de Séries
          _buildNumericRowControl(
            title: 'Número de Séries',
            subtitle: 'Quantidade de séries para este exercício',
            value: _currentExercise.sets,
            unit: _currentExercise.sets == 1 ? 'série' : 'séries',
            minValue: 1,
            maxValue: 20,
            step: 1,
            color: AppColors.brandPrimary,
            quickValues: const [2, 3, 4, 5],
            onChanged: (val) {
              setState(() {
                _currentExercise = _currentExercise.copyWith(sets: val);
              });
            },
          ),
          const Divider(height: 22),

          // Descanso entre Séries
          _buildNumericRowControl(
            title: 'Descanso entre Séries',
            subtitle: 'Recuperação antes da próxima série do exercício',
            value: _currentExercise.restBetweenSetsSeconds,
            unit: 's',
            minValue: 0,
            maxValue: 600,
            step: 5,
            color: AppColors.restBetweenSets,
            quickValues: const [30, 45, 60, 90, 120],
            onChanged: (val) {
              setState(() {
                _currentExercise =
                    _currentExercise.copyWith(restBetweenSetsSeconds: val);
              });
            },
          ),
          const Divider(height: 22),

          // Descanso Pós-Exercício (Transição)
          _buildNumericRowControl(
            title: 'Descanso Pós-Exercício',
            subtitle: 'Transição e intervalo para o próximo exercício',
            value: _currentExercise.restAfterExerciseSeconds,
            unit: 's',
            minValue: 0,
            maxValue: 600,
            step: 5,
            color: AppColors.rest,
            quickValues: const [0, 30, 60, 90, 120],
            onChanged: (val) {
              setState(() {
                _currentExercise =
                    _currentExercise.copyWith(restAfterExerciseSeconds: val);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          title: 'ANOTAÇÕES & CARGA (OPCIONAL)',
          icon: Icons.notes_rounded,
          isDark: isDark,
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _notesController,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Ex: Halteres 24kg, Banco a 45º, Pegada pronada...',
            prefixIcon: const Icon(Icons.bookmark_border_rounded, size: 18),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            filled: true,
            fillColor: isDark
                ? AppColors.darkCardElevated
                : AppColors.lightCardElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
          onChanged: (val) {
            setState(() {
              _currentExercise = _currentExercise.copyWith(
                notes: val.trim().isEmpty ? null : val,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildNumericRowControl({
    required String title,
    required String subtitle,
    required int value,
    required String unit,
    required int minValue,
    required int maxValue,
    required int step,
    required Color color,
    required List<int> quickValues,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: value > minValue
                      ? () => onChanged((value - step).clamp(minValue, maxValue))
                      : null,
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  color: color,
                  iconSize: 24,
                  visualDensity: VisualDensity.compact,
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 54),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$value $unit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: value < maxValue
                      ? () => onChanged((value + step).clamp(minValue, maxValue))
                      : null,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  color: color,
                  iconSize: 24,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: quickValues.map((qv) {
              final isSel = value == qv;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text('$qv $unit', style: const TextStyle(fontSize: 11)),
                  selected: isSel,
                  selectedColor: color.withValues(alpha: 0.2),
                  visualDensity: VisualDensity.compact,
                  onSelected: (sel) {
                    if (sel) onChanged(qv);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required IconData icon,
    Color? color,
    required bool isDark,
  }) {
    final effectiveColor = color ??
        (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);
    return Row(
      children: [
        Icon(icon, size: 15, color: effectiveColor),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: effectiveColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDialogFooter(bool isDark) {
    final totalDuration =
        Duration(seconds: _currentExercise.totalDurationSeconds);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.hourglass_bottom_rounded,
                    size: 16, color: AppColors.brandPrimary),
                const SizedBox(width: 6),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Duração Total:',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        DurationFormatter.format(totalDuration),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brandPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
