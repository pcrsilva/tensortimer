# TensionTimer (TUT & Multi-Exercise Workout Timer) ⏱️⚡

O **TensionTimer** é um aplicativo mobile profissional desenvolvido em **Flutter** (com suporte nativo completo para **iOS** e **Android**) projetado especificamente para controle rigoroso de **Tempo sob Tensão (TUT - Time Under Tension)**, montagem de treinos personalizados multi-exercício, cadência de repetições em musculação, organização de rotinas por dia da semana e exibição contínua do cronômetro na **tela de bloqueio (Lock Screen)**.

---

## 🌟 Principais Diferenciais e Funcionalidades

### 1. 🏋️ Montador de Treinos Multi-Exercício Completo
Diferente de cronômetros intervalados convencionais que apenas repetem um único bloco genérico de tempo, o **TensionTimer** permite ao atleta/treinador **estruturar uma sessão completa de musculação**, prescrevendo individualmente cada exercício com sua própria cadência ou tempo fixo:

- **Exemplo de Sessão Completa no TensionTimer:**
  1. **Supino Reto:** Cadência `3030`, 8 repetições, 2 séries (descanso entre séries: 60s, transição: 90s)
  2. **Supino Inclinado:** Cadência `2020`, 10 repetições, 2 séries (descanso entre séries: 60s, transição: 90s)
  3. **Crucifixo:** Cadência `2020`, 20 repetições, 2 séries (descanso entre séries: 60s, transição: 90s)
  4. **Rosca Bíceps:** Tempo fixo de 40s de execução por série, 3 séries (descanso entre séries: 45s)

Ao iniciar, o aplicativo executa **todos esses exercícios de forma sequencial**, guiando o usuário com contagens de repetições, tempos de descanso e avisos de transição de exercício.

---

### 2. 📅 Cronograma Semanal de Treinos (Segunda a Domingo)
- **Atribuição Diária:** Salve e vincule um grupo de exercícios ou rotina específica para cada dia da semana (ex: *Segunda: Peito & Bíceps*, *Terça: Pernas Hipertrofia*, *Quarta: Descanso*, *Quinta: Costas & Tríceps*, etc.).
- **Destaque do Dia Atual:** Indicador visual inteligente com badge `[HOJE]` que realça automaticamente o dia da semana atual.
- **Sugestão em 1 Toque:** Banner de carregamento rápido para iniciar imediatamente o treino programado para hoje.
- **Persistência Local Instantânea:** Todas as rotinas e cronogramas ficam gravados no dispositivo via `SharedPreferences`.

---

### 3. 🔒 Execução em Segundo Plano e Tela de Bloqueio (Lock Screen)
O **TensionTimer** continua executando com precisão absoluta mesmo quando a tela do smartphone é desligada ou bloqueada (ideal para evitar acidentes e economizar bateria na academia):

- **Android (Notificação Fixa & Modo Cronômetro):**
  - Notificação pública de alta prioridade na tela de bloqueio (`NotificationVisibility.public`, `category: stopwatch`).
  - Atualização em tempo real a cada segundo: exibe o exercício atual, série, repetição, fase da cadência (ex: *Descida 2s*) e contagem regressiva total.
  - Permissões de serviço em primeiro plano (`FOREGROUND_SERVICE` e `WAKE_LOCK`).
- **iOS (Background Audio & Interrupções Sensíveis ao Tempo):**
  - Modo `UIBackgroundModes: ["audio"]` ativado no `Info.plist`, mantendo o timer ativo em background.
  - Bipes de contagem regressiva continuam soando normalmente com a tela apagada.
  - Notificações com nível `timeSensitive` e suporte a Atividades ao Vivo (`NSSupportsLiveActivities`).
- **Conclusão Automática:** Notificação de conquista `🏆 Treino Concluído!` ao finalizar a sessão.

---

### 4. 📐 A Fórmula da Cadência TUT (4 Dígitos)

A cadência padronizada de 4 dígitos define o tempo em segundos de cada uma das quatro fases do movimento:

$$\text{Duração da Repetição} = E (\text{Descida}) + I_1 (\text{Pausa Inf.}) + C (\text{Subida}) + I_2 (\text{Pausa Sup.})$$
$$\text{Tempo sob Tensão da Série} = (\text{Duração da Repetição}) \times \text{Número de Repetições}$$

#### Exemplo: Supino Reto em Cadência `3030` com 8 Repetições
- **$E$ (Fase Excêntrica / Descida):** 3 segundos
- **$I_1$ (Pausa Inferior):** 0 segundos
- **$C$ (Fase Concêntrica / Subida):** 3 segundos
- **$I_2$ (Pausa Superior):** 0 segundos
- **Duração por Repetição:** $3 + 0 + 3 + 0 = 6\text{ segundos}$
- **Tempo sob Tensão Total na Série:** $6\text{s} \times 8\text{ reps} = \mathbf{48\text{ segundos}}$

#### Visualização Durante a Execução:
1. **Fase Excêntrica (Descida):** O mostrador de cadência sobe de `0` até `3s` com badge verde neon ⬇️ **DESCIDA**.
2. **Fase Concêntrica (Subida):** O mostrador desce de `3s` até `0` com badge azul esportivo ⬆️ **SUBIDA**.
3. **Indicador de Repetições:** Exibe `REP X DE Y` (ex: `REP 1 DE 8`).
4. **Badges de Contexto:** Exibe `EXERCÍCIO X DE Y: [Nome]` e `SÉRIE X DE Y`.
5. **Transições:** Mensagens claras para início de descanso e próxima série/exercício.

---

### 5. 🔊 Sistema de Áudio e Feedback Háptico

- **Avisos Sonoros em 3, 2, 1:** Toca bipes nítidos exclusivamente quando faltam **3 segundos** para o término da **Preparação**, da **Série de Trabalho** e do **Descanso**.
- **Foco e Silêncio na Execução:** Sem sons repetitivos durante a execução das repetições, garantindo máxima concentração e foco no movimento.
- **Sessão de Áudio em Background:** Configurado com `AVAudioSessionCategory.playback` e `gainTransientMayDuck` para tocar mesmo com a chave de silencioso do iPhone ativada.
- **Vibração Tátil Sincronizada:** Vibrações táteis acompanham os bipes finais e a conclusão do treino.

---

## 🎨 Design System & Estética Esportiva

- **Paleta Dark OLED:** Fundo em preto absoluto (`#0A0E1A`), cinza titânio (`#1E293B`) e acentos neon Laranja Alta Tensão (`#FF5722`), Verde Sucesso (`#10B981`) e Ciano Concêntrico (`#06B6D4`).
- **Tipografia:** Fonte moderna esportiva Google Fonts `Outfit`.
- **Ícone Oficial:** Ícone inovador estilizado com cronômetro de precisão, ondas de tensão muscular e gradiente neon.

---

## 📂 Estrutura do Projeto (*Feature-First Clean Architecture*)

```
tensortimer/
├── assets/
│   ├── audio/                          # Bipes de contagem regressiva e efeitos em WAV
│   └── icon/                           # Ícones oficiais do aplicativo (1024x1024)
├── android/                            # Configurações nativas Android, Permissões e Manifest
├── ios/                                # Configurações nativas iOS, Info.plist e Audio Background
├── lib/
│   ├── main.dart                       # Ponto de entrada com ProviderScope e inicialização
│   ├── core/
│   │   ├── constants/app_colors.dart   # Design tokens e paleta esportiva
│   │   ├── theme/app_theme.dart        # Tema Dark/Light e tipografia Outfit
│   │   ├── utils/                      # Formatadores de duração e síntese de áudio
│   │   └── services/                   # AudioService, HapticService, LockScreenService
│   └── features/
│       ├── workout_config/             # Configuração de Exercícios, Cronograma e Presets
│       │   ├── models/                 # WorkoutConfig, ExerciseConfig, CadenceInfo, WeekdaySchedule
│       │   ├── providers/              # WorkoutConfigNotifier, PresetsNotifier, ScheduleNotifier
│       │   └── presentation/           # WorkoutConfigScreen, WeekdayScheduleBar, ExerciseCard
│       └── workout_execution/          # Execução e Cronometragem Ativa
│           ├── models/                 # WorkoutTimerState, CadenceProgress, IntervalStep
│           ├── providers/              # WorkoutTimerEngine (Ticker 50ms imune a drift)
│           └── presentation/           # WorkoutExecutionScreen, CadenceDisplay
└── test/                               # Testes unitários de motor, cálculo de TUT e widgets
```

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
- Flutter SDK 3.x instalado.
- Dispositivo físico ou emulador (Android / iOS / macOS).

### Passo a Passo

1. **Clonar o Repositório:**
   ```bash
   git clone https://github.com/pcrsilva/tensortimer.git
   cd tensortimer
   ```

2. **Instalar Dependências:**
   ```bash
   flutter pub get
   ```

3. **Executar a Suíte de Testes Automatizados:**
   ```bash
   flutter test
   ```

4. **Verificar a Análise Estática de Código:**
   ```bash
   flutter analyze
   ```

5. **Iniciar a Aplicação:**
   ```bash
   flutter run
   ```

---

## 📄 Licença
Desenvolvido por **Paulo Cezar Rodrigues da Silva** (<engenheiro.paulo.cezar@gmail.com>).
Todos os direitos reservados.
