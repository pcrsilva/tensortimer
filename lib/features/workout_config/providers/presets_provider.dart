import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/storage_service.dart';
import '../models/workout_config.dart';
import '../models/workout_preset.dart';

class PresetsNotifier extends StateNotifier<List<WorkoutPreset>> {
  PresetsNotifier() : super(WorkoutPreset.defaultPresets) {
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    final list = await StorageService.loadPresets();
    state = list;
  }

  Future<void> saveCurrentAsPreset({
    required WorkoutConfig config,
    required String name,
    required String description,
    required String iconEmoji,
    List<int> scheduledDays = const [],
  }) async {
    final newPreset = WorkoutPreset(
      id: const Uuid().v4(),
      name: name,
      description: description,
      iconEmoji: iconEmoji,
      config: config,
      isDefault: false,
      scheduledDays: scheduledDays,
      createdAt: DateTime.now(),
    );

    state = [newPreset, ...state];
    await StorageService.savePresets(state);
  }

  Future<void> updatePreset(WorkoutPreset updated) async {
    state = state.map((p) => p.id == updated.id ? updated : p).toList();
    await StorageService.savePresets(state);
  }

  Future<void> duplicatePreset(WorkoutPreset preset) async {
    final duplicated = WorkoutPreset(
      id: const Uuid().v4(),
      name: '${preset.name} (Cópia)',
      description: preset.description,
      iconEmoji: preset.iconEmoji,
      config: preset.config.copyWith(id: const Uuid().v4()),
      isDefault: false,
      scheduledDays: preset.scheduledDays,
      createdAt: DateTime.now(),
    );

    state = [duplicated, ...state];
    await StorageService.savePresets(state);
  }

  Future<void> deletePreset(String id) async {
    state = state.where((p) => p.id != id || p.isDefault).toList();
    await StorageService.savePresets(state);
  }

  Future<void> restoreDefaults() async {
    state = WorkoutPreset.defaultPresets;
    await StorageService.savePresets(state);
  }
}

final presetsProvider =
    StateNotifierProvider<PresetsNotifier, List<WorkoutPreset>>((ref) {
  return PresetsNotifier();
});
