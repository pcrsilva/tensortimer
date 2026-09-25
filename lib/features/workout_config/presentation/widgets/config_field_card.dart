import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/utils/duration_formatter.dart';

class ConfigFieldCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int value;
  final bool isDurationSeconds;
  final IconData icon;
  final Color themeColor;
  final int step;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;
  final String? description;
  final ValueChanged<String?>? onDescriptionChanged;
  final List<int>? quickAddSteps;

  const ConfigFieldCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.isDurationSeconds = true,
    required this.icon,
    required this.themeColor,
    this.step = 5,
    this.minValue = 0,
    this.maxValue = 3600,
    required this.onChanged,
    this.description,
    this.onDescriptionChanged,
    this.quickAddSteps,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final haptic = HapticService();

    final String displayValue = isDurationSeconds
        ? DurationFormatter.formatSeconds(value)
        : '$value';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Ícone da fase com cor temática
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: themeColor, size: 22),
                ),
                const SizedBox(width: 12),

                // Título e Descrição
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Controles de Ajuste (- / Valor / +)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStepperButton(
                      context: context,
                      icon: Icons.remove_rounded,
                      onTap: value > minValue
                          ? () {
                              haptic.lightImpact();
                              onChanged((value - step).clamp(minValue, maxValue));
                            }
                          : null,
                    ),
                    const SizedBox(width: 8),

                    // Toque direto no valor para digitar
                    InkWell(
                      onTap: () => _showDirectInputDialog(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 64),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCardElevated
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: themeColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          displayValue,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: themeColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    _buildStepperButton(
                      context: context,
                      icon: Icons.add_rounded,
                      onTap: value < maxValue
                          ? () {
                              haptic.lightImpact();
                              onChanged((value + step).clamp(minValue, maxValue));
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Campo opcional de descrição do exercício/descanso
          if (onDescriptionChanged != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: TextFormField(
                initialValue: description,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Nome do exercício ou observação (opcional)',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary.withValues(alpha: 0.6)
                        : AppColors.lightTextSecondary.withValues(alpha: 0.6),
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkBackground
                      : const Color(0xFFF8FAFC),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                ),
                onChanged: onDescriptionChanged,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Chips de incremento rápido se houver
          if (quickAddSteps != null && quickAddSteps!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: quickAddSteps!.map((inc) {
                  return InkWell(
                    onTap: () {
                      haptic.lightImpact();
                      onChanged((value + inc).clamp(minValue, maxValue));
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBackground
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Text(
                        '+$inc${isDurationSeconds ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: onTap == null
                ? (isDark
                    ? AppColors.darkBackground.withValues(alpha: 0.5)
                    : const Color(0xFFE2E8F0).withValues(alpha: 0.5))
                : (isDark
                    ? AppColors.darkCardElevated
                    : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: onTap == null
                ? Colors.grey
                : (isDark ? Colors.white : AppColors.lightTextPrimary),
          ),
        ),
      ),
    );
  }

  void _showDirectInputDialog(BuildContext context) {
    final controller = TextEditingController(text: '$value');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Definir $title'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              suffixText: isDurationSeconds ? 'segundos' : 'unidades',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final int? parsed = int.tryParse(controller.text);
                if (parsed != null) {
                  onChanged(parsed.clamp(minValue, maxValue));
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
