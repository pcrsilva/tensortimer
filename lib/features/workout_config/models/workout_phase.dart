import 'package:flutter/material.dart';

/// Fases possíveis de um treino intervalado / tempo sob tensão (TUT)
enum WorkoutPhase {
  prepare,
  work,
  rest,
  restBetweenSets,
  coolDown,
  completed;

  /// Nome legível da fase em Português
  String get label {
    switch (this) {
      case WorkoutPhase.prepare:
        return 'Preparação';
      case WorkoutPhase.work:
        return 'Trabalho / Tensão';
      case WorkoutPhase.rest:
        return 'Descanso';
      case WorkoutPhase.restBetweenSets:
        return 'Descanso entre Séries';
      case WorkoutPhase.coolDown:
        return 'Volta à Calma';
      case WorkoutPhase.completed:
        return 'Treino Concluído!';
    }
  }

  /// Nome curto para tags compactas
  String get shortLabel {
    switch (this) {
      case WorkoutPhase.prepare:
        return 'PREP';
      case WorkoutPhase.work:
        return 'WORK';
      case WorkoutPhase.rest:
        return 'REST';
      case WorkoutPhase.restBetweenSets:
        return 'SET REST';
      case WorkoutPhase.coolDown:
        return 'COOL';
      case WorkoutPhase.completed:
        return 'FIM';
    }
  }

  /// Cor temática vibrante de alto contraste para visibilidade à distância
  Color get primaryColor {
    switch (this) {
      case WorkoutPhase.prepare:
        return const Color(0xFFF59E0B); // Amarelo/Âmbar quente
      case WorkoutPhase.work:
        return const Color(0xFF10B981); // Verde Esmeralda vibrante
      case WorkoutPhase.rest:
        return const Color(0xFFEF4444); // Vermelho / Coral
      case WorkoutPhase.restBetweenSets:
        return const Color(0xFF8B5CF6); // Violeta / Roxo intenso
      case WorkoutPhase.coolDown:
        return const Color(0xFF06B6D4); // Ciano / Azul suave
      case WorkoutPhase.completed:
        return const Color(0xFFEAB308); // Ouro / Dourado
    }
  }

  /// Cor de fundo suave (para cards e chips)
  Color get backgroundColor {
    return primaryColor.withValues(alpha: 0.15);
  }

  /// Ícone representativo da fase
  IconData get icon {
    switch (this) {
      case WorkoutPhase.prepare:
        return Icons.timer_outlined;
      case WorkoutPhase.work:
        return Icons.fitness_center_rounded;
      case WorkoutPhase.rest:
        return Icons.pause_circle_outline_rounded;
      case WorkoutPhase.restBetweenSets:
        return Icons.snooze_rounded;
      case WorkoutPhase.coolDown:
        return Icons.self_improvement_rounded;
      case WorkoutPhase.completed:
        return Icons.emoji_events_rounded;
    }
  }

  /// Indica se a fase exige esforço físico ativo
  bool get isWork => this == WorkoutPhase.work;

  /// Indica se a fase é de recuperação
  bool get isRest =>
      this == WorkoutPhase.rest || this == WorkoutPhase.restBetweenSets;
}
