# Changelog — Fazendinha 2D

Todas as alterações relevantes do projeto **Fazendinha 2D** estão documentadas neste arquivo, seguindo o versionamento semântico (`MAJOR.MINOR.PATCH`) e as regras de validação de [RELEASE_RULES.md](RELEASE_RULES.md).

- **Repositório:** [marlonferreira1800-hue/Fazenda-asclepio-](https://github.com/marlonferreira1800-hue/Fazenda-asclepio-)
- **Jogar online:** [https://marlonferreira1800-hue.github.io/Fazenda-asclepio-/](https://marlonferreira1800-hue.github.io/Fazenda-asclepio-/)
- **Autor / Mantenedor:** [@marlonferreira1800-hue](https://github.com/marlonferreira1800-hue) (Marlon Ferreira)
- **Releases:** [Todas as Releases](https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases) · **Issues:** [Acompanhar Bugs e Melhorias](https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/issues?q=is%3Aissue)

---

## [v1.4.0] — 2026-11-20

**Rebrota, Fertilizante Ouro ★, Pesca no Lago, Máquinas Artesanais, Carinho & Diário (J)**
- **Release (planejada):** [v1.4.0](https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases/tag/v1.4.0)
- **PR:** [#6](https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/pull/6)
- **Contribuidor:** [@marlonferreira1800-hue](https://github.com/marlonferreira1800-hue)

### 🔄 Antes vs. Depois
- **Antes:** Cultivos sem rebrota ou qualidade especial, sem pesca no lago, sem máquinas artesanais, sem carinho/compra de animais nem quadro de encomendas ou álbum.
- **Depois:** Morango, Milho e Tomate com rebrota contínua; Fertilizante (`$15`) + qualidade Ouro ★ (`1.5x`); minigame de pesca (4 peixes); carinho diário (`♥ 0..5`), Ovo Azul (`$55`) e compra de animais (Galinha/Ovelha/Vaca/Porco); máquinas artesanais (**Queijeira**, **Forno de Pão**, **Apiário**); Diário (`J`) com Encomendas Diárias e Álbum (3 bônus passivos); e controle de velocidade do dia (`0.5x / 1x / 1.5x`).

### Bugs Resolvidos e Melhorias
- **PR [#6](https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/pull/6):**
  - **Cultivos & Qualidade:** Rebrota automática em **Morango**, **Milho** e **Tomate** (`regrow_days: 2`), **Fertilizante (`$15`)** no slot `0` elevando a chance de colheita **Ouro ★ (`1.5x`)** de `10%` para `45%`.
  - **Pesca no Lago:** **Vara de Pesca** no slot `3` com minigame no lago (suporte teclado, mouse e touch mobile) para pescar **Tilápia (`$35`)**, **Camarão (`$45`)**, **Truta (`$55`)** e **Carpa Dourada (`$120`)** + SFX dedicados.
  - **Animais & Máquinas Artesanais:** Sistema de carinho diário (`♥ 0..5`), **Ovo Azul (`$55`)**, compra de novos animais na Loja (**Galinha**, **Ovelha**, **Vaca**, **Porco** — até 8 no cercado) e 3 máquinas (**Queijeira**, **Forno de Pão**, **Apiário**) produzindo **Queijo (`$95`)**, **Pão (`$80`)** e **Mel (`$70`)**.
  - **Diário (`J`), Álbum & Auto-Farmer:** Quadro de Encomendas no mapa + modal **Diário (`J`)** com 3 pedidos diários, **Álbum de Descobertas** (18 itens e 3 bônus passivos), controle de **Velocidade do Relógio (`0.5x / 1x / 1.5x`)** no Menu/Diário, compatibilidade retroativa com saves `v1.3.0` e Auto-Farmer (`P`) integrado às máquinas e carinho.

---

## [v1.3.0] — 2026-11-19

**Novos Cultivos, Upgrades 3x3, Aspersores, Clima Chuvoso, BGM Procedural, Ovelha/Porco & Mobile**
- **Release:** [v1.3.0](https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases/tag/v1.3.0)
- **Issue:** [#7](https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/issues/7)
- **Contribuidor:** [@marlonferreira1800-hue](https://github.com/marlonferreira1800-hue)

### 🔄 Antes vs. Depois
- **Antes:** Apenas 3 cultivos, ferramentas sem evolução, clima sempre ensolarado, sem música de fundo, apenas galinha/vaca, sem controles touch na tela nem opção na interface para reiniciar o progresso.
- **Depois:** 6 cultivos (Trigo, Cenoura, Morango, Milho, Tomate e Abóbora), upgrades de Enxada/Regador (`3x1`/`3x3`) e Resistência, Aspersor automático `3x3`, clima Sol/Chuva com previsão e rega automática, música cozy procedural em loop, Ovelha (`Lã $60`) e Porco (`Trufa $80`), controles touch na tela, Menu (`Esc`) com Reiniciar Fazenda e Auto-Farmer expandido para 12 canteiros.

### Bugs Resolvidos e Melhorias
- **Issue [#7](https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/issues/7):**
  - **Gameplay & Economia:** Adicionados **Milho** (`3d`, `$30`/`$90`), **Tomate** (`4d`, `$45`/`$145`) e **Abóbora** (`5d`, `$65`/`$220`) em `CropData`, hotbar expandida para 9 slots (`1-9` + roda do mouse), Loja (`B`) redesenhada com abas (**Sementes** `1x`/`+5` e **Upgrades**) e **Aspersor Automático (`3x3`)** recolhível com `F`.
  - **Clima & Atmosfera:** Sistema diário de clima (**Sol / Chuva**) com previsão para o dia seguinte na HUD, gotas de chuva pixeladas em movimento, fumaça na chaminé, brilhos no lago e rega automática de todo o canteiro quando chove.
  - **Áudio & Animais:** Música de fundo *cozy* sintetizada proceduralmente em loop (`AudioStreamWAV`), novos timbres para **Ovelha**, **Porco** e **Upgrade**, e produção diária de **Lã (`$60`)** e **Trufa (`$80`)**.
  - **UX, Mobile & Auto-Farmer:** Menu (`Esc`/botão `Menu`) com toggles independentes de SFX/Música, seletor de **Controles Touch (`Auto / Sempre ON / OFF`)** com D-Pad + ações na tela, **Reiniciar Fazenda** com confirmação limpando também o mundo, e Auto-Farmer (`P`) atualizado para 12 canteiros e todas as 6 culturas.

---

## [v1.2.0] — 2026-11-15

**Modo Fazendeiro Automático, Painel de Atualizações & Deploy Web**
- **Release:** [v1.2.0](https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases/tag/v1.2.0)
- **Contribuidor:** [@marlonferreira1800-hue](https://github.com/marlonferreira1800-hue)

### 🔄 Antes vs. Depois
- **Antes:** O jogo exigia controle 100% manual, não exibia a versão atual nem o histórico de correções dentro do jogo e não possuía publicação contínua na Web.
- **Depois:** Modo Fazendeiro Automático ao vivo (`P` / botão `Auto (P)`), Painel de Atualizações in-game (`V` / badge `v1.2.0 (V)`) com quadro Antes vs. Depois e deploy automático no GitHub Pages.

### Bugs Resolvidos e Melhorias
- **Issue [#3](https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/issues/3):** Modo Fazendeiro Automático (**Auto** / tecla `P` / botão `Auto (P)` na HUD) com máquina de estados contínua e rota inteligente pelos portões (colher, regar, reabastecer no poço, coletar ovo/leite, arar, plantar, vender e dormir), com retorno imediato ao controle manual via `WASD`/setas.
- **Issue [#4](https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/issues/4):** Sistema de versionamento (`scripts/data/version_data.gd`, `CHANGELOG.md`, `config/version="1.2.0"`) e Painel de Atualizações in-game (`tecla V` / badge `v1.2.0 (V)`) exibindo histórico de versões, autor e botões para abrir Releases e Issues no GitHub.
- Publicação automática da build Web HTML5 no **GitHub Pages** via **GitHub Actions** (`.github/workflows/release.yml` / `.github/workflows/pages.yml`) e atualização da seção *Jogar online* no `README.md`.

---

## [v1.1.0] — 2026-11-15

**Correção de Contraste da HUD, Áudio Procedural, Save/Load & Animais**
- **Release:** [v1.1.0](https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases/tag/v1.1.0)
- **Contribuidor:** [@marlonferreira1800-hue](https://github.com/marlonferreira1800-hue)

### 🔄 Antes vs. Depois
- **Antes:** Textos das barras de Energia/Água, hotbar e barra inferior apresentavam baixo contraste sobre o gramado, o jogo era mudo, o progresso se perdia ao fechar e os animais eram apenas decorativos.
- **Depois:** HUD legível com contornos escuros e barra inferior contrastada, áudio procedural em memória (`AudioManager`), persistência automática em `user://savegame.json` e coleta diária de Ovo (`$30`) e Leite (`$45`).

### Bugs Resolvidos e Melhorias
- **Issue [#1](https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/issues/1) (Bugfix):** Correção de contraste e legibilidade na HUD `640x360`: contornos escuros nos textos das barras de Energia/Água, no rótulo do item ativo e nos contadores de slots, além de `PanelContainer` escuro semitransparente para a barra inferior de controles.
- **Issue [#2](https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/issues/2):**
  - Efeitos sonoros procedurais em memória (`scripts/autoload/audio_manager.gd`, PCM 16-bit mono 22050Hz) compatíveis com Desktop e Web HTML5, com botão de mudo na HUD (`Som: ON / OFF`).
  - Sistema de Save/Load automático e manual em `user://savegame.json` (`GameState` + restauração de solo, cultivos e animais em `farm_world.gd`).
  - Interação com galinhas e vaca para coleta diária de **Ovo** (`$30`) e **Leite** (`$45`), com portões abertos no cercado e venda integrada na cesta.
- Criação do importador CLI `tools/import_pack.py` (com backup em `assets/sprites_backup/`) e expansão de `assets/sprites/ui_icons.png` para `128x16` RGBA (8 ícones) integrando itens CC0 do OpenGameArt.

---

## [v1.0.0] — 2026-11-15

**Lançamento Inicial — Protótipo Jogável Fazendinha 2D**
- **Release:** [v1.0.0](https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases/tag/v1.0.0)
- **Contribuidor:** [@marlonferreira1800-hue](https://github.com/marlonferreira1800-hue)

### 🔄 Antes vs. Depois
- **Antes:** Repositório inicial vazio sem cenas, lógica de cultivo, HUD ou spritesheets configurados.
- **Depois:** Protótipo completo e jogável de fazendinha 2D em Godot 4.7.2 com cultivos, economia, loja, ciclo dia/noite e catálogo de assets CC0.

### Recursos Iniciais
- Projeto configurado para **Godot 4.7.2-stable** (`GL Compatibility`, viewport `640x360`, filtro *nearest-neighbor* para pixel art).
- Mapa `40x24` tiles em `TileMapLayer` com ciclo dia/tarde/noite (`CanvasModulate`), relógio diário (`06:00`–`24:00`), casinha, poço d'água, lago, caixa de venda, placa da loja, cercado com animais e canteiro arável.
- Cultivos de **Trigo** (`2` dias, `$10`/`$25`), **Cenoura** (`3` dias, `$20`/`$55`) e **Morango** (`4` dias, `$35`/`$110`) em 5 estágios visuais com loja de sementes, hotbar de 5 slots e toasts informativos.
- Spritesheets 16x16 pixel art cozy gerados por `tools/generate_sprites.py` e catálogo de pacotes gratuitos/CC0 documentado em `ASSETS_GRATUITOS.md`.
