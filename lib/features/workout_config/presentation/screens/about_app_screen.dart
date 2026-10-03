import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/settings_dialog.dart';

/// Modelo de categoria de funcionalidade
class FeatureCategory {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<FeatureItem> items;

  const FeatureCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.items,
  });
}

/// Modelo de item de funcionalidade
class FeatureItem {
  final String title;
  final String description;
  final List<String> highlights;
  final IconData? icon;

  const FeatureItem({
    required this.title,
    required this.description,
    required this.highlights,
    this.icon,
  });
}

/// Tela completa e interativa de "Sobre o App & Guia de Funcionalidades" do TensionTimer
class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  static void show(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AboutAppScreen(),
      ),
    );
  }

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Todas';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FeatureCategory> _getFeatureCategories() {
    return [
      const FeatureCategory(
        title: 'Tempo sob Tensão (TUT)',
        subtitle: 'Metodologia científica para hipertrofia máxima',
        icon: Icons.speed_rounded,
        color: AppColors.work,
        items: [
          FeatureItem(
            title: 'O que é o Tempo sob Tensão (TUT)?',
            description:
                'O TUT (Time Under Tension) mede o tempo total em que as fibras musculares permanecem sob contração mecânica durante uma série. Controlar a velocidade de execução é comprovadamente um dos estímulos mais potentes para hipertrofia, força e integridade articular.',
            highlights: [
              'Controle do estímulo hipertrófico',
              'Maior recrutamento de unidades motoras',
              'Eliminação do impulso e "roubo" no movimento',
            ],
            icon: Icons.fitness_center_rounded,
          ),
          FeatureItem(
            title: 'Cálculo Dinâmico da Sessão',
            description:
                'O aplicativo calcula em tempo real o tempo sob tensão de cada repetição, o tempo total de esforço de cada série e a estimativa de duração completa do treino (soma de séries, preparações, descansos e transições).',
            highlights: [
              'Tempo sob tensão por série em segundos',
              'Proporção exata de esforço vs. descanso',
              'Duração total da sessão estimada ao vivo',
            ],
            icon: Icons.calculate_outlined,
          ),
        ],
      ),
      const FeatureCategory(
        title: 'Montador Multi-Exercício',
        subtitle: 'Estruture sessões completas de musculação',
        icon: Icons.playlist_add_check_rounded,
        color: Color(0xFF0EA5E9),
        items: [
          FeatureItem(
            title: 'Rotinas Sequenciais Completas',
            description:
                'Ao contrário de cronômetros convencionais que repetem apenas 1 bloco genérico, o TensionTimer permite adicionar múltiplos exercícios em sequência (ex: Supino Reto, Supino Inclinado, Crucifixo e Tríceps). O app executa tudo automaticamente.',
            highlights: [
              'Adição de múltiplos exercícios por treino',
              'Execução contínua sem interrupções',
              'Indicação clara da etapa e do próximo exercício',
            ],
            icon: Icons.format_list_numbered_rounded,
          ),
          FeatureItem(
            title: 'Configuração Individualizada por Exercício',
            description:
                'Cada exercício pode ser personalizado com seu próprio número de séries, repetições, cadência de 4 dígitos (ou tempo fixo de execução), tempo de descanso entre séries e intervalo de transição para o próximo aparelho.',
            highlights: [
              'Séries e repetições independentes',
              'Modo Cadência TUT ou Tempo Fixo em segundos',
              'Descanso entre séries e transição de exercício',
            ],
            icon: Icons.tune_rounded,
          ),
          FeatureItem(
            title: 'Controles Rápidos de Ajuste (+/-)',
            description:
                'Botões de toque rápido permitem aumentar ou diminuir séries, repetições e tempos em passos de 5s, 10s ou 15s sem necessidade de abrir telas complexas.',
            highlights: [
              'Ajuste rápido com feedback tátil',
              'Incrementos inteligentes de tempo e reps',
              'Reordenação e exclusão intuitivas',
            ],
            icon: Icons.touch_app_outlined,
          ),
        ],
      ),
      const FeatureCategory(
        title: 'Fórmula de Cadência (4 Dígitos)',
        subtitle: 'Padronização internacional das fases do movimento',
        icon: Icons.timelapse_rounded,
        color: Color(0xFFF59E0B),
        items: [
          FeatureItem(
            title: 'Significado dos 4 Dígitos (E - I1 - C - I2)',
            description:
                'A cadência padronizada define a duração em segundos de cada uma das 4 fases do movimento muscular:\n'
                '• 1º Dígito (E - Excêntrica): Tempo descendo o peso (alongamento).\n'
                '• 2º Dígito (I1 - Pausa Inferior): Isometria no ponto mais baixo.\n'
                '• 3º Dígito (C - Concêntrica): Tempo subindo o peso (contração).\n'
                '• 4º Dígito (I2 - Pausa Superior): Isometria no pico de contração.',
            highlights: [
              'Exemplo 3030 = 3s descida, 0s pausa, 3s subida, 0s pausa (6s/rep)',
              'Exemplo 4010 = 4s descida lenta e 1s subida explosiva (5s/rep)',
              'Exemplo 2121 = 2s descida, 1s pausa, 2s subida, 1s pico (6s/rep)',
            ],
            icon: Icons.menu_book_rounded,
          ),
          FeatureItem(
            title: 'Animação Visual e Direcional',
            description:
                'Durante a série, o mostrador exibe badges direcionais coloridos orientando o ritmo ideal de contração: Descida (verde esmeralda), Subida (azul/ciano) e Pausas (âmbar).',
            highlights: [
              'Contagem progressiva na fase excêntrica (0 ➔ E)',
              'Contagem regressiva na fase concêntrica (C ➔ 0)',
              'Indicação clara da repetição atual (ex: REP 3 DE 10)',
            ],
            icon: Icons.visibility_outlined,
          ),
        ],
      ),
      const FeatureCategory(
        title: 'Cronograma Semanal',
        subtitle: 'Organização de fichas de Segunda a Domingo',
        icon: Icons.calendar_month_rounded,
        color: Color(0xFF8B5CF6),
        items: [
          FeatureItem(
            title: 'Fichas Diárias Personalizadas',
            description:
                'Vincule fichas de treino para cada dia da semana (ex: Segunda: Peito & Tríceps, Terça: Costas & Bíceps, Quarta: Pernas, etc.). As rotinas ficam salvas localmente no seu aparelho.',
            highlights: [
              'Fichas independentes de Segunda a Domingo',
              'Destaque automático do dia atual [HOJE]',
              'Carregamento instantâneo em 1 toque',
            ],
            icon: Icons.today_rounded,
          ),
          FeatureItem(
            title: 'Biblioteca de Presets e Rotinas Salvas',
            description:
                'Acesse presets de cadências consagradas na musculação ou salve suas próprias rotinas personalizadas para reutilizar quando quiser.',
            highlights: [
              'Presets prontos (Hipertrofia, Força, Resistência)',
              'Salvar rotinas com nomes personalizados',
              'Exportação e restauração local',
            ],
            icon: Icons.bookmarks_outlined,
          ),
        ],
      ),
      const FeatureCategory(
        title: 'Áudio & Segundo Plano',
        subtitle: 'Treine com a tela apagada e som inteligente',
        icon: Icons.notifications_active_rounded,
        color: Color(0xFF06B6D4),
        items: [
          FeatureItem(
            title: 'Bipes Estratégicos (3, 2, 1 Segundos)',
            description:
                'Para manter sua concentração máxima durante o esforço físico, o app não emite sons contínuos durante as repetições. Os bipes nítidos tocam exclusivamente nos 3 segundos finais de preparação, séries e descansos.',
            highlights: [
              'Foco total sem poluição sonora',
              'Avisos precisos de transição em 3, 2, 1',
              'Controle de volume e opção de silenciar',
            ],
            icon: Icons.volume_up_rounded,
          ),
          FeatureItem(
            title: 'Execução em Segundo Plano & Lock Screen',
            description:
                'Com suporte nativo a áudio em segundo plano (UIBackgroundModes) e notificações no Android e iOS, o cronômetro continua ativo mesmo com o celular bloqueado no bolso.',
            highlights: [
              'Notificação viva com tempo restante na Lock Screen',
              'Bipes audíveis mesmo com o aparelho bloqueado',
              'Economia máxima de bateria na academia',
            ],
            icon: Icons.lock_clock_rounded,
          ),
          FeatureItem(
            title: 'Feedback Tátil / Vibração Háptica',
            description:
                'Sinta pulsos de vibração física no dispositivo que acompanham as contagens regressivas e o término de cada série ou treino.',
            highlights: [
              'Pulsos táteis sincronizados',
              'Ideal para ambientes com música alta na academia',
              'Habilitação/desabilitação nas configurações',
            ],
            icon: Icons.vibration_rounded,
          ),
        ],
      ),
      const FeatureCategory(
        title: 'Privacidade & Segurança',
        subtitle: 'Seus dados 100% locais no seu dispositivo',
        icon: Icons.security_rounded,
        color: Color(0xFF10B981),
        items: [
          FeatureItem(
            title: '100% Offline e Sem Necessidade de Cadastro',
            description:
                'O TensionTimer não requer internet, criação de conta, e-mail ou senhas. Todas as configurações, cronogramas e rotinas são mantidos exclusivamente na memória local do seu smartphone.',
            highlights: [
              'Zero coleta ou transmissão de dados pessoais',
              'Sem rastreadores ou telemetria invasiva',
              'Sem anúncios ou propagandas',
            ],
            icon: Icons.shield_outlined,
          ),
          FeatureItem(
            title: 'Aviso de Saúde & Exercício Físico',
            description:
                'O TensionTimer é uma ferramenta de auxílio para cronometragem esportiva. Recomendamos sempre a orientação de um profissional de educação física ou médico antes de iniciar novos programas de treinamento intenso.',
            highlights: [
              'Conformidade com diretrizes de saúde Apple',
              'Foco na segurança e correta execução biomecânica',
            ],
            icon: Icons.health_and_safety_outlined,
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allCategories = _getFeatureCategories();

    // Filtro por texto de busca e por categoria
    final query = _searchQuery.toLowerCase().trim();

    final filteredCategories = allCategories.map((cat) {
      if (_selectedCategory != 'Todas' && cat.title != _selectedCategory) {
        return null;
      }

      if (query.isEmpty) {
        return cat;
      }

      final matchedItems = cat.items.where((item) {
        final inTitle = item.title.toLowerCase().contains(query);
        final inDesc = item.description.toLowerCase().contains(query);
        final inHighlights =
            item.highlights.any((h) => h.toLowerCase().contains(query));
        return inTitle || inDesc || inHighlights;
      }).toList();

      if (matchedItems.isEmpty) return null;

      return FeatureCategory(
        title: cat.title,
        subtitle: cat.subtitle,
        icon: cat.icon,
        color: cat.color,
        items: matchedItems,
      );
    }).whereType<FeatureCategory>().toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Sobre o TensionTimer',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configurações',
            onPressed: () => SettingsDialog.show(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Hero Header do App
          _buildHeroHeader(isDark),

          const SizedBox(height: 16),

          // 2. Campo de Busca
          _buildSearchBar(isDark),

          const SizedBox(height: 12),

          // 3. Chips de Categorias
          _buildCategoryChips(isDark, allCategories),

          const SizedBox(height: 16),

          // 4. Lista de Categorias e Funcionalidades
          if (filteredCategories.isEmpty)
            _buildEmptySearch(isDark)
          else
            ...filteredCategories.map((cat) => _buildCategorySection(isDark, cat)),

          const SizedBox(height: 20),

          // 5. Card de Isenção de Saúde & Rodapé
          _buildFooter(isDark),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String get _searchQuery => _searchController.text;

  Widget _buildHeroHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF0F2027),
                  const Color(0xFF203A43),
                  const Color(0xFF2C5364),
                ]
              : [
                  const Color(0xFF0284C7),
                  const Color(0xFF0369A1),
                  const Color(0xFF075985),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF0284C7))
                .withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  color: Color(0xFF38BDF8),
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'TensionTimer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'v1.0.0',
                          style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tempo sob Tensão (TUT) e Treinos de Musculação',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _HeaderBadge(
                  icon: Icons.speed_rounded,
                  label: 'Cadência TUT',
                  color: Color(0xFF38BDF8),
                ),
                _HeaderBadge(
                  icon: Icons.playlist_add_check_rounded,
                  label: 'Multi-Exercício',
                  color: Color(0xFF4ADE80),
                ),
                _HeaderBadge(
                  icon: Icons.shield_outlined,
                  label: '100% Offline',
                  color: Color(0xFFFBBF24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Pesquisar funcionalidade ou conceito...',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
            : null,
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(
      bool isDark, List<FeatureCategory> allCategories) {
    final categories = ['Todas', ...allCategories.map((c) => c.title)];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final catName = categories[index];
          final isSelected = _selectedCategory == catName;

          return FilterChip(
            selected: isSelected,
            label: Text(
              catName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
            ),
            selectedColor: AppColors.brandPrimary,
            backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            side: BorderSide(
              color: isSelected
                  ? AppColors.brandPrimary
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onSelected: (_) {
              setState(() {
                _selectedCategory = catName;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(bool isDark, FeatureCategory cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cat.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(cat.icon, color: cat.color, size: 20),
            ),
            title: Text(
              cat.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
              cat.subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            children: cat.items.map((item) => _buildFeatureItemCard(isDark, item, cat.color)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItemCard(bool isDark, FeatureItem item, Color accentColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBackground.withValues(alpha: 0.6)
            : AppColors.lightCardElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.icon, size: 16, color: accentColor),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
          if (item.highlights.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: item.highlights.map((h) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 11, color: accentColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          h,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptySearch(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 12),
          const Text(
            'Nenhuma funcionalidade encontrada',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Tente buscar por termos como "cadência", "TUT", "séries", "áudio" ou "lock screen".',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.4)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.health_and_safety_outlined,
                  size: 18, color: AppColors.prepare),
              SizedBox(width: 8),
              Text(
                'Aviso Legal & Saúde',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'O TensionTimer é um aplicativo voltado exclusivamente à cronometragem esportiva e suporte ao treinamento. Sempre consulte um médico e um profissional de educação física habilitado antes de iniciar rotinas de exercícios de alta intensidade.',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.35,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'TensionTimer • Versão 1.0.0 (Build 1)\nDesenvolvido com foco em alta performance e privacidade.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HeaderBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
