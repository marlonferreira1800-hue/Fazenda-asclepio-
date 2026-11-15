# Fazendinha 2D (Godot 4.7.2)

## 🎮 Jogar online

- **Jogar no navegador (GitHub Pages):** https://marlonferreira1800-hue.github.io/Fazenda-asclepio-/
- **Repositório no GitHub:** https://github.com/marlonferreira1800-hue/Fazenda-asclepio-

> **Nota:** O primeiro carregamento baixa cerca de **40 MB** (runtime WebAssembly). Para assistir ao fazendeiro automático em ação, pressione **`P`** ou clique no botão **Auto (P)** na HUD.

Jogo 2D pixel art estilo *cozy farming* desenvolvido para **Godot 4.7.2-stable** (renderizador `GL Compatibility`, resolução base `640x360` com filtro *nearest-neighbor* para pixel art nítida, compatível com Desktop e Web HTML5).

---

## Como Abrir e Rodar no Godot 4.7.2

1. Abra o **Godot Engine 4.7.2-stable** (`Godot_v4.7.2-stable_win64.exe` ou equivalente).
2. No **Gerenciador de Projetos**, clique em **Importar** (ou *Import*).
3. Selecione o arquivo `project.godot` na pasta raiz do projeto (`fazendinha-2d/project.godot`).
4. Clique em **Importar e Editar** (ou abra o projeto diretamente).
5. Aguarde a importação inicial dos sprites e cenas e pressione **F5** no editor (ou clique no botão **Play** no canto superior direito) para iniciar `scenes/main.tscn`.

> **Nota para export Web:** `F5` não é associado a nenhum atalho interno do jogo para evitar recarregamento acidental da aba do navegador.

### Executando via linha de comando (opcional)

```powershell
& "C:\Users\marlo\OneDrive\Desktop\Godot_v4.7.2-stable_win64.exe" --path "C:\Users\marlo\.gemini\antigravity\scratch\fazendinha-2d"
```

---

## Controles

| Ação | Tecla / Entrada |
| :--- | :--- |
| Mover personagem | `W`, `A`, `S`, `D` ou `Setas Direcionais` |
| Usar ferramenta / Plantar / Colher | `Espaço`, `E` ou `Clique do Mouse` no tile alvo |
| Interagir (Animais, Caixa de Venda, Loja, Poço, Porta da Casa, Colheita) | `F` |
| Selecionar slot da Hotbar (1 a 5) | `1`, `2`, `3`, `4`, `5` ou clique na Hotbar |
| Abrir / Fechar Loja de Sementes | `B` |
| Dormir / Avançar para o próximo dia | `N` (ou interagir com a porta da casinha) |
| Ligar/Desligar Fazendeiro Automático (Demo IA) | `P` (ou botão **Auto (P)** na HUD) |
| Salvar progresso manualmente | Botão **Salvar** na HUD |
| Ligar / Desligar efeitos sonoros | Botão **Som: ON / OFF** na HUD |

---

## Como Jogar (Ciclo da Fazenda)

1. **Arar a terra:** Selecione a **Enxada** (`1`) e use (`Espaço`/`E`/clique) na área arável para preparar o solo.
2. **Plantar:** Selecione uma semente (`3` Trigo, `4` Cenoura ou `5` Morango) e plante sobre a terra arada.
3. **Regar:** Selecione o **Regador** (`2`) e molhe os canteiros plantados. Quando a água acabar, interaja perto do **lago** ou do **poço** para reabastecer.
4. **Cuidar dos Animais (Ovo e Leite):** Entre no cercado pelo portão e interaja (`F` ou clique) perto das **galinhas** para coletar **Ovo** e perto da **vaca** para coletar **Leite** (uma coleta por animal por dia).
5. **Avançar os dias:** O relógio começa às `06:00` e avança automaticamente até a meia-noite (`24:00`), ou você pode dormir a qualquer momento pressionando `N` (ou interagindo com a porta da casinha). Cultivos regados crescem ao virar o dia, a energia é restaurada e os animais voltam a produzir.
6. **Colher e Vender:** Quando o cultivo atingir o estágio maduro, colha com `Espaço`/`E`/`F` e venda cultivos e produtos animais na **Caixa de Venda** (`F`) ou pelo botão **Vender Tudo** na Loja (`B`).

---

## Cultivos, Produtos Animais e Economia

### Cultivos

| Cultivo | Dias para Crescer (regado) | Preço da Semente | Preço de Venda |
| :--- | :---: | :---: | :---: |
| **Trigo** (`wheat`) | 2 dias | $10 | $25 |
| **Cenoura** (`carrot`) | 3 dias | $20 | $55 |
| **Morango** (`strawberry`) | 4 dias | $35 | $110 |

### Produtos Animais

| Produto | Origem | Preço de Venda |
| :--- | :--- | :---: |
| **Ovo** (`egg`) | Galinhas (1x por dia cada) | $30 |
| **Leite** (`milk`) | Vaca (1x por dia) | $45 |

- Recursos iniciais: **$100** moedas, **6** sementes de Trigo, **4** de Cenoura e **2** de Morango.

---

## Áudio Procedural e Save/Load

- **Efeitos Sonoros (`AudioManager`):** Todos os sons (enxada, água, plantio, colheita, moedas, erro, clique, descanso e animais) são sintetizados proceduralmente em memória via `AudioStreamWAV` (PCM 16-bit mono 22050Hz), funcionando offline tanto no Desktop quanto no export Web HTML5 sem depender de arquivos externos. Você pode silenciar/reativar o som pelo botão **Som** na HUD.
- **Persistência (`user://savegame.json`):** O progresso (moedas, dia, horário, energia, água, inventário de sementes/colheitas/ovos/leite, solo arado/molhado, cultivos em crescimento e coleta diária dos animais) é salvo **automaticamente** ao avançar o dia, comprar sementes ou vender na cesta, e também **manualmente** pelo botão **Salvar** na HUD. Ao reabrir o jogo, o estado salvo é carregado automaticamente.

---

## Estrutura Principal do Projeto

- `project.godot` — Configurações de entrada, viewport (`640x360` -> janela `1280x720`), filtro pixel art e Autoloads (`GameState`, `AudioManager`).
- `scripts/data/crop_data.gd` — Definições e recurso `CropData` dos cultivos.
- `scripts/autoload/game_state.gd` — Estado global (`GameState`), inventário, economia, energia, regador, save/load JSON, sinais e relógio diário.
- `scripts/autoload/audio_manager.gd` — Sintetizador procedural de efeitos sonoros (`AudioManager`) com pool de `AudioStreamPlayer` e controle de mudo.
- `scripts/world/` e `scenes/` — Mundo da fazenda, jogador, animais e interface/HUD.
- `assets/sprites/` — Spritesheets 16x16 de terreno, cultivos, personagens, construções e ícones (`ui_icons.png` 128x16).
- `tools/import_pack.py` — Ferramenta CLI para importar pacotes externos (como *Sprout Lands* ou *Kenney Tiny Town*) para `assets/sprites/` com backup automático em `assets/sprites_backup/`.

---

## Assets Gratuitos e Substituição de Sprites

Para informações sobre pacotes gratuitos (CC0 / Free) recomendados, licenças, uso do importador `tools/import_pack.py` e substituição direta dos spritesheets em `assets/sprites/` mantendo exatamente as mesmas dimensões de grade, consulte [ASSETS_GRATUITOS.md](ASSETS_GRATUITOS.md).
