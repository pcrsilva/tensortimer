import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../utils/sound_generator.dart';

/// Serviço de Áudio otimizado para reprodução instantânea de bipes, apitos e alertas esportivos
class AudioService {
  late final AudioPlayer _whistlePlayer;
  late final AudioPlayer _countdownPlayer;
  late final AudioPlayer _effectsPlayer;
  late final AudioPlayer _cadencePlayer;

  bool _isSoundEnabled = true;
  double _volume = 1.0;
  bool _isConfigured = false;

  AudioService({
    AudioPlayer? whistlePlayer,
    AudioPlayer? countdownPlayer,
    AudioPlayer? effectsPlayer,
    AudioPlayer? cadencePlayer,
  }) {
    _whistlePlayer = whistlePlayer ?? AudioPlayer(playerId: 'whistle_player');
    _countdownPlayer =
        countdownPlayer ?? AudioPlayer(playerId: 'countdown_player');
    _effectsPlayer = effectsPlayer ?? AudioPlayer(playerId: 'effects_player');
    _cadencePlayer = cadencePlayer ?? AudioPlayer(playerId: 'cadence_player');

    _initAudioContext();
  }

  Future<void> _initAudioContext() async {
    if (_isConfigured) return;
    try {
      // Configura a sessão de áudio para modo esportivo/reprodução
      // No iOS, playback garante que o som toque mesmo com a chave de silencioso ativada!
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.assistanceSonification,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );

      await _whistlePlayer.setReleaseMode(ReleaseMode.stop);
      await _countdownPlayer.setReleaseMode(ReleaseMode.stop);
      await _effectsPlayer.setReleaseMode(ReleaseMode.stop);
      await _cadencePlayer.setReleaseMode(ReleaseMode.stop);

      _isConfigured = true;
    } catch (e) {
      debugPrint('AudioService init error/warning: $e');
    }
  }

  bool get isSoundEnabled => _isSoundEnabled;
  double get volume => _volume;

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    _whistlePlayer.setVolume(_volume);
    _countdownPlayer.setVolume(_volume);
    _effectsPlayer.setVolume(_volume);
    _cadencePlayer.setVolume((_volume * 0.7).clamp(0.0, 1.0));
  }

  /// Toca o apito esportivo de início de série / trabalho
  Future<void> playWhistle() async {
    if (!_isSoundEnabled) return;
    try {
      await _initAudioContext();
      await _whistlePlayer.stop();
      await _whistlePlayer.play(
        AssetSource('audio/whistle.wav'),
        volume: _volume,
      );
    } catch (e) {
      debugPrint('Asset play failed, using fallback synthesized whistle: $e');
      try {
        final bytes = SoundGenerator.createWorkStartBeep();
        await _whistlePlayer.play(BytesSource(bytes), volume: _volume);
      } catch (_) {}
    }
  }

  /// Toca o bipe curto de contagem regressiva (3, 2, 1)
  Future<void> playCountdownBeep() async {
    if (!_isSoundEnabled) return;
    try {
      await _initAudioContext();
      await _countdownPlayer.stop();
      await _countdownPlayer.play(
        AssetSource('audio/countdown.wav'),
        volume: _volume,
      );
    } catch (e) {
      debugPrint('Asset play failed, using fallback countdown beep: $e');
      try {
        final bytes = SoundGenerator.createCountdownBeep();
        await _countdownPlayer.play(BytesSource(bytes), volume: _volume);
      } catch (_) {}
    }
  }

  /// Toca o som de início de descanso (REST)
  Future<void> playRestStart() async {
    if (!_isSoundEnabled) return;
    try {
      await _initAudioContext();
      await _effectsPlayer.stop();
      await _effectsPlayer.play(
        AssetSource('audio/rest.wav'),
        volume: _volume,
      );
    } catch (e) {
      try {
        final bytes = SoundGenerator.createRestStartTone();
        await _effectsPlayer.play(BytesSource(bytes), volume: _volume);
      } catch (_) {}
    }
  }

  /// Toca o som de descanso longo entre séries
  Future<void> playSetRestStart() async {
    if (!_isSoundEnabled) return;
    try {
      await _initAudioContext();
      await _effectsPlayer.stop();
      await _effectsPlayer.play(
        AssetSource('audio/set_rest.wav'),
        volume: _volume,
      );
    } catch (e) {
      try {
        final bytes = SoundGenerator.createSetRestTone();
        await _effectsPlayer.play(BytesSource(bytes), volume: _volume);
      } catch (_) {}
    }
  }

  /// Toca fanfarra / som de treino concluído
  Future<void> playWorkoutCompleted() async {
    if (!_isSoundEnabled) return;
    try {
      await _initAudioContext();
      await _effectsPlayer.stop();
      await _effectsPlayer.play(
        AssetSource('audio/complete.wav'),
        volume: _volume,
      );
    } catch (e) {
      try {
        await playWhistle();
      } catch (_) {}
    }
  }

  /// Toca micro-tick de troca de fase de cadência
  Future<void> playCadenceTick() async {
    if (!_isSoundEnabled) return;
    try {
      await _initAudioContext();
      await _cadencePlayer.stop();
      await _cadencePlayer.play(
        AssetSource('audio/cadence_tick.wav'),
        volume: (_volume * 0.6).clamp(0.0, 1.0),
      );
    } catch (_) {}
  }

  void dispose() {
    _whistlePlayer.dispose();
    _countdownPlayer.dispose();
    _effectsPlayer.dispose();
    _cadencePlayer.dispose();
  }
}
