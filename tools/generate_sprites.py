#!/usr/bin/env python3
"""
Gerador determinístico de spritesheets 16x16 pixel art para Fazendinha 2D (Godot 4.7).
Estética cozy pastel inspirada em Sprout Lands (Cup Nooble) e Tiny Town (Kenney).
Integra sprites CC0 reais de assets/oga_cc0/ quando disponíveis (com fallback embutido).

Arquivos gerados em assets/sprites/:
- terrain_tileset.png : 64x32 px (4 cols x 2 rows de 16x16)
- crops_sheet.png     : 80x48 px (5 cols x 3 rows de 16x16)
- farmer_sheet.png    : 64x64 px (4 cols walk x 4 rows direções de 16x16)
- props_buildings.png : 96x48 px (casinha 32x32, árvore 32x32, props 16x16, animais 2 frames)
- ui_icons.png        : 128x16 px (8 ícones 16x16: enxada, regador, 3 sementes, moeda, ovo, leite)
"""

from pathlib import Path
from PIL import Image

ROOT_DIR = Path(__file__).resolve().parent.parent
SPRITES_DIR = ROOT_DIR / "assets" / "sprites"
OGA_FOOD_DIR = ROOT_DIR / "assets" / "oga_cc0" / "oga_16x16_food_cc0" / "food"

RGBA = tuple[int, int, int, int]


def hex_rgba(code: str, alpha: int = 255) -> RGBA:
    code = code.lstrip("#")
    return (int(code[0:2], 16), int(code[2:4], 16), int(code[4:6], 16), alpha)


TRANSPARENT: RGBA = (0, 0, 0, 0)

# Paleta cozy pastel unificada (sombreamento em múltiplos tons)
PAL: dict[str, RGBA] = {
    ".": TRANSPARENT,
    # Contornos suaves
    "k": hex_rgba("#382828"),  # contorno quente escuro
    "K": hex_rgba("#291d21"),  # contorno bem escuro
    "G": hex_rgba("#294a30"),  # contorno verde escuro
    "B": hex_rgba("#42281c"),  # contorno madeira
    "R": hex_rgba("#592329"),  # contorno telhado/vermelho
    "N": hex_rgba("#28405c"),  # contorno azul
    # Grama e folhas
    "g": hex_rgba("#76c44e"),  # grama base vibrante
    "h": hex_rgba("#8cd95b"),  # grama luz
    "m": hex_rgba("#62b040"),  # grama média
    "d": hex_rgba("#4f9633"),  # grama sombra
    "f": hex_rgba("#46852f"),  # folha média
    "F": hex_rgba("#356b26"),  # folha escura
    "l": hex_rgba("#a4e66c"),  # folha/broto claro
    "L": hex_rgba("#ccf595"),  # brilho folha
    # Flores e detalhes
    "w": hex_rgba("#fffaf0"),  # branco creme
    "W": hex_rgba("#e6dfd1"),  # branco sombra
    "y": hex_rgba("#ffd95c"),  # amarelo ouro claro
    "Y": hex_rgba("#f0b535"),  # amarelo escuro
    "p": hex_rgba("#ffa3b5"),  # rosa pastel
    "P": hex_rgba("#e36d86"),  # rosa escuro
    # Terra e caminhos
    "t": hex_rgba("#d9b280"),  # terra batida base
    "T": hex_rgba("#ebc99d"),  # terra luz
    "u": hex_rgba("#c29763"),  # terra sombra média
    "U": hex_rgba("#a67847"),  # terra pedrinha
    # Terra arada seca
    "s": hex_rgba("#ba8454"),  # solo seco base
    "S": hex_rgba("#d4a06e"),  # solo seco crista
    "z": hex_rgba("#946039"),  # solo seco sulco
    "Z": hex_rgba("#734625"),  # solo seco sulco fundo
    # Terra arada molhada
    "v": hex_rgba("#70472e"),  # solo molhado base
    "V": hex_rgba("#926b54"),  # solo molhado brilho úmido
    "q": hex_rgba("#522f1d"),  # solo molhado sulco
    "Q": hex_rgba("#381e10"),  # solo molhado fundo
    # Água
    "a": hex_rgba("#57b9db"),  # água base
    "A": hex_rgba("#4097bd"),  # água profunda
    "b": hex_rgba("#8be0f5"),  # água onda clara
    "c": hex_rgba("#dff9ff"),  # água brilho
    # Madeira
    "o": hex_rgba("#a66742"),  # madeira base
    "O": hex_rgba("#c9895b"),  # madeira luz
    "e": hex_rgba("#7a462b"),  # madeira sombra
    "E": hex_rgba("#e6b385"),  # madeira destaque
    # Pedra / Metal
    "i": hex_rgba("#9fa8b5"),  # cinza pedra/ferro
    "I": hex_rgba("#cdd6e0"),  # cinza claro
    "j": hex_rgba("#757e8c"),  # cinza sombra
    "J": hex_rgba("#505763"),  # cinza escuro
    # Casa / Telhado / Paredes
    "r": hex_rgba("#de6454"),  # telhado coral
    "x": hex_rgba("#f5937d"),  # telhado luz
    "X": hex_rgba("#b0423a"),  # telhado sombra
    "n": hex_rgba("#f7edd9"),  # parede creme
    "M": hex_rgba("#dfd0b2"),  # parede sombra
    # Personagem / Culturas
    "C": hex_rgba("#f7c8a6"),  # pele clara
    "D": hex_rgba("#de9f78"),  # pele sombra
    "H": hex_rgba("#f5ce73"),  # chapéu palha / ouro
    "0": hex_rgba("#cc9635"),  # chapéu sombra / ouro escuro
    "1": hex_rgba("#d95252"),  # fita chapéu / morango
    "2": hex_rgba("#ff8282"),  # morango luz
    "3": hex_rgba("#9e2431"),  # morango sombra
    "4": hex_rgba("#5285c4"),  # macacão azul
    "5": hex_rgba("#75abeb"),  # macacão luz
    "6": hex_rgba("#365a8f"),  # macacão sombra
    "7": hex_rgba("#f59342"),  # cenoura laranja
    "8": hex_rgba("#ffbd66"),  # cenoura luz
    "9": hex_rgba("#c75d22"),  # cenoura sombra
}


def render_grid(
    rows: list[str],
    width: int,
    height: int,
    extra_pal: dict[str, RGBA] | None = None,
) -> Image.Image:
    """Converte uma matriz ASCII em Image RGBA com validação estrita de dimensões."""
    if len(rows) != height:
        raise ValueError(f"Esperado {height} linhas, obtido {len(rows)}")
    pal = dict(PAL)
    if extra_pal:
        pal.update(extra_pal)
    img = Image.new("RGBA", (width, height), TRANSPARENT)
    px = img.load()
    for y, row in enumerate(rows):
        if len(row) != width:
            raise ValueError(f"Linha {y} tem largura {len(row)}, esperado {width}: {row!r}")
        for x, ch in enumerate(row):
            if ch not in pal:
                raise KeyError(f"Caractere {ch!r} não definido na paleta em ({x},{y})")
            px[x, y] = pal[ch]
    return img


def paste_tile(sheet: Image.Image, tile: Image.Image, x: int, y: int) -> None:
    sheet.paste(tile, (x, y), tile)


# ==============================================================================
# 1. TERRAIN TILESET (64x32 px = 4x2 tiles de 16x16)
# ==============================================================================
def build_terrain_tileset() -> Image.Image:
    sheet = Image.new("RGBA", (64, 32), TRANSPARENT)

    # (0,0) Grama lisa vibrante com tufos sutis
    grass_plain = [
        "ggggghmgggggggmg",
        "ghggggggmggggggg",
        "ggggdgggggghgggg",
        "ggmhggggggggdggg",
        "ggggggghmgggmggg",
        "ggdggggggggdgggg",
        "gggggmgggggggggh",
        "hgggggghmghggggg",
        "gggggggggggggmgg",
        "gggghggggdgggggg",
        "gmggggggggggghmg",
        "ggggdggggggggggg",
        "gggggghmgggggdgg",
        "gghggggggggggggg",
        "gggggggdggghmggg",
        "ggggmggggggggggg",
    ]
    paste_tile(sheet, render_grid(grass_plain, 16, 16), 0, 0)

    # (1,0) Grama com florzinhas/detalhes cozy
    grass_flowers = [
        "ggggghmgggggggmg",
        "ghwgggggmggggggg",
        "gwYwgghggggpgggg",
        "ggwggggdggpYpggg",
        "ggggmggghgggpmgg",
        "ggdggggggggdgggg",
        "gggggmgggggggggh",
        "hggggwggggghgggg",
        "ggggwYwggggggmgg",
        "gggggwgggdgggggg",
        "gmgggggggggghggg",
        "gggggdgggpgggggg",
        "ggggggggpYpggdgg",
        "gghggggggmgggggg",
        "ggggwggdggghmggg",
        "gggwYwgggggggggg",
    ]
    paste_tile(sheet, render_grid(grass_flowers, 16, 16), 16, 0)

    # (2,0) Caminho de terra batida com pedrinhas sombreadas
    dirt_path = [
        "ttTttutttttTtttt",
        "ttttttttutttttTt",
        "tTttTUtttttttutt",
        "ttttuutTtttutttt",
        "tuttttttttTttttt",
        "ttttutTttttttTUu",
        "ttTttttttutttttt",
        "ttttttutttttTttt",
        "ttttttttTttttttt",
        "tTUtutttttutttUt",
        "ttttutttttttTttt",
        "tttttttTtttttttt",
        "tuttttttttutttTt",
        "tttTtTUutttttttt",
        "ttttttttttTttutt",
        "ttttuttttttttttt",
    ]
    paste_tile(sheet, render_grid(dirt_path, 16, 16), 32, 0)

    # (3,0) Água azul estilizada (lago com ondas e brilhos)
    water_tile = [
        "aaaaaaaaaaaaaaaa",
        "aAAaaaaabcaaaaaa",
        "aaaaabbbbaaaaAAa",
        "aaabcaaaaaaaaaaa",
        "aaaaaaaaaAAaaaaa",
        "aaaaAAaaaaaaaabb",
        "aaaaaaaaaabcaaaa",
        "abcaaaaAAaaaaaaa",
        "aaaaabbbbaaaaaAA",
        "aaaaabcaaaaaaaaa",
        "aaaaaaaaaaaabcaa",
        "aaAAaaaaaaaabbaa",
        "aaaaaaabcaaaAAaa",
        "aaabbbbaaaaaaaaa",
        "aaaaaaaaAAaaaaba",
        "aaaaaaaaaaaaaaaa",
    ]
    paste_tile(sheet, render_grid(water_tile, 16, 16), 48, 0)

    # (0,1) Terra arada seca (sulcos marrom claro contínuos)
    tilled_dry = [
        "ssssssssssssssss",
        "SSsSSSSSSsSSSSSS",
        "zzszzzzzzszzzzzz",
        "ZZsZZZZZZsZZZZZZ",
        "ssssssssssssssss",
        "SSSSSsSSSSSSsSSS",
        "zzzzzszzzzzzszzz",
        "ZZZZZsZZZZZZsZZZ",
        "ssssssssssssssss",
        "SSsSSSSSSsSSSSSS",
        "zzszzzzzzszzzzzz",
        "ZZsZZZZZZsZZZZZZ",
        "ssssssssssssssss",
        "SSSSSsSSSSSSsSSS",
        "zzzzzszzzzzzszzz",
        "ZZZZZsZZZZZZsZZZ",
    ]
    paste_tile(sheet, render_grid(tilled_dry, 16, 16), 0, 16)

    # (1,1) Terra arada molhada (sulcos marrom escuro com reflexo úmido)
    tilled_wet = [
        "vvvvvvvvvvvvvvvv",
        "VVvVVVVVVvVVVVVV",
        "qqvqqqqqqvqqqqqq",
        "QQvQQQQQQvQQQQQQ",
        "vvvvvvvvvvvvvvvv",
        "VVVVVvVVVVVVvVVV",
        "qqqqqvqqqqqqvqqq",
        "QQQQQvQQQQQQvQQQ",
        "vvvvvvvvvvvvvvvv",
        "VVvVVVVVVvVVVVVV",
        "qqvqqqqqqvqqqqqq",
        "QQvQQQQQQvQQQQQQ",
        "vvvvvvvvvvvvvvvv",
        "VVVVVvVVVVVVvVVV",
        "qqqqqvqqqqqqvqqq",
        "QQQQQvQQQQQQvQQQ",
    ]
    paste_tile(sheet, render_grid(tilled_wet, 16, 16), 16, 16)

    # (2,1) Cerca de madeira (16x16, fundo transparente, conecta horizontalmente)
    fence = [
        "................",
        "..BBB......BBB..",
        ".BOEEB....BOEEB.",
        ".BOooB....BOooB.",
        "BBOooBBBBBBooOBB",
        "EEOooooooooooOEE",
        "BBOeeBBBBBBeeOBB",
        ".BOeeB....BOeeB.",
        ".BOooB....BOooB.",
        "BBOooBBBBBBooOBB",
        "OOoooOOOOOOoooOO",
        "BBOeeBBBBBBeeOBB",
        ".BOeeB....BOeeB.",
        ".BeBBB....BeBBB.",
        "..BBB......BBB..",
        "................",
    ]
    paste_tile(sheet, render_grid(fence, 16, 16), 32, 16)

    # (3,1) Caixa de venda / Shipping bin de madeira (16x16, fundo transparente)
    shipping_bin = [
        "................",
        "..BBBBBBBBBBBB..",
        ".BOEEEEEEEEEEOB.",
        ".BOOOOOOOOOOOOB.",
        "BBOooooooooooOBB",
        "BJIIIIIIIIIIIIJB",
        "BJoeoooooooooeJB",
        "BBoBBBBYYBBBBoBB",
        "BOoBoeeYYeeBoOoB",
        "BOoBooooooooBoOB",
        "BBoBBBBBBBBBBooB",
        "BJooeeooooeeooJB",
        "BJeeeeeeeeeeeeJB",
        ".BJJJJJJJJJJJJB.",
        "..BBBBBBBBBBBB..",
        "................",
    ]
    paste_tile(sheet, render_grid(shipping_bin, 16, 16), 48, 16)

    return sheet


# ==============================================================================
# 2. CROPS SHEET (80x48 px = 5 estágios x 3 culturas de 16x16)
# ==============================================================================
def build_crops_sheet() -> Image.Image:
    sheet = Image.new("RGBA", (80, 48), TRANSPARENT)

    # Row 0 (y=0): Trigo (wheat)
    wheat_stages = [
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            ".....kk.........",
            "....kHyk...kk...",
            ".....kk...kHyk..",
            "..kk.......kk...",
            ".kHyk..kk.......",
            "..kk..kHyk......",
            ".......kk.......",
            "................",
        ],
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "......GG........",
            ".....GLlG.......",
            "......GlG..GG...",
            ".......GG.GLlG..",
            ".......GlGGfG...",
            ".......GfGG.....",
            ".......GFFG.....",
            "........GG......",
        ],
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            ".....GG...GG....",
            "....GLG..GLG....",
            "....GlG..GlG.GG.",
            ".GG.GfG..GfGGLG.",
            "GLG.GfG..GfGGlG.",
            ".GlGGfGGGGfGGfG.",
            "..GfGfGfGfGfGfG.",
            "...GFFfFFfFFfG..",
            "....GFFFFFFFG...",
            ".....GGGGGGG....",
            "................",
        ],
        [
            "................",
            "................",
            ".....kk..kk.....",
            "....kHykkHyk....",
            "....kYykkyYk.kk.",
            ".kk.kGfGGfGkHyyk",
            "kHykGfGGfGGkYyk.",
            "kYykGfGGfGGfGG..",
            ".GlGGfGGfGGfG...",
            "..GfGfGfGfGfG...",
            "..GfGfGfGfGfG...",
            "...GFFfFFfFFG...",
            "...GFFFFFFFFG...",
            "....GFFFFFFG....",
            ".....GGGGGG.....",
            "................",
        ],
        [
            "......kk...kk...",
            ".....kHyk.kHyk..",
            "..kk.kYykkkyYk..",
            ".kHyk.kYYkYYk.kk",
            ".kYyk.k0YkY0kHyk",
            "..kYYkk0Y00kkyYk",
            "...k0Ykk0Yk.kY0k",
            "...k00kk00kk00k.",
            "....kGfGGfGG0k..",
            "....kGfGGfGGk...",
            ".....kGfGfGk....",
            ".....kYYYYYk....",
            ".....k00000k....",
            "......kGfGk.....",
            "......kGGGk.....",
            ".......kkk......",
        ],
    ]

    # Row 1 (y=16): Cenoura (carrot)
    carrot_stages = [
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "......kk........",
            ".....k78k.......",
            "..kk..kk...kk...",
            ".k78k.....k78k..",
            "..kk..kk...kk...",
            ".....k78k.......",
            "......kk........",
            "................",
        ],
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "....GG..GG......",
            "...GLlGGLlG.....",
            "....GfhGfhG.....",
            ".....GffGG......",
            "......GfG.......",
            "......GFG.......",
            ".......G........",
            "................",
        ],
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "....GG....GG....",
            "...GLlG..GLlG...",
            "..GGfhGGGGfhGG..",
            ".GLlGffGGffGLlG.",
            "..GffGffffGffG..",
            "...GffffffffG...",
            "....GffFFffG....",
            ".....GFFFFG.....",
            "......GGGG......",
            "................",
            "................",
        ],
        [
            "................",
            "......GGGG......",
            "....GGLhhLLGG...",
            "...GLhGffGhLLG..",
            "..GGffGffGffGG..",
            ".GLhGffffffGhLG.",
            "..GffGffffGffG..",
            "...GffGffGffG...",
            "....GGffffGG....",
            ".....Gkk7kk.....",
            ".....k8779k.....",
            "......k77k......",
            "......k99k......",
            ".......kk.......",
            "................",
            "................",
        ],
        [
            "....GG....GG....",
            "...GLlG..GLlG...",
            "..GGfhGGGGfhGG..",
            ".GLhGffffffGhLG.",
            "..GffGffffGffG..",
            "...GGffGGffGG...",
            "....sGkkkkGs....",
            "...zk887779kz...",
            "....k877979k....",
            "....k777779k....",
            ".....k7779k.....",
            ".....k7799k.....",
            "......k79k......",
            "......k99k......",
            ".......kk.......",
            "................",
        ],
    ]

    # Row 2 (y=32): Morango (strawberry)
    strawberry_stages = [
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "....kk..........",
            "...k21k....kk...",
            "....kk....k21k..",
            "......kk...kk...",
            "..kk.k21k.......",
            ".k21k.kk........",
            "..kk............",
            "................",
        ],
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            ".....GG.GG......",
            "....GLGGhLG.....",
            "....GfGGfhG.....",
            ".....GffGG......",
            "......GfG.......",
            "......GFG.......",
            ".......G........",
            "................",
        ],
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            ".....GGGGGG.....",
            "...GGLhhhhLLGG..",
            "..GLhGffffGhLLG.",
            "..GfGffffffGfG..",
            "..GffGffffGffG..",
            "...GffffffffG...",
            "....GffFFffG....",
            ".....GFFFFG.....",
            "......GGGG......",
            "................",
            "................",
        ],
        [
            "................",
            ".....GGGGGG.....",
            "...GGLhhhhLLGG..",
            "..GLhGwwffGhLLG.",
            "..GffwYwfGfwwG..",
            ".GLhfGwwffffwYw.",
            "..GfffffGGffwwG.",
            "..GffwwfffffGfG.",
            "...GwYwffFFffG..",
            "....GwwFFFFGG...",
            ".....GGGGGGG....",
            "................",
            "................",
            "................",
            "................",
            "................",
        ],
        [
            ".....GGGGGG.....",
            "...GGLhhhhLLGG..",
            "..GLhGffffGhLLG.",
            "..Gfk1kfffk1kG..",
            ".GLk213kfk213kG.",
            "..Gk1y1kfk1y1kG.",
            "..Gfk3kfGk3kffG.",
            "..Gfffk1kfffGfG.",
            "...Gfk213kffFG..",
            "....Gk1y1kFFG...",
            ".....Gk3kGGG....",
            "......kkk.......",
            "................",
            "................",
            "................",
            "................",
        ],
    ]

    for row_idx, stages in enumerate([wheat_stages, carrot_stages, strawberry_stages]):
        for col_idx, grid in enumerate(stages):
            paste_tile(sheet, render_grid(grid, 16, 16), col_idx * 16, row_idx * 16)

    return sheet


# ==============================================================================
# 3. FARMER SHEET (64x64 px = 4 cols walk x 4 rows direções de 16x16)
# ==============================================================================
def build_farmer_sheet() -> Image.Image:
    sheet = Image.new("RGBA", (64, 64), TRANSPARENT)

    extra_pal = {
        "S": hex_rgba("#5e3f2d"),  # cabelo/olho escuro
        "Z": hex_rgba("#8a5738"),  # botinhas marrom
    }

    down_idle = [
        ".....kkkkkk.....",
        "....kHHHHHHk....",
        "...kHHyyyyHHk...",
        "..k1111111111k..",
        ".kHHHHHHHHHHHHk.",
        ".k000000000000k.",
        "..kkCCCCCCCCkk..",
        "...kCSCCCCSCk...",
        "...kCpDDDDpCk...",
        "....kkCCCCkk....",
        "...k1ky55yk1k...",
        "..kCk454454kCk..",
        "...kk444444kk...",
        "....k46kk64k....",
        "....kZZkkZZk....",
        ".....kkkkkk.....",
    ]
    down_walk1 = [
        "................",
        ".....kkkkkk.....",
        "....kHHHHHHk....",
        "...kHHyyyyHHk...",
        "..k1111111111k..",
        ".kHHHHHHHHHHHHk.",
        ".k000000000000k.",
        "..kkCCCCCCCCkk..",
        "...kCSCCCCSCk...",
        "...kCpDDDDpCk...",
        "....kkCCCCkk....",
        "..kCky55yk1k....",
        "...kk454454kCk..",
        "....k46kk64kk...",
        "....kZZk.kZZk...",
        ".....kk...kk....",
    ]
    down_walk2 = [
        "................",
        ".....kkkkkk.....",
        "....kHHHHHHk....",
        "...kHHyyyyHHk...",
        "..k1111111111k..",
        ".kHHHHHHHHHHHHk.",
        ".k000000000000k.",
        "..kkCCCCCCCCkk..",
        "...kCSCCCCSCk...",
        "...kCpDDDDpCk...",
        "....kkCCCCkk....",
        "....k1ky55ykCk..",
        "..kCk454454kk...",
        "...kk46kk64k....",
        "....kZZk.kZZk...",
        ".....kk...kk....",
    ]

    up_idle = [
        ".....kkkkkk.....",
        "....kHHHHHHk....",
        "...kHHyyyyHHk...",
        "..k1111111111k..",
        ".kHHHHHHHHHHHHk.",
        ".k000000000000k.",
        "..kkSSSSSSSSkk..",
        "...kSSSSSSSSk...",
        "...kSSSSSSSSk...",
        "....kkSSSSkk....",
        "...k1k4444k1k...",
        "..kCk445544kCk..",
        "...kk444444kk...",
        "....k46kk64k....",
        "....kZZkkZZk....",
        ".....kkkkkk.....",
    ]
    up_walk1 = [
        "................",
        ".....kkkkkk.....",
        "....kHHHHHHk....",
        "...kHHyyyyHHk...",
        "..k1111111111k..",
        ".kHHHHHHHHHHHHk.",
        ".k000000000000k.",
        "..kkSSSSSSSSkk..",
        "...kSSSSSSSSk...",
        "...kSSSSSSSSk...",
        "....kkSSSSkk....",
        "..kCk4444k1k....",
        "...kk445544kCk..",
        "....k46kk64kk...",
        "....kZZk.kZZk...",
        ".....kk...kk....",
    ]
    up_walk2 = [
        "................",
        ".....kkkkkk.....",
        "....kHHHHHHk....",
        "...kHHyyyyHHk...",
        "..k1111111111k..",
        ".kHHHHHHHHHHHHk.",
        ".k000000000000k.",
        "..kkSSSSSSSSkk..",
        "...kSSSSSSSSk...",
        "...kSSSSSSSSk...",
        "....kkSSSSkk....",
        "....k1k4444kCk..",
        "..kCk445544kk...",
        "...kk46kk64k....",
        "....kZZk.kZZk...",
        ".....kk...kk....",
    ]

    left_idle = [
        ".....kkkkkk.....",
        "....kHHHHHHk....",
        "...kHHyyyyHHk...",
        "..k1111111111k..",
        ".kHHHHHHHHHHHHk.",
        ".k000000000000k.",
        "...kkCCCCCCSSk..",
        "...kCSCCCCSSSk..",
        "...kCpCDDDSSk...",
        "....kkCCCCkk....",
        "....k1k45ykk....",
        "....kCk4544k....",
        ".....kk4444k....",
        ".....k46k64k....",
        ".....kZZkZZk....",
        "......kkkkk.....",
    ]
    left_walk1 = [
        "................",
        ".....kkkkkk.....",
        "....kHHHHHHk....",
        "...kHHyyyyHHk...",
        "..k1111111111k..",
        ".kHHHHHHHHHHHHk.",
        ".k000000000000k.",
        "...kkCCCCCCSSk..",
        "...kCSCCCCSSSk..",
        "...kCpCDDDSSk...",
        "....kkCCCCkk....",
        "....k1k45ykk....",
        "...kCk4544kk....",
        "....kk44444k....",
        "...kZZkk.kZZk...",
        "....kk....kk....",
    ]
    left_walk2 = [
        "................",
        ".....kkkkkk.....",
        "....kHHHHHHk....",
        "...kHHyyyyHHk...",
        "..k1111111111k..",
        ".kHHHHHHHHHHHHk.",
        ".k000000000000k.",
        "...kkCCCCCCSSk..",
        "...kCSCCCCSSSk..",
        "...kCpCDDDSSk...",
        "....kkCCCCkk....",
        "....k1k45ykk....",
        ".....k454kCk....",
        ".....k4444kk....",
        "....kZZk.kZZk...",
        ".....kk...kk....",
    ]

    def mirror_rows(rows: list[str]) -> list[str]:
        return [r[::-1] for r in rows]

    rows_by_dir = [
        [down_idle, down_walk1, down_idle, down_walk2],
        [up_idle, up_walk1, up_idle, up_walk2],
        [left_idle, left_walk1, left_idle, left_walk2],
        [
            mirror_rows(left_idle),
            mirror_rows(left_walk1),
            mirror_rows(left_idle),
            mirror_rows(left_walk2),
        ],
    ]

    for row_idx, frames in enumerate(rows_by_dir):
        for col_idx, grid in enumerate(frames):
            tile = render_grid(grid, 16, 16, extra_pal=extra_pal)
            paste_tile(sheet, tile, col_idx * 16, row_idx * 16)

    return sheet


# ==============================================================================
# 4. PROPS & BUILDINGS (96x48 px)
# ==============================================================================
def build_props_buildings() -> Image.Image:
    sheet = Image.new("RGBA", (96, 48), TRANSPARENT)

    # 1. Casinha da fazenda (32x32) com telhado texturizado, janela redonda e floreiras
    house = [
        "......................RRRR......",
        "......................RiiR......",
        "...............RRRRRRRRiiR......",
        "..............RxxxxxxxxiiR......",
        ".............RxxrrrrrrrrrR......",
        "............RxrrxrrrrrrrrrR.....",
        "...........RxrrrrrrrrxrrrrrR....",
        "..........RxrrrrRaaRrrrrrrrrR...",
        ".........RxrrrrrRccRrrxrrrrrrR..",
        "........RxrxrrrrRRRRrrrrrrrrrrR.",
        ".......RxrrrrrrrrrrrrrrrxrrrrrrR",
        "......RxrrrrxrrrrrrrrrrrrrrrrrrR",
        ".....RxrrrrrrrrrrrrxrrrrrrrrrrrR",
        "....RXXXXXXXXXXXXXXXXXXXXXXXXXXR",
        "....RRRRRRRRRRRRRRRRRRRRRRRRRRRR",
        ".....BMMMMMMMMMMMMMMMMMMMMMMMMB.",
        ".....BnnnnnnnnnnnnnnnnnnnnnnnnB.",
        ".....BnnnnnnnnnBBBBBBnnnnnnnnnB.",
        ".....BnnBBBBnnBoOOOOoBnnBBBBnnB.",
        ".....BnBaccBnBBoOeeOoBBnBaccBnB.",
        ".....BnBaaabnBBoOeeOoBBnBaaabnB.",
        ".....BnBbbabnBBoOYYOoBBnBbbabnB.",
        ".....BnnBBBBnnBoOOOOoBnnBBBBnnB.",
        ".....BnnGhhGnnBoOeeOoBnnGhhGnnB.",
        ".....BnGppGyyGBoOeeOoBGyyGppGnB.",
        ".....BnMMMMMMnBooooooBnMMMMMMnB.",
        ".....BnnnnnnnnBeeeeeeBnnnnnnnnB.",
        ".....BMMMMMMMMBJJJJJJBMMMMMMMMB.",
        ".....BJJJJJJJJBIIIIIIBJJJJJJJJB.",
        "......BBBBBBBBIIIIIIIIBBBBBBBB..",
        "..............JJJJJJJJ..........",
        "................................",
    ]
    paste_tile(sheet, render_grid(house, 32, 32), 0, 0)

    # 2. Árvore frondosa (32x32) com copa volumosa e sombra nas raízes
    tree = [
        "...........GGGGGGGGGG...........",
        ".........GGLLLLllLLLLGG.........",
        ".......GGllhhllLLllhhllGG.......",
        "......GLhhhhhllllllhhhhhLG......",
        ".....GlhhgggghhhhhhgggghhlG.....",
        "....GlhgggLLgghhhhggLLggghlG....",
        "...GllggggggggghhhggggggggllG...",
        "...GlhgggggggggggggggggggglGG...",
        "..GGhhgggghhhgggggghhhgggghhGG..",
        "..GlhggggghhhgggggghhhggggghlG..",
        "..GlhgggggggggmmmmggggggggghlG..",
        "..GffgggggmmggggggggmmgggggffG..",
        "...GffgggmmmmggggggmmmmgggffG...",
        "...GffggggmmggggggggmmggggffG...",
        "....GfffgggggFFFFFFgggggfffG....",
        ".....GFFFFggggggggggggFFFFG.....",
        "......GGFFFFffffffffFFFFGG......",
        "........GGGFFGGGGGGFFGGG........",
        "..........GGGG.BB.GGGG..........",
        "............BBoOOooBB...........",
        "............BoEOOoeoB...........",
        "............BoOOoeeoB...........",
        "............BooOoeeoB...........",
        "............BooooeeoB...........",
        "............BoooeeeoB...........",
        "...........BBooeoeeeoBB.........",
        "..........BoOoeooooeeoOB........",
        ".........BoooeeeeeeeeoooB.......",
        "..........BBBeeeeeeeeBBB........",
        ".............BBBBBBBB...........",
        "................................",
        "................................",
    ]
    paste_tile(sheet, render_grid(tree, 32, 32), 32, 0)

    # 3. Pedra com musgo (16x16) at (64,0)
    rock = [
        "................",
        "................",
        "................",
        ".....kkkkkk.....",
        "...kkIIIIIIkk...",
        "..kIIiiiiiiIIk..",
        ".kIiiIIIIiiiijk.",
        ".kIiiiggiiiiijk.",
        "kIiigmmjiiijjjjk",
        "kijjjmgiiijjjjjk",
        "kjjjjjjjjjjjjjjk",
        ".kJJJJjjjjJJJJk.",
        "..kkkkJJJJkkkk..",
        "......kkkk......",
        "................",
        "................",
    ]
    paste_tile(sheet, render_grid(rock, 16, 16), 64, 0)

    # 4. Arbusto florido (16x16) at (80,0)
    bush = [
        "................",
        "................",
        ".....GGGGGG.....",
        "...GGLLhhLLGG...",
        "..GLhgggggghLG..",
        ".GlggpPgggPpgGG.",
        ".GhgPppggppPGhG.",
        "GlgggppgggppgggG",
        "GggggggggggggggG",
        "GffggmmggmmggffG",
        "GfffgmmggmmgfffG",
        ".GFFFFffffFFFFG.",
        "..GGGGFFFFGGGG..",
        "......GGGG......",
        "................",
        "................",
    ]
    paste_tile(sheet, render_grid(bush, 16, 16), 80, 0)

    # 5. Poço d'água (16x16) at (64,16)
    well = [
        "......RRRR......",
        "....RRxxxxRR....",
        "..RRrrrrrrrrRR..",
        ".RXXXXXXXXXXXXR.",
        "..BBBB....BBBB..",
        "..BOoB....BoOB..",
        "..BOoBBBBBBooB..",
        "..BJJIIIIIIJJB..",
        ".BkIIaaaaaaIIkB.",
        ".kIiaabccbaaaIk.",
        ".kIiaaaaaaaaiIk.",
        ".kjjIIIIIIIIjjk.",
        ".kJJiiJJJJiiJJk.",
        "..kkJJiiiiJJkk..",
        "....kkkkkkkk....",
        "................",
    ]
    paste_tile(sheet, render_grid(well, 16, 16), 64, 16)

    # 6. Placa da Loja (16x16) at (80,16)
    shop_sign = [
        "................",
        "..BBBBBBBBBBBB..",
        ".BrrrrrrrrrrrrB.",
        ".BwwrwwrrwwrwwB.",
        ".BOOOOOOOOOOOOB.",
        ".BOeeekkkkeeeOB.",
        ".BOeekHyyYkeeOB.",
        ".BOeekyY0YkeeOB.",
        ".BOeeekkkkeeeOB.",
        "..BBBBBBBBBBBB..",
        ".....BOooOB.....",
        ".....BOeeOB.....",
        ".....BOeeOB.....",
        "....BBOeeOBB....",
        "....BBBBBBBB....",
        "................",
    ]
    paste_tile(sheet, render_grid(shop_sign, 16, 16), 80, 16)

    # 7. Galinha 2 frames (16x16 each) at (0,32) and (16,32)
    chicken_0 = [
        "................",
        "................",
        "......kk........",
        ".....k11k.......",
        "....k1211k......",
        "....kkwwkk......",
        "...kwwkwwk......",
        "..k77wwwwkk.....",
        "...kkwwwWWWkk...",
        "....kwwwWWWWwk..",
        "....kwwWWwwWWk..",
        ".....kWWWWWWk...",
        "......kkkkkk....",
        "......k7..k7....",
        ".....k77.k77....",
        "................",
    ]
    chicken_1 = [
        "................",
        "................",
        "................",
        "......kk........",
        ".....k11k.......",
        "....k1211k......",
        "....kkwwkk......",
        "...kwwkwwk......",
        "..k77wwwwkk.....",
        "...kkwwWWWWWk...",
        "....kwwWWwwWWk..",
        ".....kWWWWWWk...",
        "......kkkkkk....",
        ".....k7....k7...",
        "....k77...k77...",
        "................",
    ]
    paste_tile(sheet, render_grid(chicken_0, 16, 16), 0, 32)
    paste_tile(sheet, render_grid(chicken_1, 16, 16), 16, 32)

    # 8. Vaca 2 frames (16x16 each) at (32,32) and (48,32)
    cow_0 = [
        "................",
        "................",
        "..kk......kk....",
        ".kHHk....kHHk...",
        "..kwwkkkkwwk....",
        ".kwwkwwwwkwwk...",
        ".kKwkwwwwkwKk...",
        ".kwwppppppwwkk..",
        "..kkpPppPpkkWWk.",
        "...kwwyyKKwwWWk.",
        "...kwwKKKKwwwwk.",
        "...kwwwwKKwwwKk.",
        "....kkkkkkkkkk..",
        "....kWWk..kWWk..",
        "....kKKk..kKKk..",
        "................",
    ]
    cow_1 = [
        "................",
        "................",
        "..kk......kk....",
        ".kHHk....kHHk...",
        "..kwwkkkkwwk....",
        ".kwwkwwwwkwwk...",
        ".kKwkwwwwkwKk...",
        ".kwwppppppwwkk..",
        "..kkpPppPpkkWWk.",
        "...kwwyyKKwwWWkk",
        "...kwwKKKKwwwKk.",
        "...kwwwwKKwwwwk.",
        "....kkkkkkkkkk..",
        "...kWWk....kWWk.",
        "...kKKk....kKKk.",
        "................",
    ]
    paste_tile(sheet, render_grid(cow_0, 16, 16), 32, 32)
    paste_tile(sheet, render_grid(cow_1, 16, 16), 48, 32)

    return sheet


# ==============================================================================
# 5. UI ICONS (128x16 px = 8 ícones de 16x16)
# Col 0: Enxada, Col 1: Regador, Col 2: Sem. Trigo, Col 3: Sem. Cenoura,
# Col 4: Sem. Morango, Col 5: Moeda dourada, Col 6: Ovo, Col 7: Garrafa de Leite
# ==============================================================================
def build_ui_icons() -> Image.Image:
    sheet = Image.new("RGBA", (128, 16), TRANSPARENT)

    # Col 0: Enxada
    hoe = [
        "................",
        ".........kkkk...",
        "........kIIIIk..",
        ".......kIiiiJJk.",
        ".......kIiBkkJk.",
        "........kBOek...",
        ".......kBOek....",
        "......kBOek.....",
        ".....kBOek......",
        "....kBOek.......",
        "...kBOek........",
        "..kBOek.........",
        ".kBOek..........",
        ".kOek...........",
        "..kk............",
        "................",
    ]
    paste_tile(sheet, render_grid(hoe, 16, 16), 0, 0)

    # Col 1: Regador
    watering_can = [
        "................",
        "................",
        ".......NNNNN....",
        "......NbbbbbN...",
        "..NN..NaaaaNN...",
        ".NyyNNaaaaNaaN..",
        ".NbbNaaaaaNaaN..",
        "..NNaabccbaaaN..",
        "....NaaaaaaaaN..",
        "....NaaAAAAaaN..",
        "....NAAAAAAAAaN.",
        "....NAAAAAAAAaN.",
        ".....NAAAAAAAN..",
        "......NNNNNNN...",
        "................",
        "................",
    ]
    paste_tile(sheet, render_grid(watering_can, 16, 16), 16, 0)

    # Col 2: Pacote de Semente Trigo
    seed_wheat = [
        "................",
        "...kkkkkkkkkk...",
        "..kEEEEEEEEEEk..",
        "..kOooooooooOk..",
        "...kkkkkkkkkk...",
        "..kwwwwwwwwwwk..",
        "..kwWWkkkkWWwk..",
        "..kwwkHyy0kwwk..",
        "..kwwkyYY0kwwk..",
        "..kwwk0YY0kwwk..",
        "..kwwkkG0kkwwk..",
        "..kwWWkGGkWWwk..",
        "..kWWWWWWWWWWk..",
        "...kkkkkkkkkk...",
        "................",
        "................",
    ]
    paste_tile(sheet, render_grid(seed_wheat, 16, 16), 32, 0)

    # Col 3: Pacote de Semente Cenoura
    seed_carrot = [
        "................",
        "...kkkkkkkkkk...",
        "..kEEEEEEEEEEk..",
        "..kOooooooooOk..",
        "...kkkkkkkkkk...",
        "..kwwwwwwwwwwk..",
        "..kwWWGGGGWWwk..",
        "..kwwGLhhGwwwk..",
        "..kwwk787kwwwk..",
        "..kwwk779kwwwk..",
        "..kwwwk79kwwwk..",
        "..kwWWwkkwWWwk..",
        "..kWWWWWWWWWWk..",
        "...kkkkkkkkkk...",
        "................",
        "................",
    ]
    paste_tile(sheet, render_grid(seed_carrot, 16, 16), 48, 0)

    # Col 4: Pacote de Semente Morango
    seed_strawberry = [
        "................",
        "...kkkkkkkkkk...",
        "..kEEEEEEEEEEk..",
        "..kOooooooooOk..",
        "...kkkkkkkkkk...",
        "..kwwwwwwwwwwk..",
        "..kwWWGGGGWWwk..",
        "..kwwk1111kwwk..",
        "..kwwk21y1kwwk..",
        "..kwwk1113kwwk..",
        "..kwwwk13kwwwk..",
        "..kwWWwkkwWWwk..",
        "..kWWWWWWWWWWk..",
        "...kkkkkkkkkk...",
        "................",
        "................",
    ]
    paste_tile(sheet, render_grid(seed_strawberry, 16, 16), 64, 0)

    # Col 5: Moeda dourada
    coin = [
        "................",
        ".....kkkkkk.....",
        "...kkHHHHHHkk...",
        "..kHHyyyyyy0Hk..",
        ".kHywYYYYYY0yHk.",
        ".kHyYyH000yYyHk.",
        ".kHyYyH0y0yYyHk.",
        ".kHyYyH0y0yYyHk.",
        ".kHyYyH0y0yYyHk.",
        ".kHyYyH000yYyHk.",
        ".kHyYyy000yYyHk.",
        ".kH00YYYYYY00Hk.",
        "..k0000000000k..",
        "...kk000000kk...",
        ".....kkkkkk.....",
        "................",
    ]
    paste_tile(sheet, render_grid(coin, 16, 16), 80, 0)

    # Col 6: Ovo (usa asset CC0 real egg_whole_white.png se disponível, senão fallback)
    oga_egg = OGA_FOOD_DIR / "egg_whole_white.png"
    if oga_egg.is_file():
        egg_tile = Image.open(oga_egg).convert("RGBA")
        if egg_tile.size != (16, 16):
            egg_tile = egg_tile.resize((16, 16), Image.Resampling.NEAREST)
    else:
        egg_fallback = [
            "................",
            "......kkkk......",
            ".....kwwwwk.....",
            "....kwwwwWWk....",
            "...kwwcwwwWWk...",
            "...kwwwwwwWWk...",
            "..kwwwwwwwwWWk..",
            "..kwwwwwwwwWWk..",
            "..kwwwwwwwwWWk..",
            "..kwwWWWWWWWWk..",
            "...kWWWWWWWWk...",
            "...kWWWWWWWWk...",
            "....kWWWWWWk....",
            ".....kkkkkk.....",
            "................",
            "................",
        ]
        egg_tile = render_grid(egg_fallback, 16, 16)
    paste_tile(sheet, egg_tile, 96, 0)

    # Col 7: Garrafa de Leite cozy 16x16
    milk_bottle = [
        "................",
        ".....kkkkkk.....",
        "....krrrrrrk....",
        "....k111111k....",
        ".....kbbbbk.....",
        ".....kbcbbk.....",
        "....kwwwwwwk....",
        "...kwwcwwwwWk...",
        "...kwwwwwwwWk...",
        "...kwbbbbbbWk...",
        "...kwaaaaaWWk...",
        "...kwwwwwwwWk...",
        "...kwwWWWWWWk...",
        "...kWWWWWWWWk...",
        "....kkkkkkkk....",
        "................",
    ]
    paste_tile(sheet, render_grid(milk_bottle, 16, 16), 112, 0)

    return sheet


# ==============================================================================
# 6. CROPS EXTRA SHEET v1.3.0 (80x48 px = 5 estágios x 3 culturas de 16x16)
# Row 0: Milho (corn), Row 1: Tomate (tomato), Row 2: Abóbora (pumpkin)
# ==============================================================================
def _load_oga_food_16(filename: str) -> Image.Image | None:
    path = OGA_FOOD_DIR / filename
    if not path.is_file():
        return None
    img = Image.open(path).convert("RGBA")
    if img.size != (16, 16):
        img = img.resize((16, 16), Image.Resampling.NEAREST)
    return img


def build_crops_extra_sheet() -> Image.Image:
    sheet = Image.new("RGBA", (80, 48), TRANSPARENT)

    # Row 0 (y=0): Milho (corn)
    corn_stages = [
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            ".....kk.........",
            "....kYyk...kk...",
            ".....kk...kYyk..",
            "..kk.......kk...",
            ".kYyk..kk.......",
            "..kk..kYyk......",
            ".......kk.......",
            "................",
        ],
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "......GG........",
            ".....GLlG.......",
            ".....GllG..GG...",
            "......GlG.GLlG..",
            "......GfGGfG....",
            ".......GfGG.....",
            ".......GFFG.....",
            "........GG......",
            "................",
        ],
        [
            "................",
            "................",
            "................",
            "......GG........",
            ".....GLlG.......",
            "..GG.GlfG..GG...",
            ".GLlGGffG.GLlG..",
            "..GlGGffGGfGG...",
            "...GffFFffG.....",
            "....GffffG......",
            "....GffFFG......",
            ".....GFFG.......",
            ".....GFFG.......",
            "......GG........",
            "................",
            "................",
        ],
        [
            "......kk........",
            ".....kHyk.......",
            "....GGyyGG......",
            "...GLlGGllG.....",
            "..GGffGGffGG....",
            ".GLhGffffGhLG...",
            "..GffGffGffG....",
            "...GGffffGG.....",
            "....GffffG......",
            "...GGffFFGG.....",
            "...GFFffFFG.....",
            "....GFFFFG......",
            ".....GFFG.......",
            ".....GGGG.......",
            "................",
            "................",
        ],
        [
            "......kk........",
            ".....kHyk.......",
            "....kGyyGk......",
            "...GLkHykLG.....",
            "..GGfkYYkfGG....",
            ".GLhGkYYkGhLG...",
            "..Gffk0YkffG....",
            "...GGkYYkGG.....",
            "...kHkffkHk.....",
            "..kHykffkyHk....",
            "..kY0GffG0Yk....",
            "...kkGFFGkk.....",
            ".....GFFG.......",
            ".....GGGG.......",
            "................",
            "................",
        ],
    ]

    # Row 1 (y=16): Tomate (tomato)
    tomato_stages = [
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            ".....kk.........",
            "....k78k...kk...",
            ".....kk...k78k..",
            "..kk.......kk...",
            ".k78k..kk.......",
            "..kk..k78k......",
            ".......kk.......",
            "................",
        ],
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            ".....GG.GG......",
            "....GLGGhLG.....",
            "....GfGGfhG.....",
            ".....GffGG......",
            "......GfG.......",
            "......GFG.......",
            ".......G........",
            "................",
        ],
        [
            "................",
            "................",
            "................",
            ".....GGGGGG.....",
            "...GGLhhhhLLGG..",
            "..GLhGffffGhLLG.",
            "..GffGffffGffG..",
            "...GffffffffG...",
            "....GffFFffG....",
            ".....GFFFFG.....",
            "......GFFG......",
            "......GGGG......",
            "................",
            "................",
            "................",
            "................",
        ],
        [
            "................",
            ".....GGGGGG.....",
            "...GGLhhhhLLGG..",
            "..GLhGyYffGhLLG.",
            "..GffYyyGfGfyyG.",
            ".GLhfGffGGffYyw.",
            "..GfffffGGffffG.",
            "..GffyyfffffGfG.",
            "...GyYfffFFffG..",
            "....GffFFFFGG...",
            ".....GGGGGGG....",
            "................",
            "................",
            "................",
            "................",
            "................",
        ],
        [
            ".....GGGGGG.....",
            "...GGLhhhhLLGG..",
            "..GLhGffffGhLLG.",
            "..Gfk11kffk11kG.",
            ".GLk2113kfk211kG",
            "..Gk1133kfk113k.",
            "..Gfk33kfGk33kG.",
            "..Gfffk11kffGfG.",
            "...Gfk2113kffG..",
            "....Gk113kFFG...",
            ".....GkkkGGG....",
            "......GGG.......",
            "................",
            "................",
            "................",
            "................",
        ],
    ]

    # Row 2 (y=32): Abóbora (pumpkin)
    pumpkin_stages = [
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            ".....kk.........",
            "....k87k...kk...",
            ".....kk...k87k..",
            "..kk.......kk...",
            ".k87k..kk.......",
            "..kk..k87k......",
            ".......kk.......",
            "................",
        ],
        [
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            ".....GGGG.......",
            "....GLhhLG......",
            "....GffffG......",
            ".....GffG.......",
            "......GG........",
            "................",
            "................",
            "................",
            "................",
        ],
        [
            "................",
            "................",
            "................",
            "....GGGGGGGG....",
            "..GGLhhhhhhLLG..",
            ".GLhGffffffGhLG.",
            ".GffGffffffGffG.",
            "..GfffFFFFfffG..",
            "...GGGGGGGGGG...",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ],
        [
            "................",
            "....GGGGGGGG....",
            "..GGLhhhhhhLLG..",
            ".GLhGyYffYyGhLG.",
            ".GffYyyGGyyYGfG.",
            "..GffGffffGffG..",
            "...GfffGGfffG...",
            "....GGGGGGGG....",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
            "................",
        ],
        [
            ".......GG.......",
            "......GLLG......",
            "....GGfGGfGG....",
            "...kKKKKKKKKk...",
            "..k8877kk7788k..",
            ".k8777k87k7779k.",
            ".k8777k77k7799k.",
            ".k7777k77k7999k.",
            ".k7799k79k9999k.",
            "..k999k99k999k..",
            "...kkkKKKKkkk...",
            ".....kkkkkk.....",
            "................",
            "................",
            "................",
            "................",
        ],
    ]

    for row_idx, stages in enumerate([corn_stages, tomato_stages, pumpkin_stages]):
        for col_idx, grid in enumerate(stages):
            paste_tile(sheet, render_grid(grid, 16, 16), col_idx * 16, row_idx * 16)

    return sheet


# ==============================================================================
# 7. V1.3.0 WORLD PROPS & SHEEP (112x32 px = 7 cols x 2 rows de 16x16)
# Row 0: Sheep0, Sheep1, CheesePressIdle, CheesePressReady, OvenIdle, OvenReady, BeeHive
# Row 1: Sprinkler, OrderBoard, Fertilizer, GoldStar, Bobber, RainDrop, ReadyExclamation
# ==============================================================================
def build_v13_props_sheet() -> Image.Image:
    sheet = Image.new("RGBA", (112, 32), TRANSPARENT)

    sheep_0 = [
        "................",
        "................",
        "....kkkkkk......",
        "...kwwwwwwkk....",
        "..kwwWWWWwwwk...",
        ".kJJkwwWWwwwwk..",
        ".kJJKkwwwwWWWk..",
        ".kJJkkwwwwWWWk..",
        "..kkwwwwwwWWWk..",
        "...kwwwwWWWWk...",
        "....kkkkkkkk....",
        "....kJJk..kJJk..",
        "....kKKk..kKKk..",
        "................",
        "................",
        "................",
    ]
    sheep_1 = [
        "................",
        "................",
        "................",
        "....kkkkkk......",
        "...kwwwwwwkk....",
        "..kwwWWWWwwwk...",
        ".kJJkwwWWwwwwk..",
        ".kJJKkwwwwWWWk..",
        ".kJJkkwwwwWWWk..",
        "..kkwwwwwwWWWk..",
        "...kwwwwWWWWk...",
        "....kkkkkkkk....",
        "...kJJk...kJJk..",
        "...kKKk...kKKk..",
        "................",
        "................",
    ]

    cheese_press_idle = [
        "................",
        "......BBBB......",
        ".....BOEEOB.....",
        "......BJJB......",
        "...BBBBJJBBBB...",
        "..BOEEEEEEEEOB..",
        "..BJJIIIIIIJJB..",
        "..BOooooooooOB..",
        "..BOoOOOOooOOB..",
        "..BOoeeeeooeeB..",
        "..BJJIIIIIIJJB..",
        "..BOooooooooOB..",
        "..BeeeeeeeeeeB..",
        "...BBBBBBBBBB...",
        "................",
        "................",
    ]
    cheese_press_ready = [
        ".....kkkkkk.....",
        "....kyyyyyyk....",
        "....kyYYYY0k....",
        ".....kkkkkk.....",
        "...BBBBJJBBBB...",
        "..BOEEEEEEEEOB..",
        "..BJJIIIIIIJJB..",
        "..BOooooooooOB..",
        "..BOoOOOOooOOB..",
        "..BOoeeeeooeeB..",
        "..BJJIIIIIIJJB..",
        "..BOooooooooOB..",
        "..BeeeeeeeeeeB..",
        "...BBBBBBBBBB...",
        "................",
        "................",
    ]

    oven_idle = [
        "................",
        ".....kkkkkk.....",
        "...kkIIIIIIkk...",
        "..kIIiiiiiiIIk..",
        ".kIiiIIIIiiiijk.",
        ".kIiiiiiiiiiijk.",
        "kIiiiBBBBBBiiijk",
        "kiiiBJJJJJJBiiik",
        "kiiiBJ7777JBiiik",
        "kjjjBJ7887JBjjjk",
        "kjjjBJJJJJJBjjjk",
        ".kJJJJiiiiJJJJk.",
        ".kJJJJJJJJJJJJk.",
        "..kkkkkkkkkkkk..",
        "................",
        "................",
    ]
    oven_ready = [
        ".....kk..kk.....",
        "....kwwk.kwwk...",
        "...kkIIIIIIkk...",
        "..kIIiiiiiiIIk..",
        ".kIiiIIIIiiiijk.",
        ".kIiiiiiiiiiijk.",
        "kIiiiBBBBBBiiijk",
        "kiiiBJJJJJJBiiik",
        "kiiiBJHyyHJBiiik",
        "kjjjBJyOOyJBjjjk",
        "kjjjBJJJJJJBjjjk",
        ".kJJJJiiiiJJJJk.",
        ".kJJJJJJJJJJJJk.",
        "..kkkkkkkkkkkk..",
        "................",
        "................",
    ]

    bee_hive = [
        "................",
        "......kkkk......",
        "....kkyyyyk.....",
        "...kHHyyyyHHk...",
        "..k0000000000k..",
        "..kHHyyyyyyHHk..",
        ".k000000000000k.",
        ".kHHyykkkkuyHHk.",
        ".k000kJJJJk000k.",
        ".kHHykJJJJkyHHk.",
        "..k000kkkk000k..",
        "..kBBBBBBBBBBk..",
        "...BOooBBOooB...",
        "...BeeeBBeeeB...",
        "................",
        "................",
    ]

    sprinkler = [
        "................",
        "......kkkk......",
        "....kkIIIIkk....",
        "...kIibbbbiIk...",
        "....kkIaaIkk....",
        "......kJJk......",
        "......kIIk......",
        "......kjjk......",
        ".....kIjjIk.....",
        "....kjjJJjjk....",
        ".....kJJJJk.....",
        "......kkkk......",
        "................",
        "................",
        "................",
        "................",
    ]

    order_board = [
        "................",
        "..BBBBBBBBBBBB..",
        ".BOEEEEEEEEEEOB.",
        ".BOoowwwwwwoooB.",
        ".BOowww11wwwooB.",
        ".BOowwWWWWwwooB.",
        ".BOoooooooooooB.",
        ".BOowwwwwoowwwB.",
        ".BOowWWwwoowWWB.",
        ".BBBBBBBBBBBBBB.",
        "....BOo..OoB....",
        "....BOe..eeB....",
        "....BOe..eeB....",
        "....BBB..BBB....",
        "................",
        "................",
    ]

    fertilizer_ground = [
        "................",
        "................",
        "...ll......yy...",
        "..lLLl....yYYy..",
        "...ll......yy...",
        ".......ll.......",
        "......lLLl......",
        ".......ll.......",
        "..yy........ll..",
        ".yYYy......lLLl.",
        "..yy........ll..",
        "................",
        "................",
        "................",
        "................",
        "................",
    ]

    gold_star = [
        ".......kk.......",
        "......kyyk......",
        "......kyyk......",
        ".kkkkkyYYykkkkk.",
        "kyyyyYYYYYYyyyyk",
        ".kYYYYYYYYYYYYk.",
        "..kYYYY00YYYYk..",
        "...kYYY00YYYk...",
        "..kYY00kk00YYk..",
        "..kY0k....k0Yk..",
        "...kk......kk...",
        "................",
        "................",
        "................",
        "................",
        "................",
    ]

    bobber = [
        "................",
        "................",
        "......kkkk......",
        ".....k1111k.....",
        "....k122111k....",
        "....k111111k....",
        "....kwwwwwwk....",
        "....kwWWWWwk....",
        ".....kWWWWk.....",
        "......kkkk......",
        ".....c.cc.c.....",
        "....a..aa..a....",
        "................",
        "................",
        "................",
        "................",
    ]

    rain_drop = [
        ".......cc.......",
        "......cbb.......",
        "......bba.......",
        ".....baaa.......",
        ".....aaAA.......",
        "....aAAA........",
        "....AAA.........",
        "...AA...........",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
    ]

    ready_badge = [
        ".....kkkkkk.....",
        "....kyyyyyyk....",
        "...kyyykkyyyk...",
        "...kyykYYkyyk...",
        "...kyykYYkyyk...",
        "...kyykYYkyyk...",
        "...kyyykkyyyk...",
        "...kyyykkyyyk...",
        "....kykYYkyk....",
        "....kyyY0yyk....",
        ".....kkkkkk.....",
        ".......kk.......",
        "................",
        "................",
        "................",
        "................",
    ]

    row0 = [sheep_0, sheep_1, cheese_press_idle, cheese_press_ready, oven_idle, oven_ready, bee_hive]
    row1 = [sprinkler, order_board, fertilizer_ground, gold_star, bobber, rain_drop, ready_badge]
    for col_idx, grid in enumerate(row0):
        paste_tile(sheet, render_grid(grid, 16, 16), col_idx * 16, 0)
    for col_idx, grid in enumerate(row1):
        paste_tile(sheet, render_grid(grid, 16, 16), col_idx * 16, 16)

    return sheet


# ==============================================================================
# 8. V1.3.0 UI ICONS (256x16 px = 16 ícones de 16x16)
# ==============================================================================
def build_v13_icons() -> Image.Image:
    sheet = Image.new("RGBA", (256, 16), TRANSPARENT)

    fishing_rod = [
        "................",
        "..........kkkk..",
        ".........kOEEOk.",
        "........kOek.kIk",
        ".......kOek...kc",
        "......kOek....kc",
        ".....kOek.....kc",
        "....kOek......kc",
        "...kOek.......k1",
        "..kOek........k1",
        ".kOek..........k",
        ".kOek...........",
        ".kkk............",
        "................",
        "................",
        "................",
    ]
    seed_corn = [
        "................",
        "...kkkkkkkkkk...",
        "..kEEEEEEEEEEk..",
        "..kOooooooooOk..",
        "...kkkkkkkkkk...",
        "..kwwwwwwwwwwk..",
        "..kwWWGGGGWWwk..",
        "..kwwkHyyHkwwk..",
        "..kwwkyYYykwwk..",
        "..kwwk0YY0kwwk..",
        "..kwwwkGGkwwwk..",
        "..kwWWwkkwWWwk..",
        "..kWWWWWWWWWWk..",
        "...kkkkkkkkkk...",
        "................",
        "................",
    ]
    seed_tomato = [
        "................",
        "...kkkkkkkkkk...",
        "..kEEEEEEEEEEk..",
        "..kOooooooooOk..",
        "...kkkkkkkkkk...",
        "..kwwwwwwwwwwk..",
        "..kwWWGGGGWWwk..",
        "..kwwk1111kwwk..",
        "..kwwk2111kwwk..",
        "..kwwk1113kwwk..",
        "..kwwwk33kwwwk..",
        "..kwWWwkkwWWwk..",
        "..kWWWWWWWWWWk..",
        "...kkkkkkkkkk...",
        "................",
        "................",
    ]
    seed_pumpkin = [
        "................",
        "...kkkkkkkkkk...",
        "..kEEEEEEEEEEk..",
        "..kOooooooooOk..",
        "...kkkkkkkkkk...",
        "..kwwwwwwwwwwk..",
        "..kwWWGGGGWWwk..",
        "..kwwk8779kwwk..",
        "..kwwk7779kwwk..",
        "..kwwk7999kwwk..",
        "..kwwwkkkkwwwk..",
        "..kwWWWWWWWWwk..",
        "..kWWWWWWWWWWk..",
        "...kkkkkkkkkk...",
        "................",
        "................",
    ]
    fertilizer_bag = [
        "................",
        ".....kkkkkk.....",
        "....kEEEEEEk....",
        ".....kBBBBk.....",
        "...kksssssskk...",
        "..kssGGLLGGssk..",
        "..ksGLhffhLGsk..",
        "..kssGffffGssk..",
        "..ksszzGGzzssk..",
        "..ksszzzzzzssk..",
        "..kssZZZZZZssk..",
        "...kkZZZZZZkk...",
        ".....kkkkkk.....",
        "................",
        "................",
        "................",
    ]
    sprinkler_icon = [
        "................",
        "......kkkk......",
        "....kkIIIIkk....",
        "...kIibbbbiIk...",
        "....kkIaaIkk....",
        "......kJJk......",
        ".....ckIIkc.....",
        "....a.kjjk.a....",
        ".....kIjjIk.....",
        "....kjjJJjjk....",
        ".....kJJJJk.....",
        "......kkkk......",
        "................",
        "................",
        "................",
        "................",
    ]
    wool_icon = [
        "................",
        ".....kkkkkk.....",
        "...kkwwwwwwkk...",
        "..kwwWWWWwwwwk..",
        ".kwwWWkkkkWWwwk.",
        ".kwwWkwWWwkWWwk.",
        ".kwwWkwWWwkWWwk.",
        ".kWWWWkkkkWWWWk.",
        "..kWWWWWWWWWWk..",
        "...kkWWWWWWkk...",
        ".....kkkkkk.....",
        "................",
        "................",
        "................",
        "................",
        "................",
    ]
    tilapia_icon = [
        "................",
        "................",
        ".....kkkkkk.....",
        "...kkaaaaAAkk...",
        "..kaabccbaaaAk..",
        ".kNabaaaKaaaAk.k",
        ".kNaaaaaaaaAAkAk",
        "..kAAaaaaaAAkkAk",
        "...kkAAAAAkk.kAk",
        ".....kkkkk....kk",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
    ]
    trout_icon = [
        "................",
        "................",
        ".....kkkkkk.....",
        "...kkggggmmkk...",
        "..kggLppggmmpk..",
        ".kGggpppKggmmk.k",
        ".kGggmmppmmmGkmk",
        "..kmmppppmmGkkGk",
        "...kkGGGGGGk.kGk",
        ".....kkkkkk...kk",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
    ]
    golden_carp_icon = [
        "................",
        "................",
        ".....kkkkkk.....",
        "...kkHyyyy0kk...",
        "..kHywYYYYY0yk..",
        ".k0yyYYYKYYY0k.k",
        ".k0YYYYYYYYY0k0k",
        "..k00YYYYY00kk0k",
        "...kk00000kk.k0k",
        ".....kkkkk....kk",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
    ]
    order_scroll = [
        "................",
        "...kkkkkkkkkk...",
        "..kEEEEEEEEEEk..",
        "..kEwwwwwwwwEk..",
        "...kkwwwwwwkk...",
        "...kww1111wwk...",
        "...kwwwwwwwwk...",
        "...kwwMMMMwwk...",
        "...kwwwwwwwwk...",
        "...kwwMMMMwwk...",
        "..kEwwwwwwwwEk..",
        "..kEEEEEEEEEEk..",
        "...kkkkkkkkkk...",
        "................",
        "................",
        "................",
    ]

    manual_icons = {
        0: render_grid(fishing_rod, 16, 16),
        1: render_grid(seed_corn, 16, 16),
        2: render_grid(seed_tomato, 16, 16),
        3: render_grid(seed_pumpkin, 16, 16),
        4: render_grid(fertilizer_bag, 16, 16),
        5: render_grid(sprinkler_icon, 16, 16),
        6: _load_oga_food_16("cheese.png") or render_grid(wool_icon, 16, 16),
        7: _load_oga_food_16("bread_loaf_brown.png") or render_grid(wool_icon, 16, 16),
        8: _load_oga_food_16("honey_pot.png") or render_grid(wool_icon, 16, 16),
        9: _load_oga_food_16("egg_whole_blue.png") or render_grid(wool_icon, 16, 16),
        10: render_grid(wool_icon, 16, 16),
        11: render_grid(tilapia_icon, 16, 16),
        12: _load_oga_food_16("shrimp.png") or render_grid(tilapia_icon, 16, 16),
        13: render_grid(trout_icon, 16, 16),
        14: render_grid(golden_carp_icon, 16, 16),
        15: render_grid(order_scroll, 16, 16),
    }

    for col_idx, icon_img in manual_icons.items():
        paste_tile(sheet, icon_img, col_idx * 16, 0)

    return sheet


def main() -> None:
    SPRITES_DIR.mkdir(parents=True, exist_ok=True)

    outputs: list[tuple[str, Image.Image, tuple[int, int]]] = [
        ("terrain_tileset.png", build_terrain_tileset(), (64, 32)),
        ("crops_sheet.png", build_crops_sheet(), (80, 48)),
        ("farmer_sheet.png", build_farmer_sheet(), (64, 64)),
        ("props_buildings.png", build_props_buildings(), (96, 48)),
        ("ui_icons.png", build_ui_icons(), (128, 16)),
        ("crops_extra_sheet.png", build_crops_extra_sheet(), (80, 48)),
        ("v13_props_sheet.png", build_v13_props_sheet(), (112, 32)),
        ("v13_icons.png", build_v13_icons(), (256, 16)),
    ]

    for filename, img, expected_size in outputs:
        assert img.size == expected_size, f"{filename}: {img.size} != {expected_size}"
        assert img.mode == "RGBA"
        out_path = SPRITES_DIR / filename
        img.save(out_path, format="PNG")
        print(f"OK: {out_path} -> {img.size[0]}x{img.size[1]} px ({img.mode})")


if __name__ == "__main__":
    main()
