import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/lock_screen_service.dart';
import '../../../../core/services/settings_provider.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../workout_config/models/cadence_sub_phase.dart';
import '../../../workout_config/models/interval_step.dart';
import '../../../workout_config/models/workout_config.dart';
import '../../../workout_config/models/workout_phase.dart';
import '../../models/cadence_progress.dart';
import '../../models/timer_state.dart';
import '../../providers/workout_timer_engine.dart';

class WorkoutExecutionScreen extends ConsumerStatefulWidget {
  final WorkoutConfig config;

  const WorkoutExecutionScreen({super.key, required this.config});

  static void start(BuildContext context, WorkoutConfig config) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutExecutionScreen(config: config),
      ),
    );
  }

  @override
  ConsumerState<WorkoutExecutionScreen> createState() =>
      _WorkoutExecutionScreenState();
}

class _WorkoutExecutionScreenState
    extends ConsumerState<WorkoutExecutionScreen> {
  late final WorkoutTimerEngine _engine;
  late final SettingsNotifier _settingsNotifier;
  late final LockScreenService _lockScreenService;

  @override
  void initState() {
    super.initState();

    final timeline = widget.config.compileTimeline();
    final audioService = ref.read(audioServiceProvider);
    final hapticService = ref.read(hapticServiceProvider);
    _lockScreenService = ref.read(lockScreenServiceProvider);
    _settingsNotifier = ref.read(settingsProvider.notifier);

    _engine = WorkoutTimerEngine(
      timeline: timeline,
      onTimerEvent: (
        event, {
        countdownSecond,
        currentStep,
        cadenceSubPhase,
      }) {
        _handleTimerEvent(
          event,
          countdownSecond,
          currentStep,
          cadenceSubPhase,
          audioService,
          hapticService,
        );
      },
    );

    // Conecta as atualizações em tempo real para tela de bloqueio (iOS e Android)
    _engine.addListener(() {
      if (mounted) {
        _lockScreenService.updateLockScreenDisplay(
          state: _engine.state,
          workoutName: widget.config.name,
        );
      }
    });

    // Liga wakelock se configurado
    _settingsNotifier.updateWakelock(true);

    // Inicia imediatamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _engine.start();
      }
    });
  }

  void _handleTimerEvent(
    TimerAudioEvent event,
    int? countdownSecond,
    IntervalStep? currentStep,
    CadenceSubPhase? cadenceSubPhase,
    dynamic audioService,
    dynamic hapticService,
  ) {
    switch (event) {
      case TimerAudioEvent.countdownTick:
        // Toca sempre quando estiver faltando 3 segundos (3, 2, 1):
        // - Na preparação (avisando o início da 1ª série)
        // - No término da série / trabalho (avisando o fim da série)
        // - No descanso (avisando o retorno para a próxima série)
        audioService.playCountdownBeep();
        hapticService.countdownImpact();
        break;
      case TimerAudioEvent.workoutCompleted:
        audioService.playWorkoutCompleted();
        hapticService.workoutCompletedVibration();
        break;
      case TimerAudioEvent.workStart:
      case TimerAudioEvent.prepareStart:
      case TimerAudioEvent.restStart:
      case TimerAudioEvent.restBetweenSetsStart:
      case TimerAudioEvent.coolDownStart:
      case TimerAudioEvent.cadencePhaseTick:
        // Silêncio durante a execução da série para foco total no movimento
        break;
    }
  }

  @override
  void dispose() {
    _lockScreenService.cancelNotification();
    _settingsNotifier.updateWakelock(false);
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _engine,
      builder: (context, _) {
        final state = _engine.state;
        final currentStep = state.currentStep;
        final phase = state.currentPhase;
        final cadenceProg = state.cadenceProgress;

        // Se estiver em trabalho com cadência, usa a cor da sub-fase (ex: verde descida, azul subida)
        final phaseColor = (phase == WorkoutPhase.work && cadenceProg != null)
            ? cadenceProg.currentSubPhase.color
            : phase.primaryColor;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              _confirmExit(context);
            }
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    phaseColor.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.95),
                    Colors.black,
                  ],
                ),
              ),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxH = constraints.maxHeight;
                    final isCompact = maxH < 620;
                    final circleDiameter = isCompact ? 190.0 : 240.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 1. Top Bar: Nome do Treino, Fechar e Status
                          _buildTopBar(context, state),
                          const SizedBox(height: 6),

                          // 2. Linha do Tempo Segmentada
                          _buildTimelineProgress(state),
                          const Spacer(),

                          // 3. Badges de Série, Ciclo e Repetição
                          if (currentStep != null && !state.status.isCompleted)
                            _buildBadgesRow(
                                currentStep, cadenceProg, phaseColor),
                          SizedBox(height: isCompact ? 6 : 12),

                          // 4. Mostrador Principal (Cadência TUT ou Temporizador Geral)
                          if (phase == WorkoutPhase.work &&
                              cadenceProg != null &&
                              !state.status.isCompleted)
                            _buildCadenceDisplay(
                                state, cadenceProg, circleDiameter, isCompact)
                          else
                            _buildGiantTimerDisplay(
                                state, phaseColor, circleDiameter, isCompact),

                          SizedBox(height: isCompact ? 6 : 12),

                          // 5. Título da Fase e Descrição
                          _buildPhaseTitleAndDescription(
                              state, phase, cadenceProg, isCompact),
                          const Spacer(),

                          // 6. Resumo de Tempo Total e Tempo do Ciclo
                          _buildTimeSummaryCard(state, cadenceProg, isCompact),
                          SizedBox(height: isCompact ? 10 : 16),

                          // 7. Controles de Reprodução
                          _buildControlsBar(state, isCompact),
                          const SizedBox(height: 6),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, WorkoutTimerState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _confirmExit(context),
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
          tooltip: 'Encerrar Treino',
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                widget.config.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                state.status.isPaused
                    ? 'PAUSADO'
                    : (state.status.isCompleted ? 'CONCLUÍDO' : 'EM ANDAMENTO'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: state.status.isPaused
                      ? AppColors.prepare
                      : (state.status.isCompleted
                          ? AppColors.completed
                          : AppColors.brandPrimary),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _engine.reset(),
          icon: const Icon(Icons.refresh_rounded,
              color: AppColors.darkTextSecondary, size: 24),
          tooltip: 'Reiniciar do Início',
        ),
      ],
    );
  }

  Widget _buildTimelineProgress(WorkoutTimerState state) {
    if (state.timeline.isEmpty) return const SizedBox.shrink();

    return Row(
      children: List.generate(state.timeline.length, (index) {
        final step = state.timeline[index];
        final isCompleted = index < state.currentStepIndex ||
            (index == state.currentStepIndex && state.status.isCompleted);
        final isCurrent =
            index == state.currentStepIndex && !state.status.isCompleted;

        return Expanded(
          child: Container(
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: isCompleted
                  ? step.phase.primaryColor
                  : (isCurrent
                      ? step.phase.primaryColor.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.15)),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBadgesRow(
    IntervalStep step,
    CadenceProgress? cadenceProg,
    Color phaseColor,
  ) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        _buildBadgeChip(
          'EXERCÍCIO ${step.exerciseIndex} DE ${step.totalExercises}',
          highlightColor: AppColors.brandPrimary,
        ),
        _buildBadgeChip('SÉRIE ${step.setIndex} DE ${step.totalSets}'),
        if (cadenceProg != null)
          _buildBadgeChip(
            'REP ${cadenceProg.currentRep} DE ${cadenceProg.totalReps}',
            highlightColor: cadenceProg.currentSubPhase.color,
          ),
      ],
    );
  }

  Widget _buildBadgeChip(String text, {Color? highlightColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: highlightColor != null
            ? highlightColor.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlightColor ?? Colors.white.withValues(alpha: 0.2),
          width: highlightColor != null ? 1.5 : 1.0,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: highlightColor ?? Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Mostrador Especial para Bloco com Cadência TUT (Velocidade subindo e descendo)
  Widget _buildCadenceDisplay(
    WorkoutTimerState state,
    CadenceProgress cadProg,
    double diameter,
    bool isCompact,
  ) {
    final subphase = cadProg.currentSubPhase;
    final subColor = subphase.color;

    // Progresso do anel: se subindo 0->E, cresce; se descendo C->0, diminui
    final ringValue = cadProg.isCountingUp
        ? cadProg.subPhaseProgress
        : (1.0 - cadProg.subPhaseProgress).clamp(0.0, 1.0);

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anel de Progresso Circular Animado
          SizedBox(
            width: diameter - 8,
            height: diameter - 8,
            child: CircularProgressIndicator(
              value: ringValue,
              strokeWidth: isCompact ? 10 : 13,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(subColor),
            ),
          ),

          // Informações Centrais
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone e Sub-fase da cadência
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(subphase.icon, color: subColor, size: isCompact ? 18 : 22),
                  const SizedBox(width: 4),
                  Text(
                    subphase.shortLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: isCompact ? 12 : 14,
                      fontWeight: FontWeight.w900,
                      color: subColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),

              // Dígito Gigante da Cadência (Subindo 0 a 3 na descida, ou descendo 3 a 0 na subida)
              Text(
                '${cadProg.displaySecond}s',
                style: TextStyle(
                  fontSize: isCompact ? 58 : 72,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -2,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  shadows: [
                    Shadow(
                      color: subColor.withValues(alpha: 0.8),
                      blurRadius: 24,
                    ),
                  ],
                ),
              ),

              // Meta da sub-fase (ex: "Meta: 3s")
              Text(
                'Meta: ${cadProg.subPhaseTotalSeconds}s (${cadProg.isCountingUp ? '0 ➔ ${cadProg.subPhaseTotalSeconds}s' : '${cadProg.subPhaseTotalSeconds}s ➔ 0'})',
                style: TextStyle(
                  fontSize: isCompact ? 10.5 : 11.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Mostrador Clássico de Contagem Regressiva para outras fases ou tempo fixo
  Widget _buildGiantTimerDisplay(
    WorkoutTimerState state,
    Color phaseColor,
    double diameter,
    bool isCompact,
  ) {
    final String timeStr;
    if (state.status.isCompleted) {
      timeStr = '00:00';
    } else {
      timeStr = DurationFormatter.formatSeconds(state.stepRemainingSeconds);
    }

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anel de Progresso Circular
          SizedBox(
            width: diameter - 8,
            height: diameter - 8,
            child: CircularProgressIndicator(
              value: state.status.isCompleted ? 1.0 : state.stepProgress,
              strokeWidth: isCompact ? 9 : 12,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(phaseColor),
            ),
          ),

          // Dígitos Gigantes
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: isCompact ? 52 : 64,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -2,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  shadows: [
                    Shadow(
                      color: phaseColor.withValues(alpha: 0.6),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              if (state.nextStep != null && !state.status.isCompleted) ...[
                const SizedBox(height: 2),
                Text(
                  'Próximo: ${state.nextStep!.phase.shortLabel} (${DurationFormatter.format(state.nextStep!.duration)})',
                  style: TextStyle(
                    fontSize: isCompact ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseTitleAndDescription(
    WorkoutTimerState state,
    WorkoutPhase phase,
    CadenceProgress? cadenceProg,
    bool isCompact,
  ) {
    if (state.status.isCompleted) {
      return Column(
        children: [
          Text(
            '🏆 TREINO CONCLUÍDO!',
            style: TextStyle(
              fontSize: isCompact ? 22 : 26,
              fontWeight: FontWeight.w900,
              color: AppColors.completed,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Parabéns! Você completou todas as séries e ciclos com sucesso.',
            style: TextStyle(
              fontSize: isCompact ? 12 : 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    final currentStep = state.currentStep;
    final title = currentStep?.title ?? phase.label;
    final desc = currentStep?.description ?? '';

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 12 : 16, vertical: isCompact ? 4 : 6),
          decoration: BoxDecoration(
            color: phase.primaryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: phase.primaryColor, width: 1.5),
          ),
          child: Text(
            phase.label.toUpperCase(),
            style: TextStyle(
              fontSize: isCompact ? 16 : 19,
              fontWeight: FontWeight.w900,
              color: phase.primaryColor,
              letterSpacing: 1.0,
            ),
          ),
        ),
        if (title.isNotEmpty && title != phase.label) ...[
          SizedBox(height: isCompact ? 4 : 6),
          Text(
            title,
            style: TextStyle(
              fontSize: isCompact ? 16 : 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (desc.isNotEmpty && desc != title) ...[
          const SizedBox(height: 2),
          Text(
            desc,
            style: TextStyle(
              fontSize: isCompact ? 11 : 12.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// Card que exibe o tempo do ciclo diminuindo e o resumo geral do treino
  Widget _buildTimeSummaryCard(
    WorkoutTimerState state,
    CadenceProgress? cadenceProg,
    bool isCompact,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 16, vertical: isCompact ? 8 : 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          // Linha 1: Tempo do Bloco/Ciclo atual diminuindo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 16, color: AppColors.work),
                  const SizedBox(width: 6),
                  Text(
                    'Tempo do Bloco:',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
              Text(
                DurationFormatter.formatSeconds(state.stepRemainingSeconds),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.work,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 1, color: Colors.white12),
          const SizedBox(height: 6),

          // Linha 2: Decorrido e Restante Geral
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Decorrido: ${DurationFormatter.format(state.totalElapsed)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              Text(
                'Restante: ${DurationFormatter.format(state.totalRemaining)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlsBar(WorkoutTimerState state, bool isCompact) {
    final isRunning = state.status.isRunning;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Voltar bloco
        _buildRoundButton(
          icon: Icons.skip_previous_rounded,
          size: isCompact ? 48 : 54,
          onTap: () => _engine.skipPrevious(),
          color: Colors.white.withValues(alpha: 0.15),
          iconColor: Colors.white,
        ),

        // Botão Principal: Play / Pause
        _buildRoundButton(
          icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: isCompact ? 68 : 78,
          onTap: () => _engine.togglePlayPause(),
          color: isRunning ? AppColors.prepare : AppColors.brandPrimary,
          iconColor: Colors.white,
          isPrimary: true,
        ),

        // Avançar bloco
        _buildRoundButton(
          icon: Icons.skip_next_rounded,
          size: isCompact ? 48 : 54,
          onTap: () => _engine.skipNext(),
          color: Colors.white.withValues(alpha: 0.15),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildRoundButton({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
    required Color color,
    required Color iconColor,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: size * 0.5, color: iconColor),
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    _engine.pause();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Encerrar Treino?'),
        content: const Text(
          'Deseja realmente sair da tela de execução e parar o temporizador?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _engine.start();
            },
            child: const Text('Continuar Treino'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rest,
              foregroundColor: Colors.white,
            ),
            child: const Text('Encerrar'),
          ),
        ],
      ),
    );
  }
}
