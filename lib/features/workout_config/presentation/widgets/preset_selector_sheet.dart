import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../models/workout_config.dart';
import '../../models/workout_preset.dart';
import '../../providers/presets_provider.dart';
import '../../providers/workout_config_provider.dart';

class PresetSelectorSheet extends ConsumerStatefulWidget {
  const PresetSelectorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PresetSelectorSheet(),
    );
  }

  @override
  ConsumerState<PresetSelectorSheet> createState() =>
      _PresetSelectorSheetState();
}

class _PresetSelectorSheetState extends ConsumerState<PresetSelectorSheet> {
  int? _filterWeekday; // null = Todos, 1..7 = Dias da semana

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allPresets = ref.watch(presetsProvider);
    final activeConfig = ref.watch(workoutConfigProvider);

    final filteredPresets = _filterWeekday == null
        ? allPresets
        : allPresets
            .where((p) => p.isScheduledForDay(_filterWeekday!))
            .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rotinas & Presets',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark ? Colors.white : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Organize seus treinos por dia da semana',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () =>
                      _showSavePresetDialog(context, ref, activeConfig),
                  icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                  label: const Text('Salvar Atual'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Barra de Filtro por Dia da Semana
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Todos'),
                    selected: _filterWeekday == null,
                    onSelected: (sel) {
                      if (sel) setState(() => _filterWeekday = null);
                    },
                  ),
                  const SizedBox(width: 6),
                  ...List.generate(7, (i) {
                    final day = i + 1;
                    final isSel = _filterWeekday == day;
                    final shortName = WorkoutPreset.dayShortNames[day] ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(shortName),
                        selected: isSel,
                        onSelected: (sel) {
                          setState(() {
                            _filterWeekday = sel ? day : null;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const Divider(height: 12),

          // Lista de Presets
          Expanded(
            child: filteredPresets.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Nenhum treino agendado para ${WorkoutPreset.dayFullNames[_filterWeekday] ?? 'este filtro'}.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPresets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final preset = filteredPresets[index];
                      return _buildPresetTile(context, ref, preset, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetTile(
    BuildContext context,
    WidgetRef ref,
    WorkoutPreset preset,
    bool isDark,
  ) {
    final cfg = preset.config;
    final totalDurationStr = DurationFormatter.format(cfg.totalDuration);

    return InkWell(
      onTap: () {
        ref.read(workoutConfigProvider.notifier).loadFromPreset(cfg);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Treino "${preset.name}" carregado!'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.brandPrimary,
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardElevated : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child:
                  Text(preset.iconEmoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preset.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : AppColors.lightTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (preset.scheduledDays.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.brandSecondary
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.brandSecondary
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            preset.scheduledDaysFormatted,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.brandSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preset.description,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildMiniBadge(
                          Icons.timer_outlined, totalDurationStr, isDark),
                      _buildMiniBadge(
                          Icons.fitness_center_rounded,
                          '${cfg.totalExercises} ${cfg.totalExercises == 1 ? 'exercício' : 'exercícios'}',
                          isDark),
                      _buildMiniBadge(
                          Icons.layers_outlined, '${cfg.totalSets} séries', isDark),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: 18,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              onSelected: (val) {
                if (val == 'duplicate') {
                  ref.read(presetsProvider.notifier).duplicatePreset(preset);
                } else if (val == 'delete') {
                  ref.read(presetsProvider.notifier).deletePreset(preset.id);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy_rounded, size: 16),
                      SizedBox(width: 8),
                      Text('Duplicar'),
                    ],
                  ),
                ),
                if (!preset.isDefault)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 16, color: AppColors.rest),
                        SizedBox(width: 8),
                        Text('Excluir',
                            style: TextStyle(color: AppColors.rest)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBadge(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 11,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  void _showSavePresetDialog(
    BuildContext context,
    WidgetRef ref,
    WorkoutConfig activeConfig,
  ) {
    final nameCtrl = TextEditingController(text: activeConfig.name);
    final descCtrl = TextEditingController();
    String selectedEmoji = '⚡';
    final Set<int> selectedDays = {};

    final emojis = ['⚡', '🔥', '🏋️‍♂️', '🏃‍♂️', '🥊', '⏱️', '🧘‍♂️', '🎯', '💪', '🦵'];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Salvar Rotina / Preset'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Treino',
                        hintText: 'Ex: Treino de Perna TUT',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descrição / Foco (opcional)',
                        hintText: 'Ex: 4 exercícios, foco em TUT 3030',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Ícone:',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: emojis.map((e) {
                        final isSel = e == selectedEmoji;
                        return ChoiceChip(
                          label: Text(e, style: const TextStyle(fontSize: 16)),
                          selected: isSel,
                          onSelected: (_) =>
                              setDialogState(() => selectedEmoji = e),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Dias da Semana Programados:',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: List.generate(7, (i) {
                        final day = i + 1;
                        final isSel = selectedDays.contains(day);
                        final shortName = WorkoutPreset.dayShortNames[day] ?? '';
                        return FilterChip(
                          label: Text(shortName),
                          selected: isSel,
                          onSelected: (sel) {
                            setDialogState(() {
                              if (sel) {
                                selectedDays.add(day);
                              } else {
                                selectedDays.remove(day);
                              }
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isNotEmpty) {
                      ref.read(presetsProvider.notifier).saveCurrentAsPreset(
                            config: activeConfig.copyWith(name: name),
                            name: name,
                            description: descCtrl.text.trim(),
                            iconEmoji: selectedEmoji,
                            scheduledDays: selectedDays.toList()..sort(),
                          );
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Rotina "$name" salva nos seus Presets!'),
                          backgroundColor: AppColors.completed,
                        ),
                      );
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
