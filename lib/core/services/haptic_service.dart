import 'package:flutter/services.dart';

/// Serviço de Feedback Háptico (Vibração Tátil Sincronizada)
class HapticService {
  bool _isHapticEnabled = true;

  bool get isHapticEnabled => _isHapticEnabled;

  void setHapticEnabled(bool enabled) {
    _isHapticEnabled = enabled;
  }

  /// Vibração leve (para toques em botões e steppers +/-)
  Future<void> lightImpact() async {
    if (!_isHapticEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Vibração média (para contagem regressiva 3, 2, 1)
  Future<void> countdownImpact() async {
    if (!_isHapticEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Vibração forte (para início de WORK e fim de série)
  Future<void> strongImpact() async {
    if (!_isHapticEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Padrão de vibração para conclusão do treino
  Future<void> workoutCompletedVibration() async {
    if (!_isHapticEnabled) return;
    await HapticFeedback.vibrate();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.heavyImpact();
  }
}
