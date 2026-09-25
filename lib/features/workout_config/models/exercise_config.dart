import 'cadence_info.dart';
import 'work_mode.dart';

/// Configuração individual de um exercício dentro do treino completo
class ExerciseConfig {
  final String id;
  final String name;
  final WorkMode workMode;
  final CadenceInfo cadenceInfo;
  final int workSeconds;
  final int sets;
  final int restBetweenSetsSeconds;
  final int restAfterExerciseSeconds;
  final String? notes;

  const ExerciseConfig({
    required this.id,
    this.name = 'Exercício',
    this.workMode = WorkMode.cadence,
    this.cadenceInfo = const CadenceInfo(
      eccentricSeconds: 3,
      isometric1Seconds: 0,
      concentricSeconds: 3,
      isometric2Seconds: 0,
      targetReps: 8,
    ),
    this.workSeconds = 40,
    this.sets = 3,
    this.restBetweenSetsSeconds = 60,
    this.restAfterExerciseSeconds = 90,
    this.notes,
  });

  /// Tempo de trabalho (sob tensão) em segundos por série
  int get effectiveWorkSeconds {
    if (workMode.isCadence) {
      final total = cadenceInfo.totalWorkSeconds;
      return total > 0 ? total : 48;
    }
    return workSeconds > 0 ? workSeconds : 40;
  }

  /// Duração total de trabalho de todas as séries do exercício
  int get totalWorkDurationSeconds => sets * effectiveWorkSeconds;

  /// Duração total de descansos dentro do exercício (entre séries)
  int get totalRestBetweenSetsSeconds =>
      sets > 1 ? (sets - 1) * restBetweenSetsSeconds : 0;

  /// Duração total deste exercício (trabalho + descansos internos)
  int get totalDurationSeconds =>
      totalWorkDurationSeconds + totalRestBetweenSetsSeconds;

  /// Resumo descritivo da prescrição (ex: "3030 • 8 reps • 3 séries" ou "40s • 3 séries")
  String get prescriptionSummary {
    if (workMode.isCadence) {
      return '${cadenceInfo.code} • ${cadenceInfo.targetReps} reps • $sets ${sets == 1 ? 'série' : 'séries'}';
    } else {
      return '${workSeconds}s • $sets ${sets == 1 ? 'série' : 'séries'}';
    }
  }

  ExerciseConfig copyWith({
    String? id,
    String? name,
    WorkMode? workMode,
    CadenceInfo? cadenceInfo,
    int? workSeconds,
    int? sets,
    int? restBetweenSetsSeconds,
    int? restAfterExerciseSeconds,
    String? notes,
  }) {
    return ExerciseConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      workMode: workMode ?? this.workMode,
      cadenceInfo: cadenceInfo ?? this.cadenceInfo,
      workSeconds: workSeconds ?? this.workSeconds,
      sets: sets ?? this.sets,
      restBetweenSetsSeconds:
          restBetweenSetsSeconds ?? this.restBetweenSetsSeconds,
      restAfterExerciseSeconds:
          restAfterExerciseSeconds ?? this.restAfterExerciseSeconds,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'workMode': workMode.name,
      'cadenceInfo': cadenceInfo.toJson(),
      'workSeconds': workSeconds,
      'sets': sets,
      'restBetweenSetsSeconds': restBetweenSetsSeconds,
      'restAfterExerciseSeconds': restAfterExerciseSeconds,
      'notes': notes,
    };
  }

  factory ExerciseConfig.fromJson(Map<String, dynamic> json) {
    final modeStr = json['workMode'] as String?;
    final mode = modeStr == 'time' ? WorkMode.time : WorkMode.cadence;

    final cadenceMap = json['cadenceInfo'] as Map<String, dynamic>?;
    final cadence = cadenceMap != null
        ? CadenceInfo.fromJson(cadenceMap)
        : const CadenceInfo();

    return ExerciseConfig(
      id: json['id'] as String? ?? 'ex_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Exercício',
      workMode: mode,
      cadenceInfo: cadence,
      workSeconds: json['workSeconds'] as int? ?? 40,
      sets: json['sets'] as int? ?? 3,
      restBetweenSetsSeconds: json['restBetweenSetsSeconds'] as int? ?? 60,
      restAfterExerciseSeconds: json['restAfterExerciseSeconds'] as int? ?? 90,
      notes: json['notes'] as String?,
    );
  }
}
