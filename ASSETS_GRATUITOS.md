# Guia de Assets Gratuitos e Substituição de Sprites — Fazendinha 2D

Este documento cataloga os melhores pacotes de **pixel art 100% gratuitos** dos 6 portais recomendados para jogos de fazenda 2D, explica suas **licenças de uso** (comercial vs. não comercial) e ensina como substituir os spritesheets gerados em `assets/sprites/` **sem quebrar nenhuma cena, colisão ou script do Godot 4.7**.

---

## 1. O que já vem pronto neste projeto

### 1.1 Spritesheets 16x16 prontos em `assets/sprites/`
Todos os sprites em jogo já estão gerados em estética *cozy pastel* (inspirada em *Sprout Lands* e *Tiny Town*) pelo script determinístico `tools/generate_sprites.py`:

- `assets/sprites/terrain_tileset.png` (`64x32 px`)
- `assets/sprites/crops_sheet.png` (`80x96 px`)
- `assets/sprites/farmer_sheet.png` (`64x64 px`)
- `assets/sprites/props_buildings.png` (`96x64 px`)
- `assets/sprites/ui_icons.png` (`256x16 px` — 16 ícones incluindo novas sementes, aspersor, lã, trufa e clima)
- `assets/sprites/v13_props_sheet.png` (`112x32 px` — Queijeira, Forno de Pão, Apiário, Quadro de Encomendas, Fertilizante no solo, Boia e Badges)
- `assets/sprites/v13_icons.png` (`256x16 px` — Vara de Pesca, Fertilizante, Queijo, Pão, Mel, Ovo Azul e peixes com assets CC0)
- `assets/sprites/house_interior.png` (`256x160 px` — pisos de madeira, paredes, tapetes, cama, fogão/cozinha, lareira com fogo animado, estante, mesa, cadeiras, escrivaninha, guarda-roupa, plantas e luminária para o interior da casa)

Para regenerar todos os arquivos padrão a qualquer momento:
```bash
python tools/generate_sprites.py
```

### 1.2 Pacotes CC0 baixados automaticamente em `assets/oga_cc0/`
Durante a curadoria automática (sem burlar CAPTCHAs, logins ou bloqueios anti-bot), os seguintes pacotes **CC0 (Domínio Público)** com download direto limpo no OpenGameArt foram baixados e preservados com o arquivo `assets/oga_cc0/LICENSE.txt`:

- **`assets/oga_cc0/oga_16x16_food_cc0/food/`**: 188 ícones 16x16 de alimentos, frutas e legumes (incluindo `egg_whole_white.png` integrado na coluna 6 de `ui_icons.png`, `carrot.png`, `strawberry.png`, `corn.png`, `tomato.png`, `cabbage.png`, `pumpkin.png`, etc.) do pacote **16x16 Food** (*ARoachIFoundOnMyPillow*, CC0).
- **`assets/oga_cc0/oga_16x16_fruits_cc0/fruits_8.png`**: coleção 16x16 de frutas em grade do pacote **16x16 Fruits** (*Leozlk*, CC0).
- **`assets/oga_cc0/oga_pixel_animals_16x16_cc0/Animals.png`**: sprites 16x16 de vaca e ovelha do pacote **Pixel Animals 16x16** (*GrumpyDiamond*, CC0).
- **`assets/oga_cc0/oga_farming_set_cc0/farming set opengameart/`**: cereais, sementes, vegetais, frutas, caixotes e sacos do pacote **Farming Set (Pixel-Art)** (*ScratchIO*, CC0).
- **`assets/oga_cc0/oga_roguelike_indoor_cc0/roguelikeIndoor_transparent.png`**: 486 sprites 16x16 de móveis de interior (cama de casal, estante de livros, bancada/pia/fogão, mesa, cadeiras, guarda-roupa, baú, escrivaninha, vasos de plantas e quadros) do pacote **Roguelike Indoor pack** (*Kenney*, CC0) integrados em `house_interior.png`.
- **`assets/oga_cc0/oga_zelda_like_indoor_cc0/`** (`Inner.png` e `objects.png`): pisos de tábuas de madeira, ladrilhos de cozinha, lareira de tijolos e 3 quadros de fogo animado 16x16 do pacote **Zelda-like tilesets and sprites** (*ArMM1998*, CC0) integrados em `house_interior.png`.

> **Sobre os pacotes da Kenney (`kenney.nl`):** os downloads da Kenney são gratuitos e CC0, porém o site exige interação humana em janela modal no navegador (*"Consider a donation" -> "Continue without donating..."* via JavaScript) antes de gerar a URL temporária do `.zip`. Por isso, eles estão documentados na seção abaixo para download manual pelo seu navegador.

---

## 2. Catálogo dos Melhores Pacotes Gratuitos (6 Sites)

> **Observação de verificação:** Todos os links abaixo foram consultados durante a curadoria. Onde um site aplicou proteção automatizada (HTTP 403/429) ou modal JavaScript, o link está documentado para abertura manual no navegador.

### 2.1 itch.io
1. **Sprout Lands — Asset Pack** *(Cup Nooble)*
   - **Link:** https://cupnooble.itch.io/sprout-lands-asset-pack
   - **UI complementar:** https://cupnooble.itch.io/sprout-lands-ui-pack
   - **Conteúdo:** Tileset 16x16 pastel icônico (grama, água, solo arado, cerca, casa, árvores, trigo/cultivos, galinha, vaca e fazendeiro).
   - **Licença (versão gratuita):** Uso livre em **projetos não comerciais** (com modificação permitida). **Exige crédito** (`Cup Nooble`). Não permite revenda/redistribuição dos arquivos isolados. A versão paga (a partir de US$ 3,99) libera uso comercial e mais animações.
2. **Cozy Farm Tileset LITE (free)** *(glintapps)*
   - **Link:** https://glintapps.itch.io/cozy-farm-tileset-lite-free
   - **Conteúdo:** Amostra gratuita 16x16 modular para fazendinha *top-down* (terreno, tiles e props no estilo cozy).
   - **Licença:** Gratuita para projetos **pessoais e comerciais**, sem exigência obrigatória de atribuição; proibido revender/redistribuir os assets puros ou usá-los para treinar modelos de IA.
3. **Cozy Farm (Free Version)** *(shubibubi)*
   - **Link:** https://shubibubi.itch.io/cozy-farm
   - **Conteúdo:** Tilesets, cultivos, animais e construções 16x16 fofos em paleta quente.
   - **Licença (versão gratuita):** Uso permitido em **projetos não comerciais** (crédito apreciado); versão completa (US$ 3,99+) libera uso comercial.
   - *(Outras variações encontradas na busca com o título "Cozy Farm Lite" incluem https://ericx00.itch.io/cozy-farm-lite e https://aquumgifts.itch.io/cozy-farm-lite — confira sempre a licença na página antes de publicar.)*
4. **Farm & Ranch Life** *(Michel Clauwaert)*
   - **Link encontrado na busca:** https://michelclauwaert.itch.io/farm-ranch-life *(Nota: retornou HTTP 404 na verificação direta no momento da criação deste guia; caso permaneça indisponível ao abrir no navegador, utilize o Sprout Lands ou Cozy Farm acima).*
   - **Conteúdo descrito:** Série 16x16 *top-down* com cultivos multiestágio, árvores frutíferas, animais animados e ferramentas.
5. **[8x8] Tiny Ranch Asset Pack** *(Gustavo Vituri)*
   - **Link:** https://gvituri.itch.io/tiny-ranch
   - **Conteúdo:** Pack minimalista em **8x8 px** com chão, água, decorações, personagens e animais de rancho.
   - **Observação técnica:** Como a grade é **8x8**, será necessário escalar em `2x` (*nearest-neighbor*, ficando `16x16`) antes de colar nos spritesheets do projeto. Confira os termos de licença na página/comentários do autor antes de uso comercial.

### 2.2 Kenney (100% CC0 — Domínio Público)
Todos os pacotes da Kenney são **CC0 1.0 Universal**: gratuitos para uso pessoal e comercial sem obrigação de crédito (embora créditos sejam bem-vindos). Para baixar, abra o link no navegador, clique em **Download** e depois em **Continue without donating...**.

1. **Tiny Town**
   - **Link:** https://kenney.nl/assets/tiny-town
   - **Conteúdo:** 130 sprites 16x16 *top-down* (grama, caminhos, cercas, telhados/casinhas, árvores, poço e props de vila). Encaixa muito bem em `terrain_tileset.png` e `props_buildings.png`.
2. **Pixel Platformer Farm Expansion**
   - **Link:** https://kenney.nl/assets/pixel-platformer-farm-expansion
   - **Conteúdo:** Mais de 110 sprites gratuitos temáticos de fazenda (cultivos, estufas, ferramentas e props em paleta outonal/quente).
3. **RPG Urban Pack** *(frequentemente referido como "RPG Urban Kit")*
   - **Link oficial:** https://kenney.nl/assets/rpg-urban-pack *(Nota: a URL `/rpg-urban-kit` retorna 404; o endereço oficial na Kenney é `/rpg-urban-pack`).*
   - **Conteúdo:** Mais de 480 tiles *top-down* incluindo personagens com caminhada em 4 direções, construções e vegetação adaptáveis para vila e loja.

### 2.3 CraftPix
Os **Freebies** do CraftPix permitem uso em projetos **pessoais e comerciais** (inclusive jogos pagos), sem atribuição obrigatória; é proibido revender ou redistribuir os arquivos originais/editados como pacote de assets. Requer abrir a página no navegador para clicar em *Free Download*.

1. **Free Pixel Art Plants for Farm**
   - **Link:** https://craftpix.net/freebies/free-pixel-art-plants-for-farm/
   - **Conteúdo:** Plantas e cultivos com múltiplos estágios de crescimento (sementes a colheita, incluindo trigo, cenoura, repolho, beterraba), árvores frutíferas, arbustos, saquinhos de semente e caixotes.
2. **Free Top-Down Animals Farm Pixel Art Sprites**
   - **Link:** https://craftpix.net/freebies/free-top-down-animals-farm-pixel-art-sprites/
   - **Conteúdo:** 8 animais de fazenda animados para visão *top-down* (ovelhas, touros/bezerros, galos/pintinhos, perus e porquinhos) em PNG e PSD.

### 2.4 OpenGameArt
1. **16x16 Food** *(ARoachIFoundOnMyPillow)* — **CC0** (já baixado em `assets/oga_cc0/oga_16x16_food_cc0/`)
   - **Link:** https://opengameart.org/content/16x16-food
   - **Conteúdo:** 188 ícones 16x16 de alimentos, legumes e frutas prontos para usar na loja, cesta ou como ícones de colheita (`egg_whole_white.png` já utilizado em `ui_icons.png`).
2. **16x16 Fruits** *(Leozlk)* — **CC0** (já baixado em `assets/oga_cc0/oga_16x16_fruits_cc0/`)
   - **Link:** https://opengameart.org/content/16x16-fruits
   - **Conteúdo:** Grade simples de frutas 16x16 em domínio público.
3. **Pixel Animals 16x16** *(GrumpyDiamond)* — **CC0** (já baixado em `assets/oga_cc0/oga_pixel_animals_16x16_cc0/`)
   - **Link:** https://opengameart.org/content/pixel-animals-16x16
   - **Conteúdo:** Sprites 16x16 leves de vaca e ovelha em domínio público.
4. **Farming Set (Pixel-Art)** *(ScratchIO)* — **CC0** (já baixado em `assets/oga_cc0/oga_farming_set_cc0/`)
   - **Link:** https://opengameart.org/content/farming-set-pixel-art
   - **Conteúdo:** Cereais, sacos de sementes, vegetais, ferramentas, feno e caixotes em domínio público.
5. **LPC Crops** *(Liberated Pixel Cup)* — **ATENÇÃO: Licença CC-BY-SA 4.0 (não CC0)**
   - **Link:** https://opengameart.org/content/lpc-crops
   - **Conteúdo:** Cultivos completos e detalhados no estilo LPC (escala maior/32x32, exigindo recorte ou redução para 16x16).
   - **Cuidado com a licença:** Por ser **CC-BY-SA 4.0**, exige atribuição explícita aos autores **e** que eventuais adaptações/assets derivados distribuídos sigam a mesma licença *ShareAlike* (CC-BY-SA). Se quiser manter o projeto 100% livre de *copyleft*, prefira pacotes **CC0**.

### 2.5 GameDev Market
1. **Basic Pixel Farm Pack** *(Iphigenia)*
   - **Link encontrado na busca:** https://www.gamedevmarket.net/asset/basic-pixel-farm-pack *(acesso automatizado retornou HTTP 403 anti-bot; abra diretamente no navegador).*
   - **Conteúdo:** Pack gratuito de fazenda em estilo fofo com animais animados (2–3 quadros) e tiles básicos em resolução nativa **32x32 px** (necessário reduzir para 50% com interpolação *Nearest* para usar diretamente nos slots 16x16 deste projeto).
   - **Licença:** Licença padrão da plataforma (uso comercial/não comercial em jogos compilados; vedada redistribuição isolada dos sprites).

### 2.6 Game Developer Studio (Assets + Ferramentas de Slicing)
A licença geral do **Game Developer Studio** permite uso gratuito em projetos pessoais e comerciais (jogos e apps derivados); proíbe revender ou redistribuir os arquivos de imagem isolados.

1. **Grass top tiles free** *(Robert Brooks)*
   - **Portal:** https://www.gamedeveloperstudio.com/ *(pesquise por "Grass top tiles free")*
   - **Conteúdo:** 10 tiles gratuitos em PNG HD (**256x256 px**), voltados originalmente para jogos de plataforma (*side-scrolling*). Caso deseje usá-los em pixel art 16x16, é preciso reduzir mantendo nitidez ou usar como inspiração/fundo alternativo.
2. **Packs gratuitos top-down de fazenda descobertos no catálogo free (`?filter=free`):**
   - **Top-Down Farming Tile Set:** https://www.gamedeveloperstudio.com/graphics/viewgraphic.php?page-name=top-down-farming-tile-set&item=_uMxlLbHeoO
   - **Catálogo gratuito geral:** https://www.gamedeveloperstudio.com/graphics/index.php?filter=free
3. **Ferramentas Web de Slicing & Montagem:**
   - **Spritesheet Slicing and Animating Tool:** https://www.gamedeveloperstudio.com/tools/spritesheet_slicer.php
   - **Central de Ferramentas GDS:** https://www.gamedeveloperstudio.com/tools/
   - **Para que serve:** Permite enviar um spritesheet grande de qualquer pacote baixado, definir colunas/linhas, pré-visualizar animações em tempo real, remover bordas vazias e exportar quadros individuais prontos para encaixar na grade exata do projeto.

---

## 3. Resumo Rápido de Licenças

| Licença | Uso Comercial? | Precisa dar Crédito? | Pode Redistribuir Assets Puros? | Exemplos |
| :--- | :---: | :---: | :---: | :--- |
| **CC0 1.0 (Domínio Público)** | Sim | Não (opcional) | Sim (é domínio público) | Kenney, OpenGameArt `16x16 Food` / `16x16 Fruits` |
| **Freebie / Standard Game License** | Sim | Geralmente não (recomendado) | **Não** | CraftPix Freebies, Cozy Farm Tileset LITE (glintapps), GDS, GameDev Market |
| **Free Non-Commercial** | **Não** (só versão paga) | **Sim** | **Não** | Sprout Lands (Free), Cozy Farm (Free — shubibubi) |
| **CC-BY-SA 4.0** | Sim | **Sim (obrigatório)** | Sim, **sob a mesma licença SA** | OpenGameArt `LPC Crops` |

---

## 4. Como Substituir em `assets/sprites/` Sem Quebrar o Jogo

O Godot carrega os 5 arquivos abaixo diretamente por código usando dimensões e regiões fixas (`AtlasTexture` / `Rect2` / `TileSetAtlasSource`). **Se você mantiver exatamente o nome do arquivo, o tamanho total em pixels, o fundo transparente (RGBA) e a posição de cada célula**, a troca funciona instantaneamente sem editar nenhuma linha de GDScript ou `.tscn`.

### 4.1 Contrato Exato dos 5 Arquivos

#### 1. `assets/sprites/terrain_tileset.png` — **`64 x 32 px`** (grade `4 x 2` de tiles `16x16`)
| Coordenada `(col, row)` | Posição `(x, y)` | Tile esperado pelo jogo | Fundo |
| :---: | :---: | :--- | :--- |
| `(0, 0)` | `x=0, y=0` | Grama lisa vibrante | Opaco |
| `(1, 0)` | `x=16, y=0` | Grama com florzinhas/detalhes | Opaco |
| `(2, 0)` | `x=32, y=0` | Caminho de terra batida | Opaco |
| `(3, 0)` | `x=48, y=0` | Água azul estilizada (lago) | Opaco |
| `(0, 1)` | `x=0, y=16` | Terra arada seca (marrom claro) | Opaco |
| `(1, 1)` | `x=16, y=16` | Terra arada molhada (marrom escuro) | Opaco |
| `(2, 1)` | `x=32, y=16` | Cerca de madeira (16x16) | Transparente |
| `(3, 1)` | `x=48, y=16` | Caixa de venda / Shipping bin (16x16) | Transparente |

#### 2. `assets/sprites/crops_sheet.png` — **`80 x 96 px`** (grade `5 x 6` de células `16x16`, fundo transparente)
- **Colunas (estágios):** `0` (`x=0`) = Sementes, `1` (`x=16`) = Broto, `2` (`x=32`) = Crescendo, `3` (`x=48`) = Florindo, `4` (`x=64`) = Maduro.
- **Linhas (culturas):**
  - Linha `0` (`y=0`): **Trigo** (`wheat`)
  - Linha `1` (`y=16`): **Cenoura** (`carrot`)
  - Linha `2` (`y=32`): **Morango** (`strawberry`)
  - Linha `3` (`y=48`): **Milho** (`corn`)
  - Linha `4` (`y=64`): **Tomate** (`tomato`)
  - Linha `5` (`y=80`): **Abóbora** (`pumpkin`)

#### 3. `assets/sprites/farmer_sheet.png` — **`64 x 64 px`** (grade `4 x 4` de quadros `16x16`, fundo transparente)
- **Colunas `0..3`:** 4 quadros da animação de caminhada (`idle / passo 1 / idle / passo 2`).
- **Linhas (direções):**
  - Linha `0` (`y=0`): Olhando para **Baixo**
  - Linha `1` (`y=16`): Olhando para **Cima**
  - Linha `2` (`y=32`): Olhando para **Esquerda**
  - Linha `3` (`y=48`): Olhando para **Direita**

#### 4. `assets/sprites/props_buildings.png` — **`96 x 64 px`** (fundo transparente)
| Elemento | `Rect2(x, y, w, h)` exato | Observação |
| :--- | :--- | :--- |
| Casinha da fazenda | `(0, 0, 32, 32)` | Ocupa 2x2 tiles |
| Árvore frondosa | `(32, 0, 32, 32)` | Ocupa 2x2 tiles |
| Pedra | `(64, 0, 16, 16)` | 1x1 tile |
| Arbusto | `(80, 0, 16, 16)` | 1x1 tile |
| Poço d'água | `(64, 16, 16, 16)` | 1x1 tile |
| Placa da Loja | `(80, 16, 16, 16)` | 1x1 tile |
| Galinha (2 quadros) | `(0, 32, 16, 16)` e `(16, 32, 16, 16)` | Animação 2 frames |
| Vaca (2 quadros) | `(32, 32, 16, 16)` e `(48, 32, 16, 16)` | Animação 2 frames |
| Ovelha (2 quadros) | `(64, 32, 16, 16)` e `(80, 32, 16, 16)` | Animação 2 frames |
| Porco (2 quadros) | `(0, 48, 16, 16)` e `(16, 48, 16, 16)` | Animação 2 frames |
| Aspersor Automático | `(32, 48, 16, 16)` | 1x1 tile |

#### 5. `assets/sprites/ui_icons.png` — **`256 x 16 px`** (grade `16 x 1` de ícones `16x16`, fundo transparente)
- `col 0` (`x=0`): **Enxada** · `col 1` (`x=16`): **Regador**
- `col 2..4` (`x=32..64`): **Sementes de Trigo, Cenoura e Morango**
- `col 5` (`x=80`): **Moeda dourada** · `col 6` (`x=96`): **Ovo (`egg`)** · `col 7` (`x=112`): **Garrafa de Leite (`milk`)**
- `col 8..10` (`x=128..160`): **Sementes de Milho, Tomate e Abóbora**
- `col 11` (`x=176`): **Aspersor Automático**
- `col 12` (`x=192`): **Lã (`wool`)** · `col 13` (`x=208`): **Trufa (`truffle`)**
- `col 14` (`x=224`): **Sol** · `col 15` (`x=240`): **Chuva**

### 4.2 Importação Automática (`tools/import_pack.py`) para Sprout Lands e Kenney Tiny Town
Depois de baixar pelo navegador o `.zip` de **Sprout Lands** (itch.io) ou **Kenney Tiny Town** (kenney.nl), você pode importar e remapear os sprites automaticamente sem precisar editar cada arquivo manualmente:

```bash
# Inspecionar arquivos PNG dentro do .zip antes de importar
python tools/import_pack.py --source "C:\caminho\Sprout Lands - Sprites - Basic pack.zip" --list

# Simular o mapeamento sem alterar nada (--dry-run)
python tools/import_pack.py --source "C:\caminho\Sprout Lands - Sprites - Basic pack.zip" --dry-run

# Importar automaticamente (detecta Sprout Lands ou Kenney Tiny Town e cria backup em assets/sprites_backup/)
python tools/import_pack.py --source "C:\caminho\Sprout Lands - Sprites - Basic pack.zip"

# Exemplo especificando o pacote Kenney Tiny Town (aceita .zip ou pasta extraída)
python tools/import_pack.py --pack kenney-tiny-town --source "C:\caminho\kenney_tiny-town.zip"

# Desfazer e restaurar os sprites originais a partir de assets/sprites_backup/
python tools/import_pack.py --restore
```

> **Como funciona com segurança:** o script cria um backup automático em `assets/sprites_backup/` antes da primeira substituição, preserva os sprites originais para slots que não existam no pacote externo (por exemplo, novos animais ou culturas extras) e garante as dimensões exatas (`64x32`, `80x96`, `64x64`, `96x64` e `256x16`) em RGBA com interpolação *Nearest Neighbor*.

### 4.3 Passo a passo manual para qualquer outro pack gratuito
1. **Baixe e extraia** o pacote escolhido em uma pasta temporária fora de `assets/sprites/`.
2. **Fatie os sprites originais** usando:
   - O **Spritesheet Slicer da GDS** (https://www.gamedeveloperstudio.com/tools/spritesheet_slicer.php), definindo a grade (`16x16`), ou
   - Um editor de pixel art gratuito como **LibreSprite** / **Aseprite** / **GIMP** / **Piskel**.
3. **Respeite a regra de nitidez (Pixel Art):**
   - Sempre que copiar, mover ou redimensionar (por exemplo, reduzir 32x32 para 16x16 ou ampliar 8x8 para 16x16), use **Interpolação: Nenhum / Nearest Neighbor** para não borrar os pixels.
   - Salve sempre como **PNG 32-bit RGBA** (com canal alfa transparente).
4. **Cole cada célula na coordenada exata** da tabela da seção **4.1** (você pode usar os arquivos atuais em `assets/sprites/` como gabarito de camadas no seu editor!).
5. **Substitua o arquivo PNG** em `assets/sprites/` mantendo exatamente o mesmo nome (ex.: `assets/sprites/farmer_sheet.png`).
6. **Abra o Godot 4.7.2**: o motor reimportará o PNG automaticamente (já configurado com filtro *Nearest* em `project.godot`), e todos os tiles, animações, ícones da hotbar e colisões continuarão funcionando imediatamente!
