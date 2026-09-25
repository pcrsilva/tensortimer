/// Modo de cálculo e prescrição do bloco de Trabalho (WORK)
enum WorkMode {
  /// Baseado em cadência/velocidade de repetição (TUT) e repetições
  /// Ex: 3030 x 8 reps = 48 segundos de tensão sob carga
  cadence,

  /// Baseado em tempo fixo pré-definido por ciclo
  /// Ex: 45 segundos
  time;

  bool get isCadence => this == WorkMode.cadence;
  bool get isTime => this == WorkMode.time;
}
