import 'cadence_info.dart';
import 'exercise_config.dart';
import 'work_mode.dart';
import 'workout_config.dart';

/// Modelo para rotinas e presets salvos com múltiplos exercícios e agendamento por dia da semana
class WorkoutPreset {
  final String id;
  final String name;
  final String description;
  final String iconEmoji;
  final WorkoutConfig config;
  final bool isDefault;
  final List<int> scheduledDays; // 1 = Segunda, 2 = Terça, ..., 7 = Domingo
  final DateTime createdAt;

  const WorkoutPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.config,
    this.isDefault = false,
    this.scheduledDays = const [],
    required this.createdAt,
  });

  /// Nomes curtos dos dias da semana
  static const Map<int, String> dayShortNames = {
    1: 'Seg',
    2: 'Ter',
    3: 'Qua',
    4: 'Qui',
    5: 'Sex',
    6: 'Sáb',
    7: 'Dom',
  };

  /// Nomes completos dos dias da semana
  static const Map<int, String> dayFullNames = {
    1: 'Segunda-feira',
    2: 'Terça-feira',
    3: 'Quarta-feira',
    4: 'Quinta-feira',
    5: 'Sexta-feira',
    6: 'Sábado',
    7: 'Domingo',
  };

  /// Formata os dias agendados em texto legível (ex: "Seg, Qui" ou "Terça-feira")
  String get scheduledDaysFormatted {
    if (scheduledDays.isEmpty) return 'Livre / Sob Demanda';
    if (scheduledDays.length == 7) return 'Todos os dias';
    final sorted = List<int>.from(scheduledDays)..sort();
    return sorted.map((d) => dayShortNames[d] ?? '').where((s) => s.isNotEmpty).join(', ');
  }

  /// Verifica se o preset está agendado para o dia da semana fornecido (1 a 7)
  bool isScheduledForDay(int weekday) {
    return scheduledDays.contains(weekday);
  }

  /// Presets oficiais de fábrica baseados em rotinas reais de musculação divididas por dia
  static List<WorkoutPreset> get defaultPresets {
    final now = DateTime(2026, 1, 1);
    return [
      // Preset 1: Segunda & Quinta (Peito & Bíceps TUT)
      WorkoutPreset(
        id: 'preset_peito_biceps_tut',
        name: 'Peito & Bíceps TUT',
        description:
            'Supino 3030 (8 reps, 2s), Inclinado 2020 (10 reps, 2s), Crucifixo 2020 (20 reps, 2s) e Rosca Bíceps (40s, 3s).',
        iconEmoji: '💪',
        isDefault: true,
        scheduledDays: const [1, 4], // Segunda (1) e Quinta (4)
        createdAt: now,
        config: const WorkoutConfig(
          id: 'config_peito_biceps',
          name: 'Peito & Bíceps TUT',
          prepareSeconds: 10,
          coolDownSeconds: 30,
          exercises: [
            ExerciseConfig(
              id: 'ex_supino_reto',
              name: 'Supino Reto',
              workMode: WorkMode.cadence,
              cadenceInfo: CadenceInfo(
                eccentricSeconds: 3,
                isometric1Seconds: 0,
                concentricSeconds: 3,
                isometric2Seconds: 0,
                targetReps: 8,
              ),
              sets: 2,
              restBetweenSetsSeconds: 60,
              restAfterExerciseSeconds: 90,
            ),
            ExerciseConfig(
              id: 'ex_supino_inc',
              name: 'Supino Inclinado',
              workMode: WorkMode.cadence,
              cadenceInfo: CadenceInfo(
                eccentricSeconds: 2,
                isometric1Seconds: 0,
                concentricSeconds: 2,
                isometric2Seconds: 0,
                targetReps: 10,
              ),
              sets: 2,
              restBetweenSetsSeconds: 60,
              restAfterExerciseSeconds: 90,
            ),
            ExerciseConfig(
              id: 'ex_crucifixo',
              name: 'Crucifixo',
              workMode: WorkMode.cadence,
              cadenceInfo: CadenceInfo(
                eccentricSeconds: 2,
                isometric1Seconds: 0,
                concentricSeconds: 2,
                isometric2Seconds: 0,
                targetReps: 20,
              ),
              sets: 2,
              restBetweenSetsSeconds: 60,
              restAfterExerciseSeconds: 90,
            ),
            ExerciseConfig(
              id: 'ex_biceps',
              name: 'Rosca Bíceps',
              workMode: WorkMode.time,
              workSeconds: 40,
              sets: 3,
              restBetweenSetsSeconds: 45,
              restAfterExerciseSeconds: 0,
            ),
          ],
        ),
      ),

      // Preset 2: Terça & Sexta (Pernas Hipertrofia TUT)
      WorkoutPreset(
        id: 'preset_pernas_tut',
        name: 'Pernas Hipertrofia TUT',
        description:
            'Agachamento Livre (3030, 8 reps, 3s), Leg Press (4020, 10 reps, 3s) e Cadeira Extensora (45s isométrica, 3s).',
        iconEmoji: '🦵',
        isDefault: true,
        scheduledDays: const [2, 5], // Terça (2) e Sexta (5)
        createdAt: now,
        config: const WorkoutConfig(
          id: 'config_pernas_tut',
          name: 'Pernas Hipertrofia TUT',
          prepareSeconds: 15,
          coolDownSeconds: 60,
          exercises: [
            ExerciseConfig(
              id: 'ex_agachamento',
              name: 'Agachamento Livre',
              workMode: WorkMode.cadence,
              cadenceInfo: CadenceInfo(
                eccentricSeconds: 3,
                isometric1Seconds: 0,
                concentricSeconds: 3,
                isometric2Seconds: 0,
                targetReps: 8,
              ),
              sets: 3,
              restBetweenSetsSeconds: 90,
              restAfterExerciseSeconds: 120,
            ),
            ExerciseConfig(
              id: 'ex_leg_press',
              name: 'Leg Press 45°',
              workMode: WorkMode.cadence,
              cadenceInfo: CadenceInfo(
                eccentricSeconds: 4,
                isometric1Seconds: 0,
                concentricSeconds: 2,
                isometric2Seconds: 0,
                targetReps: 10,
              ),
              sets: 3,
              restBetweenSetsSeconds: 90,
              restAfterExerciseSeconds: 120,
            ),
            ExerciseConfig(
              id: 'ex_extensora',
              name: 'Cadeira Extensora',
              workMode: WorkMode.time,
              workSeconds: 45,
              sets: 3,
              restBetweenSetsSeconds: 60,
              restAfterExerciseSeconds: 0,
            ),
          ],
        ),
      ),

      // Preset 3: Quarta & Sábado (Costas & Tríceps Densidade)
      WorkoutPreset(
        id: 'preset_costas_triceps',
        name: 'Costas & Tríceps Densidade',
        description:
            'Puxada Alta (3121, 8 reps, 3s), Remada Curvada (2020, 10 reps, 3s) e Tríceps Corda (3030, 12 reps, 3s).',
        iconEmoji: '🔥',
        isDefault: true,
        scheduledDays: const [3, 6], // Quarta (3) e Sábado (6)
        createdAt: now,
        config: const WorkoutConfig(
          id: 'config_costas_triceps',
          name: 'Costas & Tríceps Densidade',
          prepareSeconds: 10,
          coolDownSeconds: 30,
          exercises: [
            ExerciseConfig(
              id: 'ex_puxada_alta',
              name: 'Puxada Alta',
              workMode: WorkMode.cadence,
              cadenceInfo: CadenceInfo(
                eccentricSeconds: 3,
                isometric1Seconds: 1,
                concentricSeconds: 2,
                isometric2Seconds: 1,
                targetReps: 8,
              ),
              sets: 3,
              restBetweenSetsSeconds: 60,
              restAfterExerciseSeconds: 90,
            ),
            ExerciseConfig(
              id: 'ex_remada_curvada',
              name: 'Remada Curvada',
              workMode: WorkMode.cadence,
              cadenceInfo: CadenceInfo(
                eccentricSeconds: 2,
                isometric1Seconds: 0,
                concentricSeconds: 2,
                isometric2Seconds: 0,
                targetReps: 10,
              ),
              sets: 3,
              restBetweenSetsSeconds: 60,
              restAfterExerciseSeconds: 90,
            ),
            ExerciseConfig(
              id: 'ex_triceps_corda',
              name: 'Tríceps Corda',
              workMode: WorkMode.cadence,
              cadenceInfo: CadenceInfo(
                eccentricSeconds: 3,
                isometric1Seconds: 0,
                concentricSeconds: 3,
                isometric2Seconds: 0,
                targetReps: 12,
              ),
              sets: 3,
              restBetweenSetsSeconds: 45,
              restAfterExerciseSeconds: 0,
            ),
          ],
        ),
      ),

      // Preset 4: Domingo (Circuito Funcional HIIT & Core)
      WorkoutPreset(
        id: 'preset_funcional_hiit',
        name: 'Circuito Funcional & Core',
        description:
            'Polichinelo (45s, 3s), Prancha Abdominal (40s, 3s) e Burpees (30s, 3s).',
        iconEmoji: '⚡',
        isDefault: true,
        scheduledDays: const [7], // Domingo (7)
        createdAt: now,
        config: const WorkoutConfig(
          id: 'config_funcional',
          name: 'Circuito Funcional',
          prepareSeconds: 15,
          coolDownSeconds: 45,
          exercises: [
            ExerciseConfig(
              id: 'ex_polichinelo',
              name: 'Polichinelos',
              workMode: WorkMode.time,
              workSeconds: 45,
              sets: 3,
              restBetweenSetsSeconds: 30,
              restAfterExerciseSeconds: 60,
            ),
            ExerciseConfig(
              id: 'ex_prancha',
              name: 'Prancha Abdominal',
              workMode: WorkMode.time,
              workSeconds: 40,
              sets: 3,
              restBetweenSetsSeconds: 30,
              restAfterExerciseSeconds: 60,
            ),
            ExerciseConfig(
              id: 'ex_burpees',
              name: 'Burpees',
              workMode: WorkMode.time,
              workSeconds: 30,
              sets: 3,
              restBetweenSetsSeconds: 45,
              restAfterExerciseSeconds: 0,
            ),
          ],
        ),
      ),
    ];
  }

  WorkoutPreset copyWith({
    String? id,
    String? name,
    String? description,
    String? iconEmoji,
    WorkoutConfig? config,
    bool? isDefault,
    List<int>? scheduledDays,
    DateTime? createdAt,
  }) {
    return WorkoutPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      config: config ?? this.config,
      isDefault: isDefault ?? this.isDefault,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconEmoji': iconEmoji,
      'config': config.toJson(),
      'isDefault': isDefault,
      'scheduledDays': scheduledDays,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WorkoutPreset.fromJson(Map<String, dynamic> json) {
    final daysList = json['scheduledDays'] as List<dynamic>?;
    final scheduledDays = daysList != null
        ? daysList.map((e) => (e as num).toInt()).toList()
        : const <int>[];

    return WorkoutPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      iconEmoji: json['iconEmoji'] as String? ?? '⏱️',
      config: WorkoutConfig.fromJson(json['config'] as Map<String, dynamic>),
      isDefault: json['isDefault'] as bool? ?? false,
      scheduledDays: scheduledDays,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
