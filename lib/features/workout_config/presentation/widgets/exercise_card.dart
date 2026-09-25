import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../models/cadence_info.dart';
import '../../models/cadence_sub_phase.dart';
import '../../models/exercise_config.dart';
import '../../models/work_mode.dart';

class ExerciseCard extends StatefulWidget {
  final int index;
  final int totalExercises;
  final ExerciseConfig exercise;
  final ValueChanged<ExerciseConfig> onChanged;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const ExerciseCard({
    super.key,
    required this.index,
    required this.totalExercises,
    required this.exercise,
    required this.onChanged,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  bool _isExpanded = true;
  late TextEditingController _nameController;

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
    _nameController = TextEditingController(text: widget.exercise.name);
  }

  @override
  void didUpdateWidget(covariant ExerciseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.name != widget.exercise.name &&
        _nameController.text != widget.exercise.name) {
      _nameController.text = widget.exercise.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _update(ExerciseConfig updated) {
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ex = widget.exercise;
    final isCadence = ex.workMode.isCadence;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            // Header do Exercício
            _buildHeader(context, ex, isDark),

            // Corpo expansível do Exercício
            if (_isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome e sugestões rápidas
                    _buildNameSection(context, ex, isDark),
                    const SizedBox(height: 16),

                    // Toggle de Modo: Cadência TUT vs Tempo Fixo
                    _buildModeToggle(ex, isDark),
                    const SizedBox(height: 16),

                    // Configuração do Modo Escolhido
                    if (isCadence)
                      _buildCadenceConfig(context, ex, isDark)
                    else
                      _buildTimeConfig(context, ex, isDark),

                    const SizedBox(height: 16),

                    // Configuração de Séries e Descansos
                    _buildSetsAndRestConfig(context, ex, isDark),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ExerciseConfig ex, bool isDark) {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Número do Exercício
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.brandPrimary.withValues(alpha: 0.4),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '${widget.index}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.brandPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Nome e Prescrição Resumida
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 6,
                    runSpacing: 3,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ex.workMode.isCadence
                              ? AppColors.work.withValues(alpha: 0.15)
                              : AppColors.brandSecondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ex.prescriptionSummary,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: ex.workMode.isCadence
                                ? AppColors.work
                                : AppColors.brandSecondary,
                          ),
                        ),
                      ),
                      Text(
                        'Total: ${DurationFormatter.format(Duration(seconds: ex.totalDurationSeconds))}',
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

            // Ações rápidas compactas
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  tooltip: 'Duplicar Exercício',
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  padding: const EdgeInsets.all(4),
                  visualDensity: VisualDensity.compact,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  onPressed: widget.onDuplicate,
                ),
                if (widget.totalExercises > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 18, color: AppColors.rest),
                    tooltip: 'Remover Exercício',
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: const EdgeInsets.all(4),
                    visualDensity: VisualDensity.compact,
                    onPressed: widget.onDelete,
                  ),
                const SizedBox(width: 2),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameSection(
      BuildContext context, ExerciseConfig ex, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NOME DO EXERCÍCIO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _nameController,
          style: const TextStyle(fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: 'Ex: Supino Reto, Crucifixo, Rosca...',
            prefixIcon: const Icon(Icons.edit_note_rounded, size: 20),
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
            _update(ex.copyWith(name: val.trim().isEmpty ? 'Exercício' : val));
          },
        ),
        const SizedBox(height: 8),

        // Sugestões Rápidas de Nomes
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _commonExercises.map((sug) {
              final isSelected = ex.name == sug;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(sug),
                  selected: isSelected,
                  visualDensity: VisualDensity.compact,
                  onSelected: (sel) {
                    if (sel) {
                      _nameController.text = sug;
                      _update(ex.copyWith(name: sug));
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

  Widget _buildModeToggle(ExerciseConfig ex, bool isDark) {
    final isCadence = ex.workMode.isCadence;

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
              subtitle: 'Velocidade (Ex: 3030)',
              isSelected: isCadence,
              selectedColor: AppColors.work,
              onTap: () => _update(ex.copyWith(workMode: WorkMode.cadence)),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildToggleOption(
              icon: Icons.timer_outlined,
              title: 'Tempo Fixo',
              subtitle: 'Duração (Ex: 40s)',
              isSelected: !isCadence,
              selectedColor: AppColors.brandSecondary,
              onTap: () => _update(ex.copyWith(workMode: WorkMode.time)),
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
          color: isSelected ? selectedColor.withValues(alpha: 0.15) : Colors.transparent,
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
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? selectedColor : Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9,
                      color: isSelected ? selectedColor.withValues(alpha: 0.8) : Colors.grey,
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

  Widget _buildCadenceConfig(
      BuildContext context, ExerciseConfig ex, bool isDark) {
    final cadence = ex.cadenceInfo;
    const presets = ['3030', '2020', '4020', '3130', '5010'];

    return Container(
      padding: const EdgeInsets.all(12),
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
          // Presets rápidos de cadência
          Row(
            children: [
              const Icon(Icons.bolt_rounded,
                  size: 16, color: AppColors.work),
              const SizedBox(width: 4),
              Text(
                'PADRÕES RÁPIDOS DE VELOCIDADE:',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: presets.map((code) {
              final isSel = cadence.code == code;
              return ActionChip(
                label: Text(code),
                backgroundColor: isSel
                    ? AppColors.work
                    : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isSel ? Colors.white : null,
                ),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  final parsed =
                      CadenceInfo.parse(code, targetReps: cadence.targetReps);
                  _update(ex.copyWith(cadenceInfo: parsed));
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // 4 Dígitos de Velocidade (E - I1 - C - I2)
          Row(
            children: [
              _buildPhaseDigitInput(
                title: '1º Excêntrica',
                subtitle: 'Descida',
                seconds: cadence.eccentricSeconds,
                color: CadenceSubPhase.eccentric.color,
                onChanged: (val) {
                  _update(ex.copyWith(
                    cadenceInfo: cadence.copyWith(eccentricSeconds: val),
                  ));
                },
              ),
              const SizedBox(width: 6),
              _buildPhaseDigitInput(
                title: '2º Isometria 1',
                subtitle: 'Pausa Baixo',
                seconds: cadence.isometric1Seconds,
                color: CadenceSubPhase.isometric1.color,
                onChanged: (val) {
                  _update(ex.copyWith(
                    cadenceInfo: cadence.copyWith(isometric1Seconds: val),
                  ));
                },
              ),
              const SizedBox(width: 6),
              _buildPhaseDigitInput(
                title: '3º Concêntrica',
                subtitle: 'Subida',
                seconds: cadence.concentricSeconds,
                color: CadenceSubPhase.concentric.color,
                onChanged: (val) {
                  _update(ex.copyWith(
                    cadenceInfo: cadence.copyWith(concentricSeconds: val),
                  ));
                },
              ),
              const SizedBox(width: 6),
              _buildPhaseDigitInput(
                title: '4º Isometria 2',
                subtitle: 'Pausa Topo',
                seconds: cadence.isometric2Seconds,
                color: CadenceSubPhase.isometric2.color,
                onChanged: (val) {
                  _update(ex.copyWith(
                    cadenceInfo: cadence.copyWith(isometric2Seconds: val),
                  ));
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Repetições Alvo do Exercício
          _buildCounterRow(
            title: 'Repetições Alvo (Reps)',
            subtitle: 'Quantidade de execuções completas por série',
            value: cadence.targetReps,
            unit: 'reps',
            minValue: 1,
            maxValue: 99,
            color: AppColors.work,
            onChanged: (reps) {
              _update(ex.copyWith(
                cadenceInfo: cadence.copyWith(targetReps: reps),
              ));
            },
          ),
          const SizedBox(height: 10),

          // Banner de Cálculo Matemático do TUT
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.work.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calculate_outlined,
                    size: 16, color: AppColors.work),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '(${cadence.eccentricSeconds}+${cadence.isometric1Seconds}+${cadence.concentricSeconds}+${cadence.isometric2Seconds})s = ${cadence.repDurationSeconds}s/rep × ${cadence.targetReps} reps = ${ex.effectiveWorkSeconds}s sob tensão / série',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.work,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseDigitInput({
    required String title,
    required String subtitle,
    required int seconds,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
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
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 8.5,
                color: color.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSmallStepBtn(
                    icon: Icons.remove,
                    onTap: () => onChanged((seconds - 1).clamp(0, 30)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      '${seconds}s',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ),
                  _buildSmallStepBtn(
                    icon: Icons.add,
                    onTap: () => onChanged((seconds + 1).clamp(0, 30)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStepBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 12),
      ),
    );
  }

  Widget _buildTimeConfig(
      BuildContext context, ExerciseConfig ex, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brandSecondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.brandSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          _buildCounterRow(
            title: 'Tempo de Execução (Work)',
            subtitle: 'Duração contínua de cada série',
            value: ex.workSeconds,
            unit: 'segundos',
            isDuration: true,
            minValue: 5,
            maxValue: 600,
            color: AppColors.brandSecondary,
            onChanged: (sec) => _update(ex.copyWith(workSeconds: sec)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [20, 30, 40, 45, 60].map((s) {
              final isSel = ex.workSeconds == s;
              return ActionChip(
                label: Text('${s}s'),
                backgroundColor: isSel
                    ? AppColors.brandSecondary
                    : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                labelStyle: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: isSel ? Colors.white : null,
                ),
                visualDensity: VisualDensity.compact,
                onPressed: () => _update(ex.copyWith(workSeconds: s)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSetsAndRestConfig(
      BuildContext context, ExerciseConfig ex, bool isDark) {
    return Column(
      children: [
        // Quantidade de Séries
        _buildCounterRow(
          title: 'Séries do Exercício (Sets)',
          subtitle: 'Número de séries a realizar neste exercício',
          value: ex.sets,
          unit: 'séries',
          minValue: 1,
          maxValue: 20,
          color: AppColors.restBetweenSets,
          onChanged: (sets) => _update(ex.copyWith(sets: sets)),
        ),
        const SizedBox(height: 12),

        // Descanso entre séries
        _buildCounterRow(
          title: 'Descanso entre Séries',
          subtitle: 'Intervalo de descanso entre as séries deste exercício',
          value: ex.restBetweenSetsSeconds,
          unit: 'segundos',
          isDuration: true,
          minValue: 0,
          maxValue: 600,
          color: AppColors.rest,
          onChanged: (sec) => _update(ex.copyWith(restBetweenSetsSeconds: sec)),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: [30, 45, 60, 90, 120].map((s) {
            final isSel = ex.restBetweenSetsSeconds == s;
            return ActionChip(
              label: Text('${s}s descanso'),
              backgroundColor: isSel
                  ? AppColors.rest
                  : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSel ? Colors.white : null,
              ),
              visualDensity: VisualDensity.compact,
              onPressed: () => _update(ex.copyWith(restBetweenSetsSeconds: s)),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Descanso / Transição para o Próximo Exercício
        if (widget.index < widget.totalExercises) ...[
          _buildCounterRow(
            title: 'Troca de Exercício (Transição)',
            subtitle: 'Descanso ao concluir este exercício antes do próximo',
            value: ex.restAfterExerciseSeconds,
            unit: 'segundos',
            isDuration: true,
            minValue: 0,
            maxValue: 600,
            color: AppColors.prepare,
            onChanged: (sec) =>
                _update(ex.copyWith(restAfterExerciseSeconds: sec)),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: [0, 60, 90, 120, 180].map((s) {
              final isSel = ex.restAfterExerciseSeconds == s;
              return ActionChip(
                label: Text(s == 0 ? 'Sem pausa' : '${s}s transição'),
                backgroundColor: isSel
                    ? AppColors.prepare
                    : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSel ? Colors.white : null,
                ),
                visualDensity: VisualDensity.compact,
                onPressed: () =>
                    _update(ex.copyWith(restAfterExerciseSeconds: s)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCounterRow({
    required String title,
    required String subtitle,
    required int value,
    required String unit,
    bool isDuration = false,
    required int minValue,
    required int maxValue,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRoundBtn(
              icon: Icons.remove_rounded,
              onTap: () => onChanged((value - (isDuration ? 5 : 1)).clamp(minValue, maxValue)),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 54),
              alignment: Alignment.center,
              child: Text(
                isDuration
                    ? DurationFormatter.format(Duration(seconds: value))
                    : '$value',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ),
            _buildRoundBtn(
              icon: Icons.add_rounded,
              onTap: () => onChanged((value + (isDuration ? 5 : 1)).clamp(minValue, maxValue)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoundBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.brandPrimary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppColors.brandPrimary),
      ),
    );
  }
}
