import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../workout_config/models/cadence_sub_phase.dart';
import '../../workout_config/models/interval_step.dart';
import '../../workout_config/models/workout_phase.dart';
import '../models/timer_state.dart';

/// Tipos de eventos sonoros e táteis disparados pelo motor do timer
enum TimerAudioEvent {
  prepareStart,
  workStart, // Toca apito esportivo clássico
  restStart,
  restBetweenSetsStart,
  coolDownStart,
  countdownTick, // 3, 2, 1
  cadencePhaseTick, // Mudança de fase dentro da cadência (ex: virada descida->subida)
  workoutCompleted,
}

/// Callback para notificação de eventos sonoros / hápticos
typedef TimerEventCallback = void Function(
  TimerAudioEvent event, {
  int? countdownSecond,
  IntervalStep? currentStep,
  CadenceSubPhase? cadenceSubPhase,
});

/// Motor de Temporização de Alta Precisão (Drift-Free com Milliseconds Clock)
class WorkoutTimerEngine extends ChangeNotifier {
  WorkoutTimerState _state;
  Timer? _ticker;
  DateTime? _lastTickTime;
  int _lastCountdownSecondEmitted = -1;
  CadenceSubPhase? _lastCadenceSubPhase;
  TimerEventCallback? onTimerEvent;

  WorkoutTimerEngine({
    required List<IntervalStep> timeline,
    this.onTimerEvent,
  }) : _state = WorkoutTimerState.initial(timeline);

  WorkoutTimerState get state => _state;

  /// Atualiza a linha do tempo e reinicia o estado
  void loadTimeline(List<IntervalStep> timeline) {
    stop();
    _state = WorkoutTimerState.initial(timeline);
    notifyListeners();
  }

  /// Inicia ou retoma a execução do treino
  void start() {
    if (_state.timeline.isEmpty) return;
    if (_state.status.isRunning) return;

    if (_state.status.isCompleted) {
      reset();
    }

    final bool isStartingFromZero = _state.status.isIdle;

    _state = _state.copyWith(status: WorkoutTimerStatus.running);
    _lastTickTime = DateTime.now();
    _lastCountdownSecondEmitted = -1;
    _lastCadenceSubPhase = null;

    // Dispara evento de início se estava no zero
    if (isStartingFromZero && _state.currentStep != null) {
      _emitPhaseStartEvent(_state.currentStep!.phase);
    }

    _startTicker();
    notifyListeners();
  }

  /// Pausa a execução
  void pause() {
    if (!_state.status.isRunning) return;
    _ticker?.cancel();
    _ticker = null;
    _state = _state.copyWith(status: WorkoutTimerStatus.paused);
    notifyListeners();
  }

  /// Alterna entre Iniciar e Pausar
  void togglePlayPause() {
    if (_state.status.isRunning) {
      pause();
    } else {
      start();
    }
  }

  /// Pula para o próximo passo da linha do tempo
  void skipNext() {
    if (_state.timeline.isEmpty) return;

    if (_state.currentStepIndex + 1 < _state.timeline.length) {
      _advanceToStep(_state.currentStepIndex + 1);
    } else {
      _completeWorkout();
    }
  }

  /// Volta para o início do passo atual ou para o passo anterior
  void skipPrevious() {
    if (_state.timeline.isEmpty) return;

    // Se já decorreu mais de 3 segundos no passo atual, reinicia o passo atual
    if (_state.stepElapsed.inSeconds >= 3 || _state.currentStepIndex == 0) {
      _state = _state.copyWith(stepElapsed: Duration.zero);
      _lastCountdownSecondEmitted = -1;
      _lastCadenceSubPhase = null;
      notifyListeners();
    } else {
      _advanceToStep(_state.currentStepIndex - 1);
    }
  }

  /// Reinicia todo o treino do início
  void reset() {
    _ticker?.cancel();
    _ticker = null;
    _lastCountdownSecondEmitted = -1;
    _lastCadenceSubPhase = null;
    _state = WorkoutTimerState.initial(_state.timeline);
    notifyListeners();
  }

  /// Para a execução e encerra
  void stop() {
    _ticker?.cancel();
    _ticker = null;
    _lastCountdownSecondEmitted = -1;
    _lastCadenceSubPhase = null;
    _state = _state.copyWith(status: WorkoutTimerStatus.idle);
    notifyListeners();
  }

  // --- MOTOR INTERNO & TICKER ---

  void _startTicker() {
    _ticker?.cancel();
    // Ticker de alta frequência a cada 50ms para fluidez de animação e precisão de relógio
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _onTick();
    });
  }

  void _onTick() {
    if (!_state.status.isRunning) return;

    final now = DateTime.now();
    final deltaMs = _lastTickTime != null
        ? now.difference(_lastTickTime!).inMilliseconds
        : 50;
    _lastTickTime = now;

    final currentStep = _state.currentStep;
    if (currentStep == null) {
      _completeWorkout();
      return;
    }

    final newStepElapsed =
        _state.stepElapsed + Duration(milliseconds: deltaMs);
    final newTotalElapsed =
        _state.totalElapsed + Duration(milliseconds: deltaMs);

    final stepTotalMs = currentStep.duration.inMilliseconds;
    final remainingMs = stepTotalMs - newStepElapsed.inMilliseconds;

    // 1. Checagem de contagem regressiva 3, 2, 1 segundos antes do fim do passo
    if (remainingMs > 0 && remainingMs <= 3100) {
      final int remainingSec = (remainingMs / 1000).ceil();
      if (remainingSec >= 1 &&
          remainingSec <= 3 &&
          remainingSec != _lastCountdownSecondEmitted) {
        _lastCountdownSecondEmitted = remainingSec;
        onTimerEvent?.call(
          TimerAudioEvent.countdownTick,
          countdownSecond: remainingSec,
          currentStep: currentStep,
        );
      }
    }

    // 2. Se o passo possui cadência TUT, checa transição de sub-fase (descida / subida / repetição)
    if (currentStep.hasCadence && currentStep.cadence != null) {
      final cadProg = _state.cadenceProgress;
      if (cadProg != null) {
        if (_lastCadenceSubPhase != null &&
            _lastCadenceSubPhase != cadProg.currentSubPhase) {
          onTimerEvent?.call(
            TimerAudioEvent.cadencePhaseTick,
            currentStep: currentStep,
            cadenceSubPhase: cadProg.currentSubPhase,
          );
        }
        _lastCadenceSubPhase = cadProg.currentSubPhase;
      }
    }

    // 3. Se o passo atual foi concluído
    if (newStepElapsed >= currentStep.duration) {
      if (_state.currentStepIndex + 1 < _state.timeline.length) {
        _advanceToStep(_state.currentStepIndex + 1);
      } else {
        _completeWorkout();
      }
      return;
    }

    _state = _state.copyWith(
      stepElapsed: newStepElapsed,
      totalElapsed: newTotalElapsed,
    );
    notifyListeners();
  }

  void _advanceToStep(int stepIndex) {
    if (stepIndex < 0 || stepIndex >= _state.timeline.length) return;

    _lastCountdownSecondEmitted = -1;
    _lastCadenceSubPhase = null;

    // Recalcula o total decorrido até o início do novo passo
    int accumulatedMs = 0;
    for (int i = 0; i < stepIndex; i++) {
      accumulatedMs += _state.timeline[i].duration.inMilliseconds;
    }

    _state = _state.copyWith(
      currentStepIndex: stepIndex,
      stepElapsed: Duration.zero,
      totalElapsed: Duration(milliseconds: accumulatedMs),
    );

    final nextStep = _state.currentStep;
    if (nextStep != null) {
      _emitPhaseStartEvent(nextStep.phase);
    }

    notifyListeners();
  }

  void _emitPhaseStartEvent(WorkoutPhase phase) {
    switch (phase) {
      case WorkoutPhase.prepare:
        onTimerEvent?.call(TimerAudioEvent.prepareStart,
            currentStep: _state.currentStep);
        break;
      case WorkoutPhase.work:
        // WORK / Início de série dispara o apito clássico
        onTimerEvent?.call(TimerAudioEvent.workStart,
            currentStep: _state.currentStep);
        break;
      case WorkoutPhase.rest:
        onTimerEvent?.call(TimerAudioEvent.restStart,
            currentStep: _state.currentStep);
        break;
      case WorkoutPhase.restBetweenSets:
        onTimerEvent?.call(TimerAudioEvent.restBetweenSetsStart,
            currentStep: _state.currentStep);
        break;
      case WorkoutPhase.coolDown:
        onTimerEvent?.call(TimerAudioEvent.coolDownStart,
            currentStep: _state.currentStep);
        break;
      case WorkoutPhase.completed:
        onTimerEvent?.call(TimerAudioEvent.workoutCompleted,
            currentStep: _state.currentStep);
        break;
    }
  }

  void _completeWorkout() {
    _ticker?.cancel();
    _ticker = null;
    _lastCountdownSecondEmitted = -1;
    _lastCadenceSubPhase = null;

    _state = _state.copyWith(
      status: WorkoutTimerStatus.completed,
      stepElapsed: _state.currentStep?.duration ?? Duration.zero,
      totalElapsed: _state.totalDuration,
    );

    onTimerEvent?.call(TimerAudioEvent.workoutCompleted);
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
