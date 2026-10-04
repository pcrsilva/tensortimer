import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/exercise_config.dart';
import 'exercise_card.dart';

/// Carrossel interativo e moderno para configuração dos exercícios do treino
class ExerciseCarousel extends StatefulWidget {
  final List<ExerciseConfig> exercises;
  final ValueChanged<ExerciseConfig> onExerciseChanged;
  final ValueChanged<String> onDuplicateExercise;
  final ValueChanged<String> onDeleteExercise;
  final VoidCallback onAddExercise;

  const ExerciseCarousel({
    super.key,
    required this.exercises,
    required this.onExerciseChanged,
    required this.onDuplicateExercise,
    required this.onDeleteExercise,
    required this.onAddExercise,
  });

  @override
  State<ExerciseCarousel> createState() => _ExerciseCarouselState();
}

class _ExerciseCarouselState extends State<ExerciseCarousel> {
  late PageController _pageController;
  final ScrollController _tabScrollController = ScrollController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void didUpdateWidget(covariant ExerciseCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.exercises.length > oldWidget.exercises.length) {
      // Novo exercício adicionado: navega para a última página
      final newIndex = widget.exercises.length - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _goToPage(newIndex);
        }
      });
    } else if (_currentPage >= widget.exercises.length) {
      // Exercício removido: ajusta para o índice válido mais próximo
      final validIndex = (widget.exercises.length - 1).clamp(0, 999);
      setState(() {
        _currentPage = validIndex;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(validIndex);
          _scrollToTab(validIndex);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page < 0 || page >= widget.exercises.length) return;
    setState(() {
      _currentPage = page;
    });
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
    _scrollToTab(page);
  }

  void _scrollToTab(int index) {
    if (!_tabScrollController.hasClients) return;
    // Largura aproximada por chip para centralizar suavemente
    const chipWidth = 140.0;
    final targetOffset = (index * chipWidth) - 40;
    _tabScrollController.animateTo(
      targetOffset.clamp(0.0, _tabScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = widget.exercises.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Cabeçalho da Seção com Contador e Botão Adicionar
        _buildSectionHeader(isDark, total),

        const SizedBox(height: 8),

        // 2. Barra de Abas Horizontais (Chips dos Exercícios)
        _buildExerciseTabsBar(isDark, total),

        const SizedBox(height: 10),

        // 3. Barra de Navegação do Carrossel (Setas < > e Indicador de Páginas)
        _buildNavigationControls(isDark, total),

        const SizedBox(height: 8),

        // 4. Carrossel de Cards de Exercício (PageView)
        SizedBox(
          height: 785,
          child: PageView.builder(
            controller: _pageController,
            itemCount: total,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              _scrollToTab(index);
            },
            itemBuilder: (context, index) {
              final ex = widget.exercises[index];
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ExerciseCard(
                  key: ValueKey(ex.id),
                  index: index + 1,
                  totalExercises: total,
                  exercise: ex,
                  margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  onChanged: widget.onExerciseChanged,
                  onDuplicate: () => widget.onDuplicateExercise(ex.id),
                  onDelete: () => widget.onDeleteExercise(ex.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(bool isDark, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'EXERCÍCIOS DO TREINO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.brandPrimary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '${_currentPage + 1} de $total',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandPrimary,
                ),
              ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: widget.onAddExercise,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Adicionar'),
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: AppColors.brandPrimary,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseTabsBar(bool isDark, int total) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        controller: _tabScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: total + 1, // +1 para o botão de adicionar no final
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == total) {
            // Chip de ação rápida para adicionar novo exercício
            return ActionChip(
              avatar: const Icon(Icons.add_rounded, size: 16, color: AppColors.brandPrimary),
              label: const Text(
                'Novo',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandPrimary,
                ),
              ),
              backgroundColor: isDark
                  ? AppColors.darkCardElevated
                  : AppColors.lightCardElevated,
              side: BorderSide(
                color: AppColors.brandPrimary.withValues(alpha: 0.4),
                style: BorderStyle.solid,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onPressed: widget.onAddExercise,
            );
          }

          final ex = widget.exercises[index];
          final isSelected = _currentPage == index;

          return InkWell(
            onTap: () => _goToPage(index),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.brandPrimary
                    : (isDark ? AppColors.darkCard : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.brandPrimary
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.brandPrimary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.25)
                          : AppColors.brandPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : AppColors.brandPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 130),
                    child: Text(
                      ex.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationControls(bool isDark, int total) {
    final canGoPrev = _currentPage > 0;
    final canGoNext = _currentPage < total - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCardElevated.withValues(alpha: 0.5)
            : AppColors.lightCardElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botão Anterior (<)
          InkWell(
            onTap: canGoPrev ? () => _goToPage(_currentPage - 1) : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: canGoPrev
                    ? (isDark ? AppColors.darkCard : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: canGoPrev
                      ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_left_rounded,
                    size: 18,
                    color: canGoPrev
                        ? AppColors.brandPrimary
                        : (isDark ? Colors.white24 : Colors.black26),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Anterior',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: canGoPrev
                          ? (isDark ? Colors.white : AppColors.lightTextPrimary)
                          : (isDark ? Colors.white24 : Colors.black26),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Indicadores de Pontos (Dots / Pills)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(total, (dotIndex) {
              final isDotSelected = _currentPage == dotIndex;
              return GestureDetector(
                onTap: () => _goToPage(dotIndex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isDotSelected ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: isDotSelected
                        ? AppColors.brandPrimary
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),

          // Botão Próximo (>)
          InkWell(
            onTap: canGoNext ? () => _goToPage(_currentPage + 1) : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: canGoNext
                    ? (isDark ? AppColors.darkCard : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: canGoNext
                      ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Próximo',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: canGoNext
                          ? (isDark ? Colors.white : AppColors.lightTextPrimary)
                          : (isDark ? Colors.white24 : Colors.black26),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: canGoNext
                        ? AppColors.brandPrimary
                        : (isDark ? Colors.white24 : Colors.black26),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
