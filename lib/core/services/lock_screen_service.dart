import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/workout_config/models/workout_phase.dart';
import '../../features/workout_execution/models/timer_state.dart';
import '../utils/duration_formatter.dart';

/// Serviço responsável por manter o timer visível e atualizado na tela de bloqueio (Lock Screen)
/// tanto no Android quanto no iOS via notificações em tempo real com alta prioridade.
class LockScreenService {
  static const int notificationId = 8888;
  static const String channelId = 'tensortimer_active_workout';
  static const String channelName = 'Treino Ativo (TensionTimer)';
  static const String channelDescription =
      'Mostra o andamento e contagem regressiva do treino na tela de bloqueio.';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;
  int _lastReportedRemainingSeconds = -1;
  String _lastReportedPhaseOrStep = '';

  LockScreenService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(initSettings);

      // Solicita permissões explicitamente no Android 13+
      try {
        final androidImplementation =
            _plugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidImplementation != null) {
          await androidImplementation.requestNotificationsPermission();
        }
      } catch (_) {}

      // Solicita permissões no iOS
      try {
        final iosImplementation =
            _plugin.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        if (iosImplementation != null) {
          await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
        }
      } catch (_) {}

      _isInitialized = true;
    } catch (e) {
      debugPrint('LockScreenService initialize error: $e');
    }
  }

  /// Atualiza o painel do temporizador na tela de bloqueio
  Future<void> updateLockScreenDisplay({
    required WorkoutTimerState state,
    required String workoutName,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Se o treino terminou, exibe notificação de conclusão
    if (state.status.isCompleted) {
      await showWorkoutCompleted(workoutName);
      return;
    }

    final currentStep = state.currentStep;
    final remainingSec = state.stepRemainingSeconds;
    final phase = state.currentPhase;
    final stepKey = '${currentStep?.id}_${phase.name}';

    // Otimização: Atualiza a notificação somente a cada 1 segundo ou na troca de etapa
    if (remainingSec == _lastReportedRemainingSeconds &&
        stepKey == _lastReportedPhaseOrStep) {
      return;
    }

    _lastReportedRemainingSeconds = remainingSec;
    _lastReportedPhaseOrStep = stepKey;

    final String title;
    final String body;

    final timeRemainingStr = DurationFormatter.formatSeconds(remainingSec);
    final totalRemainingStr = DurationFormatter.format(state.totalRemaining);

    if (currentStep != null) {
      final isCadence = currentStep.cadence != null;
      final cadProg = state.cadenceProgress;

      if (phase == WorkoutPhase.work) {
        final exerciseTitle = currentStep.exerciseName;
        final setInfo = 'Série ${currentStep.setIndex}/${currentStep.totalSets}';

        if (isCadence && cadProg != null) {
          title = '💪 $exerciseTitle ($setInfo)';
          body =
              '⏱️ $timeRemainingStr • Rep ${cadProg.currentRep}/${cadProg.totalReps} (${cadProg.currentSubPhase.shortLabel} ${cadProg.displaySecond}s) • Restante: $totalRemainingStr';
        } else {
          title = '⚡ $exerciseTitle ($setInfo)';
          body =
              '⏱️ $timeRemainingStr restantes • Total restante: $totalRemainingStr';
        }
      } else if (phase == WorkoutPhase.rest) {
        title = '⏳ Descanso (${currentStep.exerciseName})';
        body =
            '⏱️ $timeRemainingStr • Próxima: Série ${currentStep.setIndex + 1}/${currentStep.totalSets}';
      } else if (phase == WorkoutPhase.restBetweenSets) {
        title = '🔄 Troca de Exercício';
        body = '⏱️ $timeRemainingStr • ${currentStep.description}';
      } else if (phase == WorkoutPhase.prepare) {
        title = '🚀 Preparação para o Treino';
        body = '⏱️ $timeRemainingStr • 1º: ${currentStep.exerciseName}';
      } else {
        title = '🧘 Volta à Calma';
        body = '⏱️ $timeRemainingStr • Alongamento e relaxamento';
      }
    } else {
      title = '⏱️ $workoutName';
      body = 'Tempo restante: $totalRemainingStr';
    }

    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        showWhen: false,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.stopwatch,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentSound: false,
        presentBadge: false,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(
        notificationId,
        title,
        body,
        details,
      );
    } catch (e) {
      debugPrint('LockScreenService show error: $e');
    }
  }

  /// Exibe notificação de conclusão de treino
  Future<void> showWorkoutCompleted(String workoutName) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        ongoing: false,
        autoCancel: true,
        visibility: NotificationVisibility.public,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: false,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(
        notificationId,
        '🏆 Treino Concluído!',
        'Parabéns! Você finalizou com sucesso o treino "$workoutName".',
        details,
      );
    } catch (e) {
      debugPrint('LockScreenService show completed error: $e');
    }
  }

  /// Remove a notificação da tela de bloqueio
  Future<void> cancelNotification() async {
    try {
      await _plugin.cancel(notificationId);
      _lastReportedRemainingSeconds = -1;
      _lastReportedPhaseOrStep = '';
    } catch (e) {
      debugPrint('LockScreenService cancel error: $e');
    }
  }
}

final lockScreenServiceProvider = Provider<LockScreenService>((ref) {
  return LockScreenService();
});
