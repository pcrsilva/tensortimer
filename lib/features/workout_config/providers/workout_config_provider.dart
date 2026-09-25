import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/storage_service.dart';
import '../models/cadence_info.dart';
import '../models/exercise_config.dart';
import '../models/work_mode.dart';
import '../models/workout_config.dart';

/// StateNotifier para gerenciar a configuração ativa de treino com múltiplos exercícios
class WorkoutConfigNotifier extends StateNotifier<WorkoutConfig> {
  WorkoutConfigNotifier() : super(const WorkoutConfig(id: 'default_config')) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final saved = await StorageService.loadActiveConfig();
    if (saved != null) {
      state = saved;
    }
  }

  void updateConfig(WorkoutConfig newConfig) {
    state = newConfig;
    StorageService.saveActiveConfig(state);
  }

  void setWorkoutName(String name) {
    state = state.copyWith(name: name.trim().isEmpty ? 'Meu Treino TUT' : name);
    StorageService.saveActiveConfig(state);
  }

  void setPrepareSeconds(int seconds) {
    state = state.copyWith(prepareSeconds: seconds.clamp(0, 600));
    StorageService.saveActiveConfig(state);
  }

  void setCoolDownSeconds(int seconds) {
    state = state.copyWith(coolDownSeconds: seconds.clamp(0, 1800));
    StorageService.saveActiveConfig(state);
  }

  /// Adiciona um novo exercício à lista
  void addExercise({ExerciseConfig? exercise}) {
    final newExercise = exercise ??
        ExerciseConfig(
          id: const Uuid().v4(),
          name: 'Exercício ${state.exercises.length + 1}',
          workMode: WorkMode.cadence,
          cadenceInfo: const CadenceInfo(
            eccentricSeconds: 3,
            isometric1Seconds: 0,
            concentricSeconds: 3,
            isometric2Seconds: 0,
            targetReps: 8,
          ),
          sets: 3,
          restBetweenSetsSeconds: 60,
          restAfterExerciseSeconds: 90,
        );

    final updated = List<ExerciseConfig>.from(state.exercises)..add(newExercise);
    state = state.copyWith(exercises: updated);
    StorageService.saveActiveConfig(state);
  }

  /// Remove um exercício pelo ID
  void removeExercise(String id) {
    if (state.exercises.length <= 1) {
      return; // Mantém pelo menos 1 exercício
    }
    final updated = state.exercises.where((e) => e.id != id).toList();
    state = state.copyWith(exercises: updated);
    StorageService.saveActiveConfig(state);
  }

  /// Atualiza os parâmetros de um exercício específico
  void updateExercise(ExerciseConfig updatedExercise) {
    final updatedList = state.exercises.map((e) {
      return e.id == updatedExercise.id ? updatedExercise : e;
    }).toList();

    state = state.copyWith(exercises: updatedList);
    StorageService.saveActiveConfig(state);
  }

  /// Reordena exercícios (Drag & Drop)
  void reorderExercises(int oldIndex, int newIndex) {
    final list = List<ExerciseConfig>.from(state.exercises);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    state = state.copyWith(exercises: list);
    StorageService.saveActiveConfig(state);
  }

  /// Duplica um exercício existente
  void duplicateExercise(String id) {
    final index = state.exercises.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final original = state.exercises[index];
    final duplicated = original.copyWith(
      id: const Uuid().v4(),
      name: '${original.name} (Cópia)',
    );

    final list = List<ExerciseConfig>.from(state.exercises);
    list.insert(index + 1, duplicated);

    state = state.copyWith(exercises: list);
    StorageService.saveActiveConfig(state);
  }

  /// Carrega configuração a partir de um Preset
  void loadFromPreset(WorkoutConfig config) {
    state = config.copyWith(id: const Uuid().v4());
    StorageService.saveActiveConfig(state);
  }

  /// Restaura o treino padrão inicial
  void resetToDefault() {
    state = const WorkoutConfig(id: 'default_config');
    StorageService.saveActiveConfig(state);
  }
}

final workoutConfigProvider =
    StateNotifierProvider<WorkoutConfigNotifier, WorkoutConfig>((ref) {
  return WorkoutConfigNotifier();
});
