import 'dart:math' as math;
import 'dart:typed_data';

/// Gerador em memória de ondas sonoras WAV/PCM para bipes esportivos e gongs
class SoundGenerator {
  /// Gera um arquivo WAV de onda senoidal pura em memória
  static Uint8List generateSineWaveWav({
    required double frequencyHz,
    required double durationSeconds,
    int sampleRate = 44100,
    double volume = 0.8,
    bool fadeOut = true,
  }) {
    final int numSamples = (sampleRate * durationSeconds).toInt();
    final int dataSize = numSamples * 2; // 16-bit mono = 2 bytes por sample
    final int fileSize = 36 + dataSize;

    final ByteData byteData = ByteData(44 + dataSize);

    // 1. RIFF Header
    byteData.setUint8(0, 0x52); // 'R'
    byteData.setUint8(1, 0x49); // 'I'
    byteData.setUint8(2, 0x46); // 'F'
    byteData.setUint8(3, 0x46); // 'F'
    byteData.setUint32(4, fileSize, Endian.little);
    byteData.setUint8(8, 0x57); // 'W'
    byteData.setUint8(9, 0x41); // 'A'
    byteData.setUint8(10, 0x56); // 'V'
    byteData.setUint8(11, 0x45); // 'E'

    // 2. fmt Sub-chunk
    byteData.setUint8(12, 0x66); // 'f'
    byteData.setUint8(13, 0x6D); // 'm'
    byteData.setUint8(14, 0x74); // 't'
    byteData.setUint8(15, 0x20); // ' '
    byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 para PCM)
    byteData.setUint16(20, 1, Endian.little); // AudioFormat (1 para PCM)
    byteData.setUint16(22, 1, Endian.little); // NumChannels (1 = Mono)
    byteData.setUint32(24, sampleRate, Endian.little); // SampleRate
    byteData.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
    byteData.setUint16(32, 2, Endian.little); // BlockAlign
    byteData.setUint16(34, 16, Endian.little); // BitsPerSample (16 bits)

    // 3. data Sub-chunk
    byteData.setUint8(36, 0x64); // 'd'
    byteData.setUint8(37, 0x61); // 'a'
    byteData.setUint8(38, 0x74); // 't'
    byteData.setUint8(39, 0x61); // 'a'
    byteData.setUint32(40, dataSize, Endian.little);

    // 4. PCM Samples
    int offset = 44;
    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      double envelope = 1.0;

      // Suave fade out para evitar "clicks" de áudio
      if (fadeOut && i > numSamples * 0.7) {
        envelope = (numSamples - i) / (numSamples * 0.3);
      }

      final double sample = math.sin(2 * math.pi * frequencyHz * t) *
          volume *
          envelope *
          32767;
      final int sampleInt = sample.clamp(-32768, 32767).toInt();
      byteData.setInt16(offset, sampleInt, Endian.little);
      offset += 2;
    }

    return byteData.buffer.asUint8List();
  }

  /// Bipe curto de contagem regressiva (3, 2, 1) - 880Hz (A5)
  static Uint8List createCountdownBeep() {
    return generateSineWaveWav(
      frequencyHz: 880.0,
      durationSeconds: 0.12,
      volume: 0.85,
    );
  }

  /// Bipe agudo longo de início de trabalho (WORK / GO!) - 1760Hz (A6)
  static Uint8List createWorkStartBeep() {
    return generateSineWaveWav(
      frequencyHz: 1760.0,
      durationSeconds: 0.45,
      volume: 0.95,
    );
  }

  /// Tom grave de início de descanso (REST) - 523.25Hz (C5)
  static Uint8List createRestStartTone() {
    return generateSineWaveWav(
      frequencyHz: 523.25,
      durationSeconds: 0.35,
      volume: 0.85,
    );
  }

  /// Tom grave longo de descanso entre séries (SET REST) - 440Hz (A4)
  static Uint8List createSetRestTone() {
    return generateSineWaveWav(
      frequencyHz: 440.0,
      durationSeconds: 0.50,
      volume: 0.90,
    );
  }
}
