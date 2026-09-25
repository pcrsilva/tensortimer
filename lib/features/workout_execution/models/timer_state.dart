import '../../workout_config/models/interval_step.dart';
import '../../workout_config/models/workout_phase.dart';
import 'cadence_progress.dart';

enum WorkoutTimerStatus {
  idle,
  running,
  paused,
  completed;

  bool get isRunning => this == WorkoutTimerStatus.running;
  bool get isPaused => this == WorkoutTimerStatus.paused;
  bool get isCompleted => this == WorkoutTimerStatus.completed;
  bool get isIdle => this == WorkoutTimerStatus.idle;
}

/// Estado imutável da execução do temporizador
class WorkoutTimerState {
  final WorkoutTimerStatus status;
  final List<IntervalStep> timeline;
  final int currentStepIndex;
  final Duration stepElapsed;
  final Duration totalElapsed;

  const WorkoutTimerState({
    required this.status,
    required this.timeline,
    required this.currentStepIndex,
    required this.stepElapsed,
    required this.totalElapsed,
  });

  factory WorkoutTimerState.initial(List<IntervalStep> timeline) {
    return WorkoutTimerState(
      status: WorkoutTimerStatus.idle,
      timeline: timeline,
      currentStepIndex: 0,
      stepElapsed: Duration.zero,
      totalElapsed: Duration.zero,
    );
  }

  /// Passo atual em execução
  IntervalStep? get currentStep {
    if (timeline.isEmpty || currentStepIndex >= timeline.length) {
      return null;
    }
    return timeline[currentStepIndex];
  }

  /// Próximo passo após o atual
  IntervalStep? get nextStep {
    if (currentStepIndex + 1 < timeline.length) {
      return timeline[currentStepIndex + 1];
    }
    return null;
  }

  /// Fase atual
  WorkoutPhase get currentPhase => currentStep?.phase ?? WorkoutPhase.completed;

  /// Indica se o passo atual tem cadência ativa
  bool get hasCadence => currentStep?.hasCadence == true;

  /// Progresso detalhado da cadência se o passo atual possuir cadência
  CadenceProgress? get cadenceProgress {
    final step = currentStep;
    if (step == null || !step.hasCadence || step.cadence == null) {
      return null;
    }
    return CadenceProgress.calculate(
      cadence: step.cadence!,
      stepElapsed: stepElapsed,
    );
  }

  /// Duração total do passo atual
  Duration get currentStepTotalDuration =>
      currentStep?.duration ?? Duration.zero;

  /// Tempo restante no passo atual
  Duration get stepRemaining {
    final diff = currentStepTotalDuration - stepElapsed;
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Segundos restantes inteiros (arredondado para cima para contagem regressiva visual esportiva)
  int get stepRemainingSeconds {
    if (stepRemaining == Duration.zero) return 0;
    return (stepRemaining.inMilliseconds / 1000).ceil();
  }

  /// Progresso percentual no passo atual (0.0 a 1.0)
  double get stepProgress {
    final totalMs = currentStepTotalDuration.inMilliseconds;
    if (totalMs <= 0) return 1.0;
    final progress = stepElapsed.inMilliseconds / totalMs;
    return progress.clamp(0.0, 1.0);
  }

  /// Duração total de todo o treino compilado
  Duration get totalDuration {
    int totalMs = 0;
    for (final step in timeline) {
      totalMs += step.duration.inMilliseconds;
    }
    return Duration(milliseconds: totalMs);
  }

  /// Tempo restante total de todo o treino
  Duration get totalRemaining {
    final diff = totalDuration - totalElapsed;
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Progresso percentual geral do treino (0.0 a 1.0)
  double get totalProgress {
    final totalMs = totalDuration.inMilliseconds;
    if (totalMs <= 0) return 0.0;
    return (totalElapsed.inMilliseconds / totalMs).clamp(0.0, 1.0);
  }

  WorkoutTimerState copyWith({
    WorkoutTimerStatus? status,
    List<IntervalStep>? timeline,
    int? currentStepIndex,
    Duration? stepElapsed,
    Duration? totalElapsed,
  }) {
    return WorkoutTimerState(
      status: status ?? this.status,
      timeline: timeline ?? this.timeline,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      stepElapsed: stepElapsed ?? this.stepElapsed,
      totalElapsed: totalElapsed ?? this.totalElapsed,
    );
  }
}
