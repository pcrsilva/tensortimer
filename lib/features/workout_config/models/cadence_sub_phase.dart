import 'package:flutter/material.dart';

/// Sub-fases da cadência de repetição no treinamento de força / TUT
enum CadenceSubPhase {
  /// Descida / Alongamento sob tensão (Fase Excêntrica) - contador sobe 0 -> E
  eccentric,

  /// Pausa / Transição inferior (Ponto de máxima extensão / inversão do movimento)
  isometric1,

  /// Subida / Contração máxima (Fase Concêntrica) - contador desce C -> 0
  concentric,

  /// Pico de contração / Pausa superior antes de iniciar a próxima repetição
  isometric2;

  String get label {
    switch (this) {
      case CadenceSubPhase.eccentric:
        return 'DESCIDA (EXCÊNTRICA)';
      case CadenceSubPhase.isometric1:
        return 'PAUSA INFERIOR';
      case CadenceSubPhase.concentric:
        return 'SUBIDA (CONCÊNTRICA)';
      case CadenceSubPhase.isometric2:
        return 'PICO DE CONTRAÇÃO';
    }
  }

  String get shortLabel {
    switch (this) {
      case CadenceSubPhase.eccentric:
        return 'Descida';
      case CadenceSubPhase.isometric1:
        return 'Pausa Inf.';
      case CadenceSubPhase.concentric:
        return 'Subida';
      case CadenceSubPhase.isometric2:
        return 'Pico';
    }
  }

  IconData get icon {
    switch (this) {
      case CadenceSubPhase.eccentric:
        return Icons.arrow_downward_rounded;
      case CadenceSubPhase.isometric1:
        return Icons.pause_circle_outline_rounded;
      case CadenceSubPhase.concentric:
        return Icons.arrow_upward_rounded;
      case CadenceSubPhase.isometric2:
        return Icons.stop_circle_outlined;
    }
  }

  Color get color {
    switch (this) {
      case CadenceSubPhase.eccentric:
        return const Color(0xFF00E676); // Verde neon
      case CadenceSubPhase.isometric1:
        return const Color(0xFFFFD600); // Amarelo vibrante
      case CadenceSubPhase.concentric:
        return const Color(0xFF00B0FF); // Azul esportivo
      case CadenceSubPhase.isometric2:
        return const Color(0xFFFF9100); // Laranja vivo
    }
  }
}
