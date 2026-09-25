import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'audio_service.dart';
import 'haptic_service.dart';
import 'storage_service.dart';

class SettingsState {
  final bool isSoundEnabled;
  final bool isHapticEnabled;
  final bool keepScreenAwake;
  final double volume;

  const SettingsState({
    this.isSoundEnabled = true,
    this.isHapticEnabled = true,
    this.keepScreenAwake = true,
    this.volume = 1.0,
  });

  SettingsState copyWith({
    bool? isSoundEnabled,
    bool? isHapticEnabled,
    bool? keepScreenAwake,
    double? volume,
  }) {
    return SettingsState(
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isHapticEnabled: isHapticEnabled ?? this.isHapticEnabled,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      volume: volume ?? this.volume,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final AudioService audioService;
  final HapticService hapticService;

  SettingsNotifier({
    required this.audioService,
    required this.hapticService,
  }) : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final sound = await StorageService.loadSoundEnabled();
    final haptic = await StorageService.loadHapticEnabled();
    final keepAwake = await StorageService.loadKeepScreenAwake();
    final vol = await StorageService.loadVolume();

    audioService.setSoundEnabled(sound);
    audioService.setVolume(vol);
    hapticService.setHapticEnabled(haptic);

    state = SettingsState(
      isSoundEnabled: sound,
      isHapticEnabled: haptic,
      keepScreenAwake: keepAwake,
      volume: vol,
    );
  }

  void toggleSound(bool enabled) {
    audioService.setSoundEnabled(enabled);
    state = state.copyWith(isSoundEnabled: enabled);
    StorageService.saveSoundEnabled(enabled);
  }

  void setVolume(double vol) {
    audioService.setVolume(vol);
    state = state.copyWith(volume: vol);
    StorageService.saveVolume(vol);
  }

  void toggleHaptic(bool enabled) {
    hapticService.setHapticEnabled(enabled);
    state = state.copyWith(isHapticEnabled: enabled);
    StorageService.saveHapticEnabled(enabled);
  }

  void toggleKeepScreenAwake(bool keep) {
    state = state.copyWith(keepScreenAwake: keep);
    StorageService.saveKeepScreenAwake(keep);
  }

  Future<void> updateWakelock(bool enable) async {
    try {
      if (!kIsWeb && state.keepScreenAwake && enable) {
        await WakelockPlus.enable();
      } else if (!kIsWeb) {
        await WakelockPlus.disable();
      }
    } catch (_) {}
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService();
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final audio = ref.watch(audioServiceProvider);
  final haptic = ref.watch(hapticServiceProvider);
  return SettingsNotifier(audioService: audio, hapticService: haptic);
});
