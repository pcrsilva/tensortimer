import '../../workout_config/models/cadence_info.dart';
import '../../workout_config/models/cadence_sub_phase.dart';

/// Informações em tempo real do andamento da repetição e fase da cadência TUT
class CadenceProgress {
  final int currentRep;
  final int totalReps;
  final CadenceSubPhase currentSubPhase;

  /// Progresso percentual da subfase atual (0.0 a 1.0)
  final double subPhaseProgress;

  /// Segundos decorridos na subfase atual
  final double subPhaseElapsedSeconds;

  /// Duração total da subfase atual em segundos
  final int subPhaseTotalSeconds;

  /// Número exibido no visor gigante de cadência:
  /// - Na Excêntrica (Descida): sobe de 0 até E (ex: 0, 1, 2, 3)
  /// - Na Isometria 1 (Pausa Inf.): tempo de pausa
  /// - Na Concêntrica (Subida): desce de C até 0 (ex: 3, 2, 1, 0)
  /// - Na Isometria 2 (Pico Sup.): tempo de pico
  final int displaySecond;

  /// Indicador visual: true se a contagem está subindo (0->E), false se descendo (C->0)
  final bool isCountingUp;

  const CadenceProgress({
    required this.currentRep,
    required this.totalReps,
    required this.currentSubPhase,
    required this.subPhaseProgress,
    required this.subPhaseElapsedSeconds,
    required this.subPhaseTotalSeconds,
    required this.displaySecond,
    required this.isCountingUp,
  });

  /// Calcula o progresso exato da cadência a partir dos milissegundos decorridos no passo
  static CadenceProgress calculate({
    required CadenceInfo cadence,
    required Duration stepElapsed,
  }) {
    final repDurationSec = cadence.repDurationSeconds;
    final totalReps = cadence.targetReps;
    if (repDurationSec <= 0 || totalReps <= 0) {
      return const CadenceProgress(
        currentRep: 1,
        totalReps: 1,
        currentSubPhase: CadenceSubPhase.eccentric,
        subPhaseProgress: 0.0,
        subPhaseElapsedSeconds: 0.0,
        subPhaseTotalSeconds: 3,
        displaySecond: 0,
        isCountingUp: true,
      );
    }

    final elapsedMs = stepElapsed.inMilliseconds;
    final repDurationMs = repDurationSec * 1000;

    // Repetição atual (1-based)
    final repIndex = (elapsedMs ~/ repDurationMs) + 1;
    final clampedRep = repIndex > totalReps ? totalReps : repIndex;

    // Tempo dentro da repetição atual (ms)
    final repElapsedMs = elapsedMs % repDurationMs;

    final eMs = cadence.eccentricSeconds * 1000;
    final i1Ms = cadence.isometric1Seconds * 1000;
    final cMs = cadence.concentricSeconds * 1000;
    final i2Ms = cadence.isometric2Seconds * 1000;

    if (repElapsedMs < eMs && eMs > 0) {
      // 1. Fase Excêntrica (Descida): Mostra subindo de 0 até E
      final progress = repElapsedMs / eMs;
      final elapsedSec = repElapsedMs / 1000.0;
      final disp =
          (repElapsedMs / 1000).floor().clamp(0, cadence.eccentricSeconds);
      return CadenceProgress(
        currentRep: clampedRep,
        totalReps: totalReps,
        currentSubPhase: CadenceSubPhase.eccentric,
        subPhaseProgress: progress.clamp(0.0, 1.0),
        subPhaseElapsedSeconds: elapsedSec,
        subPhaseTotalSeconds: cadence.eccentricSeconds,
        displaySecond: disp,
        isCountingUp: true,
      );
    } else if (repElapsedMs < (eMs + i1Ms) && i1Ms > 0) {
      // 2. Isometria 1 (Pausa Inferior)
      final localMs = repElapsedMs - eMs;
      final progress = localMs / i1Ms;
      final elapsedSec = localMs / 1000.0;
      final disp = (localMs / 1000).floor() + 1;
      return CadenceProgress(
        currentRep: clampedRep,
        totalReps: totalReps,
        currentSubPhase: CadenceSubPhase.isometric1,
        subPhaseProgress: progress.clamp(0.0, 1.0),
        subPhaseElapsedSeconds: elapsedSec,
        subPhaseTotalSeconds: cadence.isometric1Seconds,
        displaySecond: disp,
        isCountingUp: true,
      );
    } else if (repElapsedMs < (eMs + i1Ms + cMs) && cMs > 0) {
      // 3. Fase Concêntrica (Subida): Mostra descendo de C até 0
      final localMs = repElapsedMs - (eMs + i1Ms);
      final progress = localMs / cMs;
      final elapsedSec = localMs / 1000.0;
      final remainingInSubphase =
          ((cMs - localMs) / 1000).ceil().clamp(0, cadence.concentricSeconds);
      return CadenceProgress(
        currentRep: clampedRep,
        totalReps: totalReps,
        currentSubPhase: CadenceSubPhase.concentric,
        subPhaseProgress: progress.clamp(0.0, 1.0),
        subPhaseElapsedSeconds: elapsedSec,
        subPhaseTotalSeconds: cadence.concentricSeconds,
        displaySecond: remainingInSubphase,
        isCountingUp: false,
      );
    } else if (i2Ms > 0) {
      // 4. Isometria 2 (Pico de Contração)
      final localMs = repElapsedMs - (eMs + i1Ms + cMs);
      final progress = localMs / i2Ms;
      final elapsedSec = localMs / 1000.0;
      final disp = (localMs / 1000).floor() + 1;
      return CadenceProgress(
        currentRep: clampedRep,
        totalReps: totalReps,
        currentSubPhase: CadenceSubPhase.isometric2,
        subPhaseProgress: progress.clamp(0.0, 1.0),
        subPhaseElapsedSeconds: elapsedSec,
        subPhaseTotalSeconds: cadence.isometric2Seconds,
        displaySecond: disp,
        isCountingUp: true,
      );
    } else {
      // Fallback
      return CadenceProgress(
        currentRep: clampedRep,
        totalReps: totalReps,
        currentSubPhase: CadenceSubPhase.concentric,
        subPhaseProgress: 1.0,
        subPhaseElapsedSeconds: 0.0,
        subPhaseTotalSeconds: cadence.concentricSeconds,
        displaySecond: 0,
        isCountingUp: false,
      );
    }
  }
}
