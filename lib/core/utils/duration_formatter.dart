/// Utilitário para formatação limpa de tempos e durações no formato esportivo
class DurationFormatter {
  /// Formata uma duração para mm:ss ou hh:mm:ss se ultrapassar 1 hora
  static String format(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);

    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final String hoursStr = hours.toString().padLeft(2, '0');
      return '$hoursStr:$minutesStr:$secondsStr';
    } else {
      return '$minutesStr:$secondsStr';
    }
  }

  /// Formata segundos inteiros para mm:ss ou hh:mm:ss
  static String formatSeconds(int totalSeconds) {
    return format(Duration(seconds: totalSeconds));
  }

  /// Formata milissegundos restantes com centésimos (ex: "45.8s" ou "00:45.8")
  static String formatWithMilliseconds(Duration duration) {
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);
    final int tenths = (duration.inMilliseconds.remainder(1000) ~/ 100);

    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = seconds.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr.$tenths';
  }

  /// Formata apenas segundos com rótulo amigável (ex: "45s", "2m 30s", "1h 10m")
  static String formatFriendly(int totalSeconds) {
    if (totalSeconds < 60) {
      return '${totalSeconds}s';
    }
    final int minutes = totalSeconds ~/ 60;
    final int remainingSec = totalSeconds % 60;
    if (minutes < 60) {
      return remainingSec > 0 ? '${minutes}m ${remainingSec}s' : '${minutes}m';
    }
    final int hours = minutes ~/ 60;
    final int remMin = minutes % 60;
    return remMin > 0 ? '${hours}h ${remMin}m' : '${hours}h';
  }
}
