# Fazendinha 2D (Godot 4.7.2)

## 🎮 Jogar online

- **Jogar no navegador (GitHub Pages):** https://marlonferreira1800-hue.github.io/Fazenda-asclepio-/
- **Repositório no GitHub:** https://github.com/marlonferreira1800-hue/Fazenda-asclepio-

> **Nota:** O primeiro carregamento baixa cerca de **40 MB** (runtime WebAssembly). Para assistir ao fazendeiro automático em ação, pressione **`P`** ou clique no botão **Auto (P)** na HUD.

Jogo 2D pixel art estilo *cozy farming* desenvolvido para **Godot 4.7.2-stable** (renderizador `GL Compatibility`, resolução base `640x360` com filtro *nearest-neighbor* para pixel art nítida, compatível com Desktop, Mobile Touch e Web HTML5).

---

## Como Abrir e Rodar no Godot 4.7.2

1. Abra o **Godot Engine 4.7.2-stable** (`Godot_v4.7.2-stable_win64.exe` ou equivalente).
2. No **Gerenciador de Projetos**, clique em **Importar** (ou *Import*).
3. Selecione o arquivo `project.godot` na pasta raiz do projeto (`project.godot`).
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
| Mover personagem | `W`, `A`, `S`, `D`, `Setas Direcionais` ou **D-Pad Touch** (mobile) |
| Usar ferramenta / Plantar / Fertilizar / Aspersor / Colher / Pescar | `Espaço`, `E`, `Clique do Mouse` ou botão **Usar** (touch) |
| Interagir (Animais, Máquinas, Caixa de Venda, Loja, Encomendas, Poço, Porta, Recolher Aspersor) | `F` ou botão **Interagir** (touch) |
| Selecionar slot da Hotbar (11 slots) | `1`–`9`, `0`, `-`, **Roda do Mouse** ou clique na Hotbar |
| Abrir / Fechar Loja da Fazenda (Sementes, Upgrades, Animais & Máquinas) | `B` |
| Abrir / Fechar Diário da Fazenda (Pedidos, Álbum e Dicas/Velocidade) | `J` |
| Dormir / Avançar para o próximo dia | `N` (ou interagir com a porta da casinha) |
| Ligar/Desligar Fazendeiro Automático (Demo IA) | `P` (ou botão **Auto (P)** na HUD) |
| Abrir Menu & Opções (Som, Música, Touch, Velocidade, Reiniciar) | `Esc` (ou botão **Menu** na HUD) |
| Ver Atualizações / Changelog e Versão atual | `V` (ou botão **v1.4.0 (V)** na HUD) |
| Salvar progresso manualmente | Botão **Salvar** na HUD |
| Ligar / Desligar efeitos sonoros | Botão **Som: ON / OFF** na HUD (ou no Menu) |

---

## Como Jogar (Ciclo da Fazenda)

1. **Arar e Fertilizar:** Selecione a **Enxada** (`1`) e use (`Espaço`/`E`/clique) na área arável para preparar o solo (evoluindo a Enxada na Loja libera áreas `3x1` e `3x3`). Opcionalmente aplique **Fertilizante** (`0`) para aumentar a chance de colheitas **Ouro ★ (`1.5x`)** de `10%` para `45%`.
2. **Plantar (com Rebrota):** Selecione uma semente (`4`–`9`) e plante sobre a terra arada. **Morango, Milho e Tomate** rebrotam após a colheita sem gastar nova semente!
3. **Regar, Aspersores e Chuva:** Selecione o **Regador** (`2`) e molhe os canteiros (reabasteça no **lago** ou **poço**). Você também pode comprar **Aspersores Automáticos (`-`)** na Loja (`B`) para regar `3x3` todo amanhecer (recolhível com `F`) — e em **dias de Chuva**, todos os canteiros são regados automaticamente seguindo a previsão exibida na HUD!
4. **Pescar no Lago:** Selecione a **Vara de Pesca** (`3`) na beira do lago e acerte a zona verde no minigame (`Espaço`/`E`/clique ou botão **Usar**) para pescar **Tilápia**, **Camarão**, **Truta** e **Carpa Dourada**.
5. **Cuidar dos Animais & Carinho:** Entre no cercado pelo portão e interaja (`F` ou clique) com **galinhas** (**Ovo**/**Ovo Azul**), **vaca** (**Leite**), **ovelha** (**Lã**) e **porco** (**Trufa**). O carinho diário aumenta os corações (`♥ 0..5`), elevando a chance de variantes raras e qualidade **Ouro ★**! Você também pode comprar novos animais (até 8 no cercado) na aba *Animais & Máq.* da Loja (`B`).
6. **Máquinas Artesanais & Encomendas:** Instale a **Queijeira**, **Forno de Pão** e **Apiário** na Loja (`B`) para produzir **Queijo**, **Pão** e **Mel**, e entregue pedidos diários no **Quadro / Diário (`J`)** com recompensa bônus em moedas!
7. **Melhorias & Álbum:** Evolua **Enxada**, **Regador** e **Resistência** na Loja (`B`) e complete coleções no **Álbum (`J`)** para liberar bônus passivos permanentes (`+15%` valor de colheitas, barra de pesca `+25%` e máquinas `+30%` mais rápidas).

---

## Cultivos, Animais, Pesca, Máquinas & Upgrades

### Cultivos

| Cultivo | Dias (regado) | Rebrota | Preço da Semente | Venda Base |
| :--- | :---: | :---: | :---: | :---: |
| **Trigo** (`wheat`) | 2 dias | — | $10 | $25 |
| **Cenoura** (`carrot`) | 3 dias | — | $20 | $55 |
| **Morango** (`strawberry`) | 4 dias | 2 dias | $35 | $110 |
| **Milho** (`corn`) | 3 dias | 2 dias | $30 | $70 |
| **Tomate** (`tomato`) | 4 dias | 2 dias | $45 | $100 |
| **Abóbora** (`pumpkin`) | 5 dias | — | $65 | $220 |

### Produtos Animais, Pesca & Artesanais

| Produto | Origem | Venda Base |
| :--- | :--- | :---: |
| **Ovo** (`egg`) / **Ovo Azul** (`blue_egg`) | Galinhas (carinho libera Ovo Azul) | $30 / $55 |
| **Leite** (`milk`) | Vacas (1x por dia) | $45 |
| **Lã** (`wool`) | Ovelhas (1x por dia) | $60 |
| **Trufa** (`truffle`) | Porcos (1x por dia) | $80 |
| **Tilápia** / **Camarão** / **Truta** / **Carpa Dourada** | Pesca no lago | $35 / $45 / $55 / $120 |
| **Queijo** (`cheese`) | Queijeira (`1 Leite`) | $95 |
| **Pão** (`bread`) | Forno de Pão (`2 Trigo`) | $80 |
| **Mel** (`honey`) | Apiário (todo amanhecer) | $70 |

> Itens com qualidade **Ouro ★** rendem **1.5x** o valor de venda!

### Upgrades & Automação (Loja `B` -> Aba Upgrades)

| Item / Upgrade | Nível 2 | Nível 3 |
| :--- | :---: | :---: |
| **Enxada** | Ara `3x1` ($150) | Ara `3x3` ($350) |
| **Regador** | `40` água, `3x1` ($150) | `60` água, `3x3` ($350) |
| **Resistência (Energia)** | `140` Energia ($120) | `180` Energia ($280) |
| **Fertilizante** | $15 cada (slot `0`) — aumenta chance de Ouro ★ | — |
| **Aspersor Automático** | $180 cada (slot `-`) — rega `3x3` todo amanhecer | — |

- Recursos iniciais: **$100** moedas, **6** Trigo, **4** Cenoura, **2** Morango e **2** Fertilizantes.

---

## Áudio Procedural e Save/Load

- **Efeitos Sonoros & Música (`AudioManager`):** Todos os efeitos sonoros (enxada, água, plantio, colheita, moedas, erro, clique, descanso, pesca, máquinas, pedidos, upgrade e 4 animais) e a **música de fundo cozy em loop** são sintetizados proceduralmente em memória via `AudioStreamWAV` (PCM 16-bit mono 22050Hz), funcionando offline tanto no Desktop quanto no export Web HTML5 sem depender de arquivos externos. Você pode silenciar SFX e música separadamente no **Menu (`Esc`)** ou pelo botão **Som** na HUD.
- **Persistência (`user://savegame.json`):** O progresso completo (moedas, dia, horário, velocidade do relógio, clima/previsão, energia, água, upgrades, fertilizante, aspersores, máquinas artesanais, encomendas, corações dos animais, Álbum, preferências de áudio/touch e mundo) é salvo **automaticamente** ao avançar o dia, comprar na loja, entregar pedidos ou vender na cesta, e também **manualmente** pelo botão **Salvar**, mantendo compatibilidade retroativa com saves `v1.2.0`/`v1.3.0`. Você pode reiniciar a fazenda para o Dia 1 com confirmação no **Menu (`Esc`)**.

---

## Estrutura Principal do Projeto

- `project.godot` — Configurações de entrada, viewport (`640x360` -> janela `1280x720`), filtro pixel art, versão (`1.4.0`) e Autoloads (`GameState`, `AudioManager`).
- `scripts/data/crop_data.gd` — Definições e recurso `CropData` dos 6 cultivos (com suporte a rebrota).
- `scripts/data/farm_catalog.gd` — Catálogo `FarmCatalog` de peixes, produtos animais, máquinas artesanais, suprimentos, upgrades, compra de animais e metas do Álbum.
- `scripts/data/version_data.gd` — Versão atual (`v1.4.0`), histórico de versões (`v1.0.0`–`v1.4.0`), autoria e URLs de Releases/Issues.
- `scripts/autoload/game_state.gd` — Estado global (`GameState`), inventário, upgrades, clima/previsão, máquinas, encomendas, Álbum, velocidade do relógio e save/load JSON.
- `scripts/autoload/audio_manager.gd` — Sintetizador procedural de efeitos sonoros e música de fundo em loop (`AudioManager`).
- `scripts/world/` e `scenes/` — Mundo da fazenda, clima visual, pesca, máquinas, aspersores, jogador (com suporte touch), animais (com carinho/corações) e interface/HUD.
- `assets/sprites/` — Spritesheets 16x16 originais (`terrain_tileset.png`, `crops_sheet.png` `80x96`, `farmer_sheet.png`, `props_buildings.png` `96x64`, `ui_icons.png` `256x16`) + sheets modulares adicionais (`v13_props_sheet.png` `112x32`, `v13_icons.png` `256x16`).
- `tools/import_pack.py` — Ferramenta CLI para importar pacotes externos (como *Sprout Lands* ou *Kenney Tiny Town*) para `assets/sprites/` com backup automático em `assets/sprites_backup/`.
- `tools/auto_release_bot.py` e `Robozinho_Release.bat` — Robô automatizador de auditoria das 5 Barreiras e publicação de Releases (`Antes vs. Depois`).
- `RELEASE_RULES.md` — Critérios obrigatórios verificados pelo robô antes de subir qualquer nova versão.
- `CHANGELOG.md` — Registro completo de releases, quadro *Antes vs. Depois* e issues resolvidas.

---

## 📋 Histórico de Versões, Issues & Como Atualizar (Fluxo Solo GitHub)

- **Versão atual:** `v1.4.0` (mantida em `project.godot` e `scripts/data/version_data.gd`)
- **Changelog completo:** [CHANGELOG.md](CHANGELOG.md)
- **Releases no GitHub:** https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases
- **Issues & Bugs:** https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/issues?q=is%3Aissue

Para validar e publicar no Godot 4.7.2:

```powershell
# 1. Auditar as 5 barreiras no Godot 4.7.2
python tools/auto_release_bot.py --check

# 2. Re-exportar build Web HTML5 sincronizada antes do merge/release
& "C:\Users\marlo\OneDrive\Desktop\Godot_v4.7.2-stable_win64.exe" --headless --path . --export-release "Web" build/web/index.html

# 3. Ou publicar correção/versão completa via Robô de Release
python tools/auto_release_bot.py --publish --bump minor --title "Descrição" --before "Estado anterior" --after "Estado corrigido"
```

---

## Assets Gratuitos e Substituição de Sprites

Para informações sobre pacotes gratuitos (CC0 / Free) recomendados, licenças, uso do importador `tools/import_pack.py` e substituição direta dos spritesheets em `assets/sprites/` mantendo exatamente as mesmas dimensões de grade, consulte [ASSETS_GRATUITOS.md](ASSETS_GRATUITOS.md).

---

## 🤖 Engenharia com Enxame de Agentes de IA & Curadoria de Recursos

Este projeto foi concebido, dirigido e arquitetado por **Marlon Ferreira ([@marlonferreira1800-hue](https://github.com/marlonferreira1800-hue))** utilizando **Engenharia e Orquestração de Enxame de Agentes de IA Estruturados (Multi-Agent Swarm)** com separação estrita de propriedade de arquivos e validação automatizada ponta a ponta:

- **Arquitetura do Enxame (Swarm):**
  - `assets-scout` — Curadoria de pacotes CC0/gratuitos, geração programática dos spritesheets 16x16 (`tools/generate_sprites.py`) e importador CLI (`tools/import_pack.py`).
  - `core-dev` — Autoloads (`GameState`, `AudioManager` SFX/BGM procedural), persistência JSON, definição de cultivos/catálogo/versões (`CropData`, `FarmCatalog`, `VersionData`), `CHANGELOG.md`, regras de release e robô gatekeeper.
  - `world-dev` — Mapa `TileMapLayer`, física/colisões, cultivos em 5 estágios com rebrota, pesca, máquinas, animais produtores com carinho, ciclo dia/noite e máquina de estados do Fazendeiro Automático (`Auto / P`).
  - `ui-dev` — HUD responsiva em `640x360`, loja com abas, Diário (`J`), Menu (`Esc`), hotbar de 11 slots, controles touch mobile, toasts e painel de atualizações in-game (`V`).
  - `verifier` — Auditoria independente em Godot 4.7.2 (`--import`, `--check-only`, boot headless, suítes de integração e export Web HTML5/WASM).
  - `publisher` — Templates de Issues/PRs, GitHub Actions (`Pages` e `Release`), versionamento em tags e publicação contínua.
- **Curadoria Integrada nos 6 Portais de Assets Gratuitos:** Levantamento estruturado em [ASSETS_GRATUITOS.md](ASSETS_GRATUITOS.md) cobrindo **itch.io**, **Kenney**, **CraftPix**, **OpenGameArt**, **GameDev Market** e **Game Developer Studio**, com integração direta de ícones CC0 e compatibilidade de grade para substituição de pacotes.
- **Automação de Qualidade & Versionamento (`tools/auto_release_bot.py`):** Robô de release com **5 Barreiras de Critério** ([RELEASE_RULES.md](RELEASE_RULES.md)) que bloqueia qualquer publicação sem sintaxe limpa no Godot 4.7.2, integridade RGBA dos sprites, boot sem erros/lixo/segredos, quadro obrigatório **Antes vs. Depois** com diff real e build Web sincronizado.
