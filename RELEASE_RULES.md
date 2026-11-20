# Regras e Critérios do Robô de Release (`auto_release_bot.py`)

Este documento define as **5 Barreiras Obrigatórias** verificadas pelo robô automatizador (`tools/auto_release_bot.py` / `Robozinho_Release.bat`) antes de aprovar, versionar, gerar build Web e publicar qualquer correção ou melhoria no GitHub.

Se qualquer uma das 5 regras falhar, o robô **REJEITA** a publicação (`STATUS: REJECTED`) e exibe o motivo exato para correção.

---

## As 5 Regras / Barreiras de Critério

### Regra 1 — Barreira de Sintaxe Godot 4.7.2
- **Critério:** Todos os scripts `.gd` em `scripts/` devem compilar sem erros nem warnings críticos no executável oficial do **Godot 4.7.2-stable**.
- **Verificação automática:** Executa `Godot_v4.7.2-stable_win64.exe --headless --no-header --quit --check-only --path . -s res://<script.gd>` em cada arquivo `.gd`, exigindo `EXIT=0` e ausência de `SCRIPT ERROR`.

### Regra 2 — Barreira de Assets & Grade RGBA
- **Critério:** Os 5 spritesheets principais e os 2 spritesheets modulares adicionais em `assets/sprites/` devem existir, estar no modo `RGBA`, conter pixels visíveis (não vazios) e manter exatamente as dimensões esperadas pelo código:
  - `assets/sprites/terrain_tileset.png` -> `64x32` RGBA
  - `assets/sprites/crops_sheet.png` -> `80x96` RGBA
  - `assets/sprites/farmer_sheet.png` -> `64x64` RGBA
  - `assets/sprites/props_buildings.png` -> `96x64` RGBA
  - `assets/sprites/ui_icons.png` -> `256x16` RGBA
  - `assets/sprites/v13_props_sheet.png` -> `112x32` RGBA
  - `assets/sprites/v13_icons.png` -> `256x16` RGBA
  - `assets/sprites/house_interior.png` -> `256x160` RGBA
- **Verificação automática:** Inspeciona todos os PNGs via Python Pillow (`PIL.Image`).

### Regra 3 — Barreira de Boot & Higiene do Repositório
- **Critério:**
  1. A cena principal (`res://scenes/main.tscn`) deve iniciar em `--headless --quit-after 10` com `EXIT=0` e zero erros de runtime ou carregamento de recursos.
  2. Não podem existir arquivos temporários sobrando no repositório (`test_*`, `verify_*`, `tmp_*`, `debug_*`, `*.tmp`, `*.bak`).
  3. Não podem existir segredos ou credenciais expostas (`.env`, `export_credentials.cfg`, tokens `ghp_`/`github_pat_`, chaves privadas).

### Regra 4 — Critério de Mudança Real & Quadro Antes vs. Depois
- **Critério:**
  1. Consistência de versão entre `project.godot` (`config/version`) e `scripts/data/version_data.gd` (`CURRENT_VERSION`), além de entrada correspondente em `CHANGELOG.md` com blocos `before` / `after`.
  2. Em modo `--publish`, é **proibido** subir versão sem alterações reais no Git (`git status --porcelain` vazio).
  3. Toda nova atualização exige título (`--title`), estado anterior (`--before`) e estado corrigido (`--after`) não vazios e distintos entre si, gerando automaticamente o quadro **🔄 Antes vs. Depois**.
  4. Incremento semântico automático:
     - `--bump patch` (`v1.2.0 -> v1.2.1`): correções de bugs (`fix`).
     - `--bump minor` (`v1.2.0 -> v1.3.0`): novas funcionalidades (`feat`).
     - `--bump major` (`v1.2.0 -> v2.0.0`): mudanças estruturais/compatibilidade.

### Regra 5 — Build Web Sincronizado & Rastreabilidade GitHub
- **Critério:**
  1. `export_presets.cfg` (preset `"Web"`) e os artefatos `build/web/index.html`, `index.pck` e `index.wasm` devem estar presentes e válidos.
  2. Em `--publish`: valida autenticação do `gh` CLI (`gh auth status`), atualiza `project.godot`, `scripts/data/version_data.gd` e `CHANGELOG.md`, re-exporta `build/web/index.html` (`EXIT=0`) para manter o GitHub Pages sincronizado com a versão exata, cria/fecha a Issue no GitHub (`gh issue`), realiza `git commit` + `git push` (nunca `--force`) e publica a GitHub Release (`gh release create`) com as notas **Antes vs. Depois**.

---

## Exemplos de Uso

```powershell
# 1. Apenas auditar as 5 barreiras no estado atual (sem alterar arquivos)
python tools/auto_release_bot.py --check

# 2. Simular (dry-run) uma correção de bug patch com preview Antes vs. Depois
python tools/auto_release_bot.py --dry-run --bump patch --title "Corrigir texto da loja" --before "Texto cortava no botão" --after "Texto ajustado com margem na HUD" --fixes "Ajuste de largura mínima no ShopPanel"

# 3. Publicar de verdade (atualiza arquivos, exporta Web, cria Issue/Commit/Push/Release)
python tools/auto_release_bot.py --publish --bump patch --title "Corrigir texto da loja" --before "Texto cortava no botão" --after "Texto ajustado com margem na HUD" --fixes "Ajuste de largura mínima no ShopPanel"
```
