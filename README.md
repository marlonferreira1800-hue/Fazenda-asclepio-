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
| Mover personagem | `W`, `A`, `S`, `D`, `Setas Direcionais` ou **D-Pad Touch** (mobile) |
| Usar ferramenta / Plantar / Instalar Aspersor / Colher | `Espaço`, `E`, `Clique do Mouse` ou botão **Usar** (touch) |
| Interagir (Animais, Caixa de Venda, Loja, Poço, Porta da Casa, Recolher Aspersor, Colheita) | `F` ou botão **Interagir** (touch) |
| Selecionar slot da Hotbar (1 a 9) | `1`–`9`, **Roda do Mouse** ou clique na Hotbar |
| Abrir / Fechar Loja da Fazenda (Sementes e Upgrades) | `B` |
| Dormir / Avançar para o próximo dia | `N` (ou interagir com a porta da casinha) |
| Ligar/Desligar Fazendeiro Automático (Demo IA) | `P` (ou botão **Auto (P)** na HUD) |
| Abrir Menu & Opções (Som, Música, Touch, Reiniciar) | `Esc` (ou botão **Menu** na HUD) |
| Ver Atualizações / Changelog e Versão atual | `V` (ou botão **v1.3.0 (V)** na HUD) |
| Salvar progresso manualmente | Botão **Salvar** na HUD |
| Ligar / Desligar efeitos sonoros | Botão **Som: ON / OFF** na HUD (ou no Menu) |

---

## Como Jogar (Ciclo da Fazenda)

1. **Arar a terra:** Selecione a **Enxada** (`1`) e use (`Espaço`/`E`/clique) na área arável para preparar o solo (evoluindo a Enxada na Loja libera áreas `3x1` e `3x3`).
2. **Plantar:** Selecione uma semente (`3`–`8`) e plante sobre a terra arada.
3. **Regar, Aspersores e Chuva:** Selecione o **Regador** (`2`) e molhe os canteiros (reabasteça no **lago** ou **poço**). Você também pode comprar **Aspersores Automáticos (`9`)** na aba *Upgrades* da Loja (`B`) para regar `3x3` todo amanhecer — e em **dias de Chuva**, todos os canteiros são regados automaticamente!
4. **Cuidar dos Animais:** Entre no cercado pelo portão e interaja (`F` ou clique) perto das **galinhas** (**Ovo**), **vaca** (**Leite**), **ovelha** (**Lã**) e **porco** (**Trufa**), uma coleta por animal por dia.
5. **Avançar os dias:** O relógio começa às `06:00` e avança automaticamente até a meia-noite (`24:00`), ou você pode dormir a qualquer momento pressionando `N` (ou interagindo com a porta da casinha). Cultivos regados crescem ao virar o dia, a energia é restaurada e o clima segue a previsão exibida na HUD.
6. **Colher e Vender:** Quando o cultivo atingir o estágio maduro, colha com `Espaço`/`E`/`F` e venda cultivos e produtos animais na **Caixa de Venda** (`F`) ou pelo botão **Vender Tudo** na Loja (`B`).

---

## Cultivos, Produtos Animais, Upgrades e Economia

### Cultivos

| Cultivo | Dias para Crescer (regado) | Preço da Semente | Preço de Venda |
| :--- | :---: | :---: | :---: |
| **Trigo** (`wheat`) | 2 dias | $10 | $25 |
| **Cenoura** (`carrot`) | 3 dias | $20 | $55 |
| **Morango** (`strawberry`) | 4 dias | $35 | $110 |
| **Milho** (`corn`) | 3 dias | $30 | $90 |
| **Tomate** (`tomato`) | 4 dias | $45 | $145 |
| **Abóbora** (`pumpkin`) | 5 dias | $65 | $220 |

### Produtos Animais

| Produto | Origem | Preço de Venda |
| :--- | :--- | :---: |
| **Ovo** (`egg`) | Galinhas (1x por dia cada) | $30 |
| **Leite** (`milk`) | Vaca (1x por dia) | $45 |
| **Lã** (`wool`) | Ovelha (1x por dia) | $60 |
| **Trufa** (`truffle`) | Porco (1x por dia) | $80 |

### Upgrades & Automação (Loja `B` -> Aba Upgrades)

| Item / Upgrade | Nível 2 | Nível 3 |
| :--- | :---: | :---: |
| **Enxada** | Ara `3x1` ($150) | Ara `3x3` ($350) |
| **Regador** | `40` água, `3x1` ($150) | `60` água, `3x3` ($350) |
| **Resistência (Energia)** | `140` Energia ($120) | `180` Energia ($280) |
| **Aspersor Automático** | $180 cada (slot `9`) — rega `3x3` todo amanhecer | — |

- Recursos iniciais: **$100** moedas, **6** sementes de Trigo, **4** de Cenoura e **2** de Morango.

---

## Áudio Procedural e Save/Load

- **Efeitos Sonoros & Música (`AudioManager`):** Todos os efeitos sonoros e a **música de fundo cozy em loop** são sintetizados proceduralmente em memória via `AudioStreamWAV` (PCM 16-bit mono 22050Hz), funcionando offline tanto no Desktop quanto no export Web HTML5 sem depender de arquivos externos. Você pode silenciar SFX e música separadamente no **Menu (`Esc`)** ou pelo botão **Som** na HUD.
- **Persistência (`user://savegame.json`):** O progresso (moedas, dia, horário, clima/previsão, energia, água, upgrades, aspersores instalados, inventário, solo arado/molhado, cultivos, animais e preferências de áudio/touch) é salvo **automaticamente** ao avançar o dia, comprar na loja ou vender na cesta, e também **manualmente** pelo botão **Salvar**. Você pode reiniciar a fazenda para o Dia 1 com confirmação no **Menu (`Esc`)**.

---

## Estrutura Principal do Projeto

- `project.godot` — Configurações de entrada (`1-9`), viewport (`640x360` -> janela `1280x720`), filtro pixel art, versão (`1.3.0`) e Autoloads (`GameState`, `AudioManager`).
- `scripts/data/crop_data.gd` — Definições e recurso `CropData` dos 6 cultivos.
- `scripts/data/version_data.gd` — Versão atual (`v1.3.0`), histórico de versões (`v1.0.0`–`v1.3.0`), autoria e URLs de Releases/Issues.
- `scripts/autoload/game_state.gd` — Estado global (`GameState`), inventário, upgrades, clima/previsão, save/load JSON, reset completo e relógio diário.
- `scripts/autoload/audio_manager.gd` — Sintetizador procedural de efeitos sonoros e música de fundo em loop (`AudioManager`).
- `scripts/world/` e `scenes/` — Mundo da fazenda, clima visual, aspersores, jogador (com suporte touch), animais e HUD/Menu/Loja.
- `assets/sprites/` — Spritesheets 16x16 de terreno, cultivos (`80x96`), personagens, construções/animais (`96x64`) e ícones (`ui_icons.png` `256x16`).
- `tools/import_pack.py` — Ferramenta CLI para importar pacotes externos (como *Sprout Lands* ou *Kenney Tiny Town*) para `assets/sprites/` com backup automático em `assets/sprites_backup/`.
- `tools/auto_release_bot.py` e `Robozinho_Release.bat` — Robô automatizador de auditoria das 5 Barreiras e publicação de Releases (`Antes vs. Depois`).
- `RELEASE_RULES.md` — Critérios obrigatórios verificados pelo robô antes de subir qualquer nova versão.
- `CHANGELOG.md` — Registro completo de releases, quadro *Antes vs. Depois* e issues resolvidas.

---

## 📋 Histórico de Versões, Issues & Como Atualizar (Fluxo Solo GitHub)

- **Versão atual:** `v1.3.0` (mantida em `project.godot` e `scripts/data/version_data.gd`)
- **Changelog completo:** [CHANGELOG.md](CHANGELOG.md)
- **Releases no GitHub:** https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases
- **Issues & Bugs:** https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/issues?q=is%3Aissue

Para registrar novos bugs, melhorias, Pull Requests e novas versões no seu perfil do GitHub trabalhando solo:

```powershell
# 1. Abrir uma Issue descrevendo o bug ou melhoria (retorna o número #N)
gh issue create --title "fix(ui): descrever correção" --label "bug"

# 2. Criar uma branch limpa a partir da main atualizada
git checkout main
git pull origin main
git checkout -b fix/issue-N-breve-descricao

# 3. Após editar e validar no Godot 4.7.2, atualizar version_data.gd, CHANGELOG.md e project.godot
git add -A
git commit -m "fix: descrição objetiva da correção (#N)"
git push -u origin fix/issue-N-breve-descricao

# 4. Abrir e concluir o Pull Request fechando a Issue #N automaticamente
gh pr create --title "fix: descrição objetiva (#N)" --body "Closes #N"
gh pr merge --squash --delete-branch

# 5. Publicar nova Release (dispara .github/workflows/release.yml e Pages)
git checkout main
git pull origin main
gh release create v1.3.0 --title "v1.3.0" --generate-notes
```

### 🤖 Robô Automatizador de Release (`Robozinho_Release.bat`)

Para validar, versionar e publicar correções automaticamente sem risco de subir código quebrado, utilize o **Robô Agente de Release** (`tools/auto_release_bot.py` ou `Robozinho_Release.bat`), que exige aprovação nas **5 Barreiras** descritas em [RELEASE_RULES.md](RELEASE_RULES.md):

1. **Sintaxe Godot 4.7.2:** `--check-only` em todos os `.gd` (`EXIT=0`, zero `SCRIPT ERROR`).
2. **Assets & Grade RGBA:** Dimensões exatas dos 5 spritesheets em `assets/sprites/` (`64x32`, `80x96`, `64x64`, `96x64`, `256x16`).
3. **Boot & Higiene:** Boot headless de `scenes/main.tscn` (`EXIT=0`), zero arquivos temporários (`test_*`, `verify_*`, `*.tmp`) e zero segredos expostos.
4. **Mudança Real & Antes vs. Depois:** Consistência de versão, bloqueio de release sem diff real em `--publish`, incremento semântico (`patch`/`minor`/`major`) e quadro obrigatório **Antes vs. Depois**.
5. **Web Sincronizado & Rastreabilidade GitHub:** Re-export automático de `build/web/index.html`, Issue criada/fechada via `gh`, commit/push e Release publicada.

```powershell
# Auditar o projeto agora (somente leitura)
python tools/auto_release_bot.py --check

# Simular nova versão patch com Antes vs. Depois (dry-run)
python tools/auto_release_bot.py --dry-run --bump patch --title "Exemplo" --before "Estado anterior" --after "Estado corrigido"

# Publicar correção completa (ou clique duplo em Robozinho_Release.bat)
python tools/auto_release_bot.py --publish --bump patch --title "Correção X" --before "Como estava antes" --after "Como ficou depois" --fixes "Detalhe do ajuste"
```

---

## Assets Gratuitos e Substituição de Sprites

Para informações sobre pacotes gratuitos (CC0 / Free) recomendados, licenças, uso do importador `tools/import_pack.py` e substituição direta dos spritesheets em `assets/sprites/` mantendo exatamente as mesmas dimensões de grade, consulte [ASSETS_GRATUITOS.md](ASSETS_GRATUITOS.md).

---

## 🤖 Engenharia com Enxame de Agentes de IA & Curadoria de Recursos

Este projeto foi concebido, dirigido e arquitetado por **Marlon Ferreira ([@marlonferreira1800-hue](https://github.com/marlonferreira1800-hue))** utilizando **Engenharia e Orquestração de Enxame de Agentes de IA Estruturados (Multi-Agent Swarm)** com separação estrita de propriedade de arquivos e validação automatizada ponta a ponta:

- **Arquitetura do Enxame (Swarm):**
  - `assets-scout` — Curadoria de pacotes CC0/gratuitos, geração programática dos spritesheets 16x16 (`tools/generate_sprites.py`) e importador CLI (`tools/import_pack.py`).
  - `core-dev` — Autoloads (`GameState`, `AudioManager` SFX procedural), persistência JSON, definição de cultivos/versões (`CropData`, `VersionData`), `CHANGELOG.md`, regras de release e robô gatekeeper.
  - `world-dev` — Mapa `TileMapLayer`, física/colisões, cultivos em 5 estágios, animais produtores, ciclo dia/noite e máquina de estados do Fazendeiro Automático (`Auto / P`).
  - `ui-dev` — HUD responsiva em `640x360`, loja de sementes, hotbar, contraste acessível, toasts e painel de atualizações in-game (`v1.2.0 / V`).
  - `verifier` — Auditoria independente em Godot 4.7.2 (`--import`, `--check-only`, boot headless, suítes de integração e export Web HTML5/WASM).
  - `publisher` — Templates de Issues/PRs, GitHub Actions (`Pages` e `Release`), versionamento em tags e publicação contínua.
- **Curadoria Integrada nos 6 Portais de Assets Gratuitos:** Levantamento estruturado em [ASSETS_GRATUITOS.md](ASSETS_GRATUITOS.md) cobrindo **itch.io**, **Kenney**, **CraftPix**, **OpenGameArt**, **GameDev Market** e **Game Developer Studio**, com integração direta de ícones CC0 e compatibilidade de grade para substituição de pacotes.
- **Automação de Qualidade & Versionamento (`tools/auto_release_bot.py`):** Robô de release com **5 Barreiras de Critério** ([RELEASE_RULES.md](RELEASE_RULES.md)) que bloqueia qualquer publicação sem sintaxe limpa no Godot 4.7.2, integridade RGBA dos sprites, boot sem erros/lixo/segredos, quadro obrigatório **Antes vs. Depois** com diff real e build Web sincronizado.
