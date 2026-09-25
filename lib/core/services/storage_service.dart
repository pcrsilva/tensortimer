import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/workout_config/models/workout_config.dart';
import '../../features/workout_config/models/workout_preset.dart';

/// Serviço de persistência local para presets de treinos e preferências
class StorageService {
  static const String _keyActiveConfig = 'tensortimer_active_config';
  static const String _keyCustomPresets = 'tensortimer_custom_presets';
  static const String _keySoundEnabled = 'tensortimer_sound_enabled';
  static const String _keyHapticEnabled = 'tensortimer_haptic_enabled';
  static const String _keyKeepScreenAwake = 'tensortimer_keep_screen_awake';
  static const String _keyVolume = 'tensortimer_volume';

  static Future<void> saveActiveConfig(WorkoutConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActiveConfig, jsonEncode(config.toJson()));
  }

  static Future<WorkoutConfig?> loadActiveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyActiveConfig);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return WorkoutConfig.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> savePresets(List<WorkoutPreset> presets) async {
    final prefs = await SharedPreferences.getInstance();
    final list = presets.map((p) => p.toJson()).toList();
    await prefs.setString(_keyCustomPresets, jsonEncode(list));
  }

  static Future<List<WorkoutPreset>> loadPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCustomPresets);
    if (raw == null) {
      return WorkoutPreset.defaultPresets;
    }
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((item) => WorkoutPreset.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return WorkoutPreset.defaultPresets;
    }
  }

  static Future<bool> loadSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySoundEnabled) ?? true;
  }

  static Future<void> saveSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySoundEnabled, enabled);
  }

  static Future<bool> loadHapticEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHapticEnabled) ?? true;
  }

  static Future<void> saveHapticEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHapticEnabled, enabled);
  }

  static Future<bool> loadKeepScreenAwake() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyKeepScreenAwake) ?? true;
  }

  static Future<void> saveKeepScreenAwake(bool keep) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyKeepScreenAwake, keep);
  }

  static Future<double> loadVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyVolume) ?? 1.0;
  }

  static Future<void> saveVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyVolume, volume);
  }
}
