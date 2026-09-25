/// Modelo que encapsula a cadência de 4 dígitos e repetições (ex: 3030 x 8 reps = 48s)
class CadenceInfo {
  final int eccentricSeconds;
  final int isometric1Seconds;
  final int concentricSeconds;
  final int isometric2Seconds;
  final int targetReps;

  const CadenceInfo({
    this.eccentricSeconds = 3,
    this.isometric1Seconds = 0,
    this.concentricSeconds = 3,
    this.isometric2Seconds = 0,
    this.targetReps = 8,
  });

  /// Duração total de 1 repetição (soma dos 4 tempos da cadência)
  int get repDurationSeconds =>
      eccentricSeconds +
      isometric1Seconds +
      concentricSeconds +
      isometric2Seconds;

  /// Tempo total sob tensão de um ciclo completo (duração por rep x total de reps)
  int get totalWorkSeconds {
    final repDur = repDurationSeconds;
    if (repDur <= 0 || targetReps <= 0) return 0;
    return repDur * targetReps;
  }

  /// Código de 4 dígitos padrão (ex: "3030", "4020", "2010")
  String get code =>
      '$eccentricSeconds$isometric1Seconds$concentricSeconds$isometric2Seconds';

  /// Código formatado com separador (ex: "3-0-3-0")
  String get formattedCode =>
      '$eccentricSeconds-$isometric1Seconds-$concentricSeconds-$isometric2Seconds';

  /// Descrição explicativa do ritmo da cadência
  String get explanation {
    final parts = <String>[];
    if (eccentricSeconds > 0) parts.add('${eccentricSeconds}s descida');
    if (isometric1Seconds > 0) parts.add('${isometric1Seconds}s pausa inf.');
    if (concentricSeconds > 0) parts.add('${concentricSeconds}s subida');
    if (isometric2Seconds > 0) parts.add('${isometric2Seconds}s pausa sup.');
    return parts.join(' • ');
  }

  /// Parse inteligente a partir de uma string digitada pelo usuário (ex: "3030" ou "3-0-3-0")
  static CadenceInfo parse(String input, {int targetReps = 8}) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 4) {
      return CadenceInfo(
        eccentricSeconds: int.tryParse(digits[0]) ?? 3,
        isometric1Seconds: int.tryParse(digits[1]) ?? 0,
        concentricSeconds: int.tryParse(digits[2]) ?? 3,
        isometric2Seconds: int.tryParse(digits[3]) ?? 0,
        targetReps: targetReps,
      );
    } else if (digits.length == 3) {
      return CadenceInfo(
        eccentricSeconds: int.tryParse(digits[0]) ?? 3,
        isometric1Seconds: int.tryParse(digits[1]) ?? 0,
        concentricSeconds: int.tryParse(digits[2]) ?? 3,
        isometric2Seconds: 0,
        targetReps: targetReps,
      );
    } else if (digits.length == 2) {
      return CadenceInfo(
        eccentricSeconds: int.tryParse(digits[0]) ?? 3,
        isometric1Seconds: 0,
        concentricSeconds: int.tryParse(digits[1]) ?? 3,
        isometric2Seconds: 0,
        targetReps: targetReps,
      );
    }
    return CadenceInfo(targetReps: targetReps);
  }

  CadenceInfo copyWith({
    int? eccentricSeconds,
    int? isometric1Seconds,
    int? concentricSeconds,
    int? isometric2Seconds,
    int? targetReps,
  }) {
    return CadenceInfo(
      eccentricSeconds: eccentricSeconds ?? this.eccentricSeconds,
      isometric1Seconds: isometric1Seconds ?? this.isometric1Seconds,
      concentricSeconds: concentricSeconds ?? this.concentricSeconds,
      isometric2Seconds: isometric2Seconds ?? this.isometric2Seconds,
      targetReps: targetReps ?? this.targetReps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eccentricSeconds': eccentricSeconds,
      'isometric1Seconds': isometric1Seconds,
      'concentricSeconds': concentricSeconds,
      'isometric2Seconds': isometric2Seconds,
      'targetReps': targetReps,
    };
  }

  factory CadenceInfo.fromJson(Map<String, dynamic> json) {
    return CadenceInfo(
      eccentricSeconds: json['eccentricSeconds'] as int? ?? 3,
      isometric1Seconds: json['isometric1Seconds'] as int? ?? 0,
      concentricSeconds: json['concentricSeconds'] as int? ?? 3,
      isometric2Seconds: json['isometric2Seconds'] as int? ?? 0,
      targetReps: json['targetReps'] as int? ?? 8,
    );
  }
}
