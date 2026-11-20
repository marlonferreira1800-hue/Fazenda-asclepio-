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
| Usar ferramenta / Plantar / Colher / Pescar | `Espaço`, `E` ou `Clique do Mouse` no tile alvo |
| Interagir (Animais, Máquinas, Caixa de Venda, Loja, Encomendas, Poço, Porta) | `F` |
| Selecionar slot da Hotbar (11 slots) | `1`–`9`, `0`, `-`, `Scroll do Mouse` ou clique na Hotbar |
| Abrir / Fechar Loja da Fazenda (Sementes, Fazenda, Máquinas) | `B` |
| Abrir / Fechar Diário da Fazenda (Pedidos, Álbum e Opções) | `J` |
| Dormir / Avançar para o próximo dia | `N` (ou interagir com a porta da casinha) |
| Ligar/Desligar Fazendeiro Automático (Demo IA) | `P` (ou botão **Auto (P)** na HUD) |
| Ver Atualizações / Changelog e Versão atual | `V` (ou botão **v1.3.0 (V)** na HUD) |
| Salvar progresso manualmente | Botão **Salvar** na HUD |
| Ligar / Desligar efeitos sonoros | Botão **Som: ON / OFF** na HUD |

---

## Como Jogar (Ciclo da Fazenda)

1. **Arar e Fertilizar:** Selecione a **Enxada** (`1`) e use (`Espaço`/`E`/clique) na área arável. Opcionalmente aplique **Fertilizante** (`0`) para aumentar a chance de colheitas **Ouro ★ (`1.5x`)**.
2. **Plantar:** Selecione uma semente (`4`–`9`) e plante sobre a terra arada. **Morango, Milho e Tomate** rebrotam após a colheita sem gastar nova semente!
3. **Regar & Clima:** Selecione o **Regador** (`2`) ou instale **Aspersores** (`-`) para regar `3x3` automaticamente todo amanhecer. Em **dias de chuva**, toda a terra arada é regada pela natureza.
4. **Pescar no Lago:** Selecione a **Vara de Pesca** (`3`) perto do lago e acerte a zona verde no minigame para pescar Tilápia, Camarão, Truta e Carpa Dourada.
5. **Cuidar dos Animais & Carinho:** Entre no cercado pelo portão e interaja (`F` ou clique) com **galinhas**, **ovelhas** e **vacas** para coletar **Ovo/Ovo Azul**, **Lã** e **Leite** e aumentar corações de amizade (`♥ 0..5`), elevando a chance de variantes raras e qualidade Ouro.
6. **Máquinas Artesanais & Encomendas:** Compre a **Queijeira**, **Forno de Pão** e **Apiário** na aba *Máquinas* da Loja (`B`) para transformar Leite/Trigo em **Queijo**, **Pão** e **Mel**, e entregue pedidos diários no **Quadro / Diário (`J`)** com bônus em moedas!
7. **Melhorias & Álbum:** Evolua **Enxada e Regador** até `3x3` na Loja (`B`) e complete coleções no **Álbum (`J`)** para desbloquear bônus passivos permanentes.

---

## Cultivos, Animais, Pesca e Artesanais

### Cultivos

| Cultivo | Dias (regado) | Rebrota | Semente | Venda |
| :--- | :---: | :---: | :---: | :---: |
| **Trigo** (`wheat`) | 2 dias | — | $10 | $25 |
| **Cenoura** (`carrot`) | 3 dias | — | $20 | $55 |
| **Morango** (`strawberry`) | 4 dias | 2 dias | $35 | $110 |
| **Milho** (`corn`) | 4 dias | 2 dias | $40 | $65 |
| **Tomate** (`tomato`) | 3 dias | 2 dias | $30 | $50 |
| **Abóbora** (`pumpkin`) | 5 dias | — | $60 | $190 |

### Produtos Animais, Pesca & Artesanais

| Produto | Origem | Venda Base |
| :--- | :--- | :---: |
| **Ovo** (`egg`) / **Ovo Azul** (`blue_egg`) | Galinhas (carinho libera Ovo Azul) | $30 / $55 |
| **Leite** (`milk`) | Vacas (1x por dia) | $45 |
| **Lã** (`wool`) | Ovelhas (1x por dia) | $60 |
| **Tilápia** / **Camarão** / **Truta** / **Carpa Dourada** | Pesca no lago | $35 / $45 / $55 / $120 |
| **Queijo** (`cheese`) | Queijeira (`1 Leite`) | $95 |
| **Pão** (`bread`) | Forno de Pão (`2 Trigo`) | $80 |
| **Mel** (`honey`) | Apiário (todo amanhecer) | $70 |

- Recursos iniciais: **$100** moedas, **6** Trigo, **4** Cenoura, **2** Morango e **2** Fertilizantes.

---

## Áudio Procedural e Save/Load

- **Efeitos Sonoros (`AudioManager`):** Todos os sons (enxada, água, plantio, colheita, moedas, erro, clique, descanso, pesca, máquinas, pedidos e animais) são sintetizados proceduralmente em memória via `AudioStreamWAV` (PCM 16-bit mono 22050Hz), funcionando offline tanto no Desktop quanto no export Web HTML5 sem depender de arquivos externos. Você pode silenciar/reativar o som pelo botão **Som** na HUD.
- **Persistência (`user://savegame.json`):** O progresso completo (incluindo clima, upgrades, fertilizante, aspersores, máquinas, encomendas, corações dos animais e Álbum) é salvo **automaticamente** ao avançar o dia, comprar na loja, entregar pedidos ou vender na cesta, mantendo retrocompatibilidade com saves da `v1.2.0`.

---

## Estrutura Principal do Projeto

- `project.godot` — Configurações de entrada, viewport (`640x360` -> janela `1280x720`), filtro pixel art e Autoloads (`GameState`, `AudioManager`).
- `scripts/data/crop_data.gd` — Definições e recurso `CropData` dos 6 cultivos (com suporte a rebrota e sheet extra).
- `scripts/data/farm_catalog.gd` — Catálogo `FarmCatalog` de peixes, produtos animais, máquinas artesanais, upgrades de ferramentas, suprimentos e metas do Álbum.
- `scripts/data/version_data.gd` — Histórico de versões, autoria e URLs de Releases/Issues.
- `scripts/autoload/game_state.gd` — Estado global (`GameState`), inventário, clima, economia, máquinas, encomendas, Álbum e save/load JSON.
- `scripts/autoload/audio_manager.gd` — Sintetizador procedural de efeitos sonoros (`AudioManager`).
- `scripts/world/` e `scenes/` — Mundo da fazenda, clima, pesca, máquinas, jogador, animais (com carinho/corações) e interface/HUD.
- `assets/sprites/` — Spritesheets 16x16 originais + sheets modulares adicionais (`crops_extra_sheet.png`, `v13_props_sheet.png`, `v13_icons.png`).
- `tools/import_pack.py` — Ferramenta CLI para importar pacotes externos (como *Sprout Lands* ou *Kenney Tiny Town*) para `assets/sprites/` com backup automático em `assets/sprites_backup/`.
- `tools/auto_release_bot.py` e `Robozinho_Release.bat` — Robô automatizador de auditoria das 5 Barreiras e publicação de Releases (`Antes vs. Depois`).
- `RELEASE_RULES.md` — Critérios obrigatórios verificados pelo robô antes de subir qualquer nova versão.
- `CHANGELOG.md` — Registro completo de releases, quadro *Antes vs. Depois* e issues resolvidas.

---

## 📋 Histórico de Versões, Issues & Como Atualizar (Fluxo Solo GitHub)

- **Versão atual:** `v1.2.0` (mantida em `project.godot` e `scripts/data/version_data.gd`)
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
2. **Assets & Grade RGBA:** Dimensões exatas dos 5 spritesheets em `assets/sprites/` (`64x32`, `80x48`, `64x64`, `96x48`, `128x16`).
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
