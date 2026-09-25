import 'cadence_info.dart';
import 'workout_phase.dart';

/// Representa um passo concreto na linha do tempo executável do treino
class IntervalStep {
  final String id;
  final WorkoutPhase phase;
  final Duration duration;
  final int exerciseIndex;
  final int totalExercises;
  final String exerciseName;
  final int setIndex;
  final int totalSets;
  final int cycleIndex;
  final int totalCycles;
  final String title;
  final String? description;
  final CadenceInfo? cadence;

  const IntervalStep({
    required this.id,
    required this.phase,
    required this.duration,
    this.exerciseIndex = 1,
    this.totalExercises = 1,
    this.exerciseName = '',
    required this.setIndex,
    required this.totalSets,
    this.cycleIndex = 1,
    this.totalCycles = 1,
    required this.title,
    this.description,
    this.cadence,
  });

  /// Duração em segundos inteiros
  int get durationSeconds => duration.inSeconds;

  /// Indica se este passo possui cadência de repetições ativa
  bool get hasCadence =>
      phase == WorkoutPhase.work &&
      cadence != null &&
      cadence!.repDurationSeconds > 0 &&
      cadence!.targetReps > 0;

  /// Retorna o rótulo de progresso do exercício (ex: "Exercício 1 de 4")
  String get exerciseProgressLabel => 'Exercício $exerciseIndex de $totalExercises';

  /// Retorna o rótulo de progresso da série (ex: "Série 2 de 5")
  String get setProgressLabel => 'Série $setIndex de $totalSets';

  /// Retorna o rótulo de progresso do ciclo (ex: "Ciclo 1 de 3")
  String get cycleProgressLabel => 'Ciclo $cycleIndex de $totalCycles';

  IntervalStep copyWith({
    String? id,
    WorkoutPhase? phase,
    Duration? duration,
    int? exerciseIndex,
    int? totalExercises,
    String? exerciseName,
    int? setIndex,
    int? totalSets,
    int? cycleIndex,
    int? totalCycles,
    String? title,
    String? description,
    CadenceInfo? cadence,
  }) {
    return IntervalStep(
      id: id ?? this.id,
      phase: phase ?? this.phase,
      duration: duration ?? this.duration,
      exerciseIndex: exerciseIndex ?? this.exerciseIndex,
      totalExercises: totalExercises ?? this.totalExercises,
      exerciseName: exerciseName ?? this.exerciseName,
      setIndex: setIndex ?? this.setIndex,
      totalSets: totalSets ?? this.totalSets,
      cycleIndex: cycleIndex ?? this.cycleIndex,
      totalCycles: totalCycles ?? this.totalCycles,
      title: title ?? this.title,
      description: description ?? this.description,
      cadence: cadence ?? this.cadence,
    );
  }

  @override
  String toString() {
    return 'IntervalStep(phase: ${phase.name}, ex: $exerciseIndex/$totalExercises ($exerciseName), set: $setIndex/$totalSets, duration: ${duration.inSeconds}s, cadence: ${cadence?.code})';
  }
}
