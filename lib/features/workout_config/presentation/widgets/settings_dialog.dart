import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/settings_provider.dart';

class SettingsDialog extends ConsumerWidget {
  const SettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: AppColors.brandPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Configurações do Timer',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Som & Efeitos
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Avisos Sonoros (Bipes em 3, 2, 1)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: const Text(
                    'Toca nos 3s finais da preparação, término da série e descanso',
                    style: TextStyle(fontSize: 12)),
                value: settings.isSoundEnabled,
                activeTrackColor: AppColors.brandPrimary,
                onChanged: settingsNotifier.toggleSound,
              ),

              if (settings.isSoundEnabled) ...[
                Row(
                  children: [
                    const Icon(Icons.volume_down, size: 18),
                    Expanded(
                      child: Slider(
                        value: settings.volume,
                        min: 0.1,
                        max: 1.0,
                        activeColor: AppColors.brandPrimary,
                        onChanged: settingsNotifier.setVolume,
                      ),
                    ),
                    const Icon(Icons.volume_up, size: 18),
                  ],
                ),
                const SizedBox(height: 4),
              ],

              // Vibração Háptica
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Feedback Tátil / Vibração',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: const Text('Vibrações sincronizadas com a cadência',
                    style: TextStyle(fontSize: 12)),
                value: settings.isHapticEnabled,
                activeTrackColor: AppColors.brandPrimary,
                onChanged: settingsNotifier.toggleHaptic,
              ),

              // Manter Tela Ligada
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Manter Tela Sempre Ligada',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: const Text('Impede bloqueio automático durante o treino',
                    style: TextStyle(fontSize: 12)),
                value: settings.keepScreenAwake,
                activeTrackColor: AppColors.brandPrimary,
                onChanged: settingsNotifier.toggleKeepScreenAwake,
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Concluído',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
