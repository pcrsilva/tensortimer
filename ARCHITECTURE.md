# Arquitetura Técnica do TensionTimer 🏗️

Este documento detalha as decisões de engenharia de software, modelos matemáticos, compilação de linha do tempo linear multi-exercício, ciclo de vida do temporizador e suporte à tela de bloqueio do aplicativo **TensionTimer**.

---

## 1. Estrutura Multi-Exercício e Compilação da Linha do Tempo

O **TensionTimer** adota uma abordagem modular de treino, onde uma rotina completa (`WorkoutConfig`) é composta por uma lista ordenada de exercícios individuais (`ExerciseConfig`).

### Hierarquia de Entidades:
- **`WorkoutConfig`**:
  - `id`, `name`: Identificador e nome do treino (ex: "Peito & Bíceps TUT").
  - `prepareSeconds`: Aquecimento/preparação inicial antes do 1º exercício.
  - `exercises`: Lista de `ExerciseConfig`.
  - `coolDownSeconds`: Volta à calma e desaquecimento final.
- **`ExerciseConfig`**:
  - `id`, `name`: Identificador e nome do exercício (ex: "Supino Reto", "Rosca Bíceps").
  - `workMode`: `WorkMode.cadence` (Cadência TUT) ou `WorkMode.time` (Tempo Fixo).
  - `cadenceInfo`: Cadência de 4 dígitos ($E - I_1 - C - I_2$) e repetições alvo.
  - `workSeconds`: Duração em segundos (utilizado quando `workMode == WorkMode.time`).
  - `sets`: Quantidade de séries do exercício.
  - `restBetweenSetsSeconds`: Descanso curto/médio entre séries do mesmo exercício.
  - `restAfterExerciseSeconds`: Descanso/transição maior ao concluir este exercício antes do próximo.

### Algoritmo de Compilação da Timeline (`compileTimeline()`):
O método lineariza o treino completo em uma sequência contínua e imutável de `IntervalStep`:
1. **Passo 1 (Preparação Inicial):** `WorkoutPhase.prepare` com aviso do 1º exercício.
2. **Para cada exercício $i$ na lista:**
   - **Para cada série $s$ de 1 até `sets`:**
     - Passo de Trabalho: `WorkoutPhase.work` com metadados do exercício ($i$ de $N$), série ($s$ de $S$) e cadência ativa.
     - Se $s < \text{sets}$ e houver descanso entre séries: Passo `WorkoutPhase.rest` ("Descanso: [Nome do Exercício]").
   - Se houver próximo exercício ($i < N$) e houver descanso pós-exercício: Passo `WorkoutPhase.restBetweenSets` ("Troca de Exercício: Próximo: [Nome]").
3. **Passo Final (Volta à Calma):** `WorkoutPhase.coolDown` se configurado.

---

## 2. Modelo de Cadência e Tempo sob Tensão (TUT)

No treinamento resistido, a cadência é padronizada em 4 etapas cronológicas:
- **E (Excêntrica):** Alongamento muscular sob carga (descida do peso).
- **I1 (Isométrica 1):** Transição e máxima extensão muscular (ponto de inversão inferior).
- **C (Concêntrica):** Encurtamento muscular e superação da carga (subida do peso).
- **I2 (Isométrica 2):** Pico de contração no topo do movimento.

### Fórmulas Matemáticas

$$\text{Tempo de 1 Repetição} (T_{\text{rep}}) = E + I_1 + C + I_2$$
$$\text{Tempo sob Tensão da Série} (T_{\text{work}}) = T_{\text{rep}} \times R$$

Onde $R$ é a quantidade de repetições prescritas na série.

### Cálculo da Sub-fase no Ticker em Tempo Real

Dado o tempo decorrido no bloco em milissegundos ($t_{\text{elapsed}}$):
1. **Repetição Atual:** $\text{Rep} = \lfloor \frac{t_{\text{elapsed}}}{T_{\text{rep}} \times 1000} \rfloor + 1$
2. **Tempo Decorrido na Repetição Atual:** $t_{\text{rep}} = t_{\text{elapsed}} \pmod{T_{\text{rep}} \times 1000}$
3. **Determinação da Sub-Fase:**
   - Se $t_{\text{rep}} < E \times 1000$: **Fase Excêntrica (Descida)** $\rightarrow$ Contador visual sobe de $0$ até $E$ segundos.
   - Se $t_{\text{rep}} < (E + I_1) \times 1000$: **Pausa Inferior** $\rightarrow$ Contador indica $I_1$.
   - Se $t_{\text{rep}} < (E + I_1 + C) \times 1000$: **Fase Concêntrica (Subida)** $\rightarrow$ Contador visual desce de $C$ até $0$ segundos.
   - Caso contrário: **Pico de Contração** $\rightarrow$ Contador indica $I_2$.

---

## 3. Motor de Temporização Sem Drift (`WorkoutTimerEngine`)

Para garantir que o cronômetro não sofra com o acúmulo de atrasos do escalonador do sistema operacional (*drift accumulation*), o motor utiliza:
1. Um **ticker de 50ms** com base em `Timer.periodic`.
2. O cálculo de tempo é ancorado no relógio de alta resolução do sistema (`DateTime.now()`), garantindo precisão absoluta de milissegundos independente de oscilações na taxa de quadros (FPS) da UI.
3. Emissão precisa de eventos de contagem regressiva (`3`, `2`, `1`) exclusivamente nos 3 segundos finais das fases de **Preparação**, **Término da Série** e **Descanso**.
4. **Silêncio total durante a execução**: sem apitos ou sons durante os movimentos da série para concentração absoluta.

---

## 4. Gestão de Áudio com Compatibilidade iOS/Android

O `AudioService` gerencia instâncias dedicadas de `AudioPlayer` e configura o contexto de áudio em nível global:
- **iOS:** Categoria `AVAudioSessionCategory.playback` com opção `mixWithOthers`, permitindo que o som continue ativo mesmo com a chave física de silencioso ligada e durante o bloqueio de tela.
- **Android:** Tipo de uso `AndroidUsageType.assistanceSonification` e foco `gainTransientMayDuck`.
- **Assets Locais:** Bipes de contagem regressiva (`countdown.wav`) armazenados em `assets/audio/` com fallback de síntese PCM em memória.

---

## 5. Exibição na Tela de Bloqueio (`LockScreenService`)

Para garantir que o usuário acompanhe o treino com o celular bloqueado ou no bolso:
- **Canal Android:** `tensortimer_active_workout` com importância máxima, visibilidade pública na tela de bloqueio (`NotificationVisibility.public`) e categoria `AndroidNotificationCategory.stopwatch`.
- **Throttling de Atualizações:** A notificação é atualizada a cada 1 segundo ou a cada troca de etapa/sub-fase para otimização de CPU e bateria.
- **Notificação de Sucesso:** Ao concluir o treino, a notificação contínua é encerrada e substituída pela notificação de conclusão `🏆 Treino Concluído!`.
- **iOS Time-Sensitive:** Notificações configuradas com `InterruptionLevel.timeSensitive` e `NSSupportsLiveActivities` habilitado.

---

## 6. Cronograma Semanal de Treinos (`WeekdaySchedule`)

- **Estrutura:** `WeekdaySchedule` mapeia os dias da semana (1 = Segunda-feira a 7 = Domingo) para identificadores de rotina (`presetId` ou `workoutConfigId`).
- **UI:** `WeekdayScheduleBar` com scroll horizontal de chips de dias da semana, identificando o dia de hoje com destaque colorido e exibindo a rotina correspondente para troca rápida em um toque.
- **Persistência:** Sincronizado automaticamente via `SharedPreferences`.

---

## 7. Gerenciamento de Estado (Riverpod)

- **`workoutConfigProvider` (`WorkoutConfigNotifier`):** Gerencia a lista de exercícios do treino ativo, CRUD de exercícios (adicionar, duplicar, remover, reordenar), persistência automática e compilação da linha do tempo linear (`compileTimeline`).
- **`presetsProvider` (`PresetsNotifier`):** Carrega presets multi-exercício pré-definidos e permite criação, clonagem, edição e exclusão de treinos completos pelo usuário.
- **`weekdayScheduleProvider` (`WeekdayScheduleNotifier`):** Gerencia a atribuição de rotinas aos dias da semana.
- **`lockScreenServiceProvider`:** Fornece a instância singleton de controle de tela de bloqueio.
- **`settingsProvider` (`SettingsNotifier`):** Controla volume, ativação de sons, feedback háptico e controle de tela ligada (`WakelockPlus`).
