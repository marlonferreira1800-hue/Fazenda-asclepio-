#!/usr/bin/env python3
"""
Gerador determinístico de spritesheets 16x16 pixel art para Fazendinha 2D (Godot 4.7).
Estética cozy pastel inspirada em Sprout Lands (Cup Nooble) e Tiny Town (Kenney).
Integra sprites CC0 reais de assets/oga_cc0/ quando disponíveis (com fallback embutido).

Arquivos gerados em assets/sprites/:
- terrain_tileset.png : 64x32 px (4 cols x 2 rows de 16x16)
- crops_sheet.png     : 80x96 px (5 cols x 6 rows de 16x16)
- farmer_sheet.png    : 64x64 px (4 cols walk x 4 rows direções de 16x16)
- props_buildings.png : 96x64 px (casinha 32x32, árvore 32x32, props 16x16, animais 2 frames, aspersor)
- ui_icons.png        : 256x16 px (16 ícones 16x16: ferramentas, sementes, moeda, produtos animais, aspersor, clima)
"""

from pathlib import Path
from PIL import Image, ImageDraw

ROOT_DIR = Path(__file__).resolve().parent.parent
SPRITES_DIR = ROOT_DIR / "assets" / "sprites"
OGA_FOOD_DIR = ROOT_DIR / "assets" / "oga_cc0" / "oga_16x16_food_cc0" / "food"
OGA_KENNEY_INDOOR = ROOT_DIR / "assets" / "oga_cc0" / "oga_roguelike_indoor_cc0" / "roguelikeIndoor_transparent.png"
OGA_ZELDA_INNER = ROOT_DIR / "assets" / "oga_cc0" / "oga_zelda_like_indoor_cc0" / "Inner.png"
OGA_ZELDA_OBJECTS = ROOT_DIR / "assets" / "oga_cc0" / "oga_zelda_like_indoor_cc0" / "objects.png"

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
# 2. CROPS SHEET (80x96 px = 5 estágios x 6 culturas de 16x16)
# ==============================================================================
def build_crops_sheet() -> Image.Image:
    sheet = Image.new("RGBA", (80, 96), TRANSPARENT)

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

    # Row 3 (y=48): Milho (corn)
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
            ".......GG.......",
            "......GLlG......",
            ".....GGfGG......",
            "....GLfGfLG.....",
            ".....GGfGG......",
            "......GfG.......",
            "......GfG.......",
            "......GFFG......",
            ".......GG.......",
            "................",
        ],
        [
            "................",
            "................",
            ".......GG.......",
            "......GLlG......",
            "....GGGlfGGG....",
            "...GLlGfGfLLG...",
            "....GGfffGGG....",
            "......GfG.......",
            "....GGfffGG.....",
            "...GLfGfGfLG....",
            "....GGfGfGG.....",
            "......GfG.......",
            ".....GFFFG......",
            ".....GFFFG......",
            "......GGG.......",
            "................",
        ],
        [
            ".......kk.......",
            "......kH0k......",
            "....GGGlfGGG....",
            "...GLlGfGfLLG...",
            "....GGflfGGG....",
            ".....GGfGG......",
            "...GGkllkGG.....",
            "..GLlkllkLLG....",
            "...GGkffkGG.....",
            ".....GffG.......",
            "....GLfGfLG.....",
            ".....GfffG......",
            ".....GFFFG......",
            ".....GFFFG......",
            "......GGG.......",
            "................",
        ],
        [
            "......kkkk......",
            ".....kH00Hk.....",
            "....GGGlfGGG....",
            "...GLlGfGfLLG...",
            "....GGflfGGG....",
            "...kkGGfGGkk....",
            "..kHykllkHyk....",
            "..kYykffkYyk....",
            "..k0ykffky0k....",
            "...kGkffkGk.....",
            "....GLffLG......",
            ".....GffG.......",
            ".....GFFFG......",
            ".....GFFFG......",
            "......GGG.......",
            "................",
        ],
    ]

    # Row 4 (y=64): Tomate (tomato)
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
            "....kwwk...kk...",
            ".....kk...kwwk..",
            "..kk.......kk...",
            ".kwwk..kk.......",
            "..kk..kwwk......",
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
            ".....GG..GG.....",
            "....GLlGGLlG....",
            "....GfhGGfhG....",
            ".....GffffG.....",
            "......GffG......",
            "......GFFG......",
            ".......GG.......",
            "................",
            "................",
        ],
        [
            "................",
            "................",
            "................",
            "......GGGG......",
            "....GGLhhLGG....",
            "...GLhGffGhLG...",
            "...GffGffGffG...",
            "....GffffffG....",
            "...GLhGffGhLG...",
            "....GffFFffG....",
            ".....GFFFFG.....",
            "......GGGG......",
            ".....GFFFG......",
            "......GGG.......",
            "................",
            "................",
        ],
        [
            "................",
            ".....GGGGGG.....",
            "...GGLhhhhLGG...",
            "..GLhGwYwfGhLG..",
            "..GffGfffGffwYw.",
            "..GLhGfffGffwwG.",
            "...GfwYwfGfffG..",
            "...GffwwffFFfG..",
            "....GffFFffffG..",
            ".....GGFFFFGG...",
            "......GFFFG.....",
            "......GFFFG.....",
            ".......GGG......",
            "................",
            "................",
            "................",
        ],
        [
            ".....GGGGGG.....",
            "...GGLhhhhLGG...",
            "..GLhGffffGhLG..",
            "..Gfk11kffk11k..",
            ".GLk2113kfk211k.",
            "..Gk1113kfk113k.",
            "..Gfk33kfGfk3kG.",
            "..Gfffk11kfffG..",
            "...Gfk2113kFG...",
            "...GGk1133kGG...",
            ".....GkkkGGG....",
            "......GFFG......",
            ".......GG.......",
            "................",
            "................",
            "................",
        ],
    ]

    # Row 5 (y=80): Abóbora (pumpkin)
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
            "....kWWk...kk...",
            ".....kk...kWWk..",
            "..kk.......kk...",
            ".kWWk..kk.......",
            "..kk..kWWk......",
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
            "....GGG..GGG....",
            "...GLLhGGhLLG...",
            "...GffGGGGffG...",
            "....GffGGffG....",
            ".....GffffG.....",
            "......GFFG......",
            ".......GG.......",
            "................",
            "................",
        ],
        [
            "................",
            "................",
            "................",
            "................",
            "....GGG..GGG....",
            "...GLhLGGGLhLG..",
            "..GGffGffGffGG..",
            ".GLhGffffffGhLG.",
            "..GffGffffGffG..",
            "...GffffffffG...",
            "....GffFFffG....",
            ".....GGFFGG.....",
            "......GGGG......",
            "................",
            "................",
            "................",
        ],
        [
            "................",
            "................",
            "....GGG..GGG....",
            "...GLhLGGGLhLG..",
            "..GGfGGffGGfGG..",
            ".GLhGffkkffGhLG.",
            "..GffkGllGkffG..",
            "...GfkGlhGfGffG.",
            "....GkGffGfkGG..",
            "....GkFFFFkG....",
            ".....GkkkkG.....",
            "......GGGG......",
            "................",
            "................",
            "................",
            "................",
        ],
        [
            "......GGGG......",
            ".....GLhhLG.....",
            "...GGkffffkGG...",
            "..GLhkkkkkkhLG..",
            "..Gfk877779kfG..",
            ".GLk87877979kLG.",
            "..k8778779799k..",
            "..k7778779799k..",
            "..k7777779999k..",
            "..k9777799999k..",
            "...k99799999k...",
            "...Gk999999kG...",
            "....GGkkkkGG....",
            "......GGGG......",
            "................",
            "................",
        ],
    ]

    for row_idx, stages in enumerate([
        wheat_stages,
        carrot_stages,
        strawberry_stages,
        corn_stages,
        tomato_stages,
        pumpkin_stages,
    ]):
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
# 4. PROPS & BUILDINGS (96x64 px)
# ==============================================================================
def build_props_buildings() -> Image.Image:
    sheet = Image.new("RGBA", (96, 64), TRANSPARENT)

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

    # 9. Ovelha 2 frames (16x16 each) at (64,32) and (80,32)
    sheep_0 = [
        "................",
        "................",
        ".....kkkkkk.....",
        "...kkwwwwwwkk...",
        "..kwwwwWWWWwwk..",
        ".kJkwWwwwwWWwwk.",
        "kJwkwwwwwwWWWWwk",
        "kKJkwwwwWWWWWWwk",
        ".kJkwWWWWWWWWwk.",
        "..kkWWWWWWWWWWk.",
        "...kkWWWWWWWWk..",
        "....kkkkkkkkkk..",
        "....kJJk..kJJk..",
        "....kKKk..kKKk..",
        "................",
        "................",
    ]
    sheep_1 = [
        "................",
        "................",
        "................",
        ".....kkkkkk.....",
        "...kkwwwwwwkk...",
        "..kwwwwWWWWwwk..",
        ".kJkwWwwwwWWwwk.",
        "kJwkwwwwwwWWWWwk",
        "kKJkwwwwWWWWWWwk",
        ".kJkwWWWWWWWWwk.",
        "..kkWWWWWWWWWWk.",
        "...kkWWWWWWWWk..",
        "....kkkkkkkkkk..",
        "...kJJk....kJJk.",
        "...kKKk....kKKk.",
        "................",
    ]
    paste_tile(sheet, render_grid(sheep_0, 16, 16), 64, 32)
    paste_tile(sheet, render_grid(sheep_1, 16, 16), 80, 32)

    # 10. Porco 2 frames (16x16 each) at (0,48) and (16,48)
    pig_0 = [
        "................",
        "................",
        "...kk.....kk....",
        "..kPpk...kpPk...",
        "..kppkkkkkppk...",
        ".kppppppppppkk..",
        "kKpppppppppppPk.",
        "kPPkppppppppppPk",
        "kPPppppppppppPPk",
        ".kppPPPppppPPPk.",
        "..kkppppppppPPk.",
        "....kkkkkkkkkk..",
        "....kPPk..kPPk..",
        "....kRRk..kRRk..",
        "................",
        "................",
    ]
    pig_1 = [
        "................",
        "................",
        "................",
        "...kk.....kk....",
        "..kPpk...kpPk...",
        "..kppkkkkkppk...",
        ".kppppppppppkk..",
        "kKpppppppppppPk.",
        "kPPkppppppppppPk",
        "kPPppppppppppPPk",
        ".kppPPPppppPPPk.",
        "..kkppppppppPPk.",
        "....kkkkkkkkkk..",
        "...kPPk....kPPk.",
        "...kRRk....kRRk.",
        "................",
    ]
    paste_tile(sheet, render_grid(pig_0, 16, 16), 0, 48)
    paste_tile(sheet, render_grid(pig_1, 16, 16), 16, 48)

    # 11. Aspersor Automático (16x16) at (32,48)
    sprinkler = [
        "................",
        ".....kk..kk.....",
        "....kbcbbcbk....",
        ".....kkNNkk.....",
        "....kIaaaaIk....",
        "...kIabccbaIk...",
        "...kJaaaaaaJk...",
        "....kJJJJJJk....",
        ".....kIiiIk.....",
        ".....kIjjIk.....",
        ".....kIjjIk.....",
        "....kJIIIIJk....",
        "...kJjjjjjjJk...",
        "....kkkkkkkk....",
        "................",
        "................",
    ]
    paste_tile(sheet, render_grid(sprinkler, 16, 16), 32, 48)

    return sheet


# ==============================================================================
# 5. UI ICONS (256x16 px = 16 ícones de 16x16)
# Col 0: Enxada, Col 1: Regador, Col 2: Sem. Trigo, Col 3: Sem. Cenoura,
# Col 4: Sem. Morango, Col 5: Moeda dourada, Col 6: Ovo (CC0), Col 7: Leite,
# Col 8: Sem. Milho, Col 9: Sem. Tomate, Col 10: Sem. Abóbora, Col 11: Aspersor,
# Col 12: Lã, Col 13: Trufa, Col 14: Sol, Col 15: Chuva
# ==============================================================================
def build_ui_icons() -> Image.Image:
    sheet = Image.new("RGBA", (256, 16), TRANSPARENT)

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

    # Col 8: Pacote de Semente Milho
    seed_corn = [
        "................",
        "...kkkkkkkkkk...",
        "..kEEEEEEEEEEk..",
        "..kOooooooooOk..",
        "...kkkkkkkkkk...",
        "..kwwwwwwwwwwk..",
        "..kwWWkkkkWWwk..",
        "..kwwkHyy0kwwk..",
        "..kwwGkYyGkwwk..",
        "..kwwGlY0Gkwwk..",
        "..kwwGGffGGwwk..",
        "..kwWWGGGGWWwk..",
        "..kWWWWWWWWWWk..",
        "...kkkkkkkkkk...",
        "................",
        "................",
    ]
    paste_tile(sheet, render_grid(seed_corn, 16, 16), 128, 0)

    # Col 9: Pacote de Semente Tomate
    seed_tomato = [
        "................",
        "...kkkkkkkkkk...",
        "..kEEEEEEEEEEk..",
        "..kOooooooooOk..",
        "...kkkkkkkkkk...",
        "..kwwwwwwwwwwk..",
        "..kwWWGGGGWWwk..",
        "..kwwk2111kwwk..",
        "..kwwk1113kwwk..",
        "..kwwk1133kwwk..",
        "..kwwwkkkkwwwk..",
        "..kwWWWWWWWWwk..",
        "..kWWWWWWWWWWk..",
        "...kkkkkkkkkk...",
        "................",
        "................",
    ]
    paste_tile(sheet, render_grid(seed_tomato, 16, 16), 144, 0)

    # Col 10: Pacote de Semente Abóbora
    seed_pumpkin = [
        "................",
        "...kkkkkkkkkk...",
        "..kEEEEEEEEEEk..",
        "..kOooooooooOk..",
        "...kkkkkkkkkk...",
        "..kwwwwwwwwwwk..",
        "..kwWWGGGGWWwk..",
        "..kwwk8779kwwk..",
        "..kwwk7879kwwk..",
        "..kwwk7799kwwk..",
        "..kwwwkkkkwwwk..",
        "..kwWWWWWWWWwk..",
        "..kWWWWWWWWWWk..",
        "...kkkkkkkkkk...",
        "................",
        "................",
    ]
    paste_tile(sheet, render_grid(seed_pumpkin, 16, 16), 160, 0)

    # Col 11: Aspersor Automático
    sprinkler_icon = [
        "................",
        "....kbcbbcbk....",
        ".....kkNNkk.....",
        "....kIaaaaIk....",
        "...kIabccbaIk...",
        "...kJaaaaaaJk...",
        "....kJJJJJJk....",
        ".....kIiiIk.....",
        ".....kIjjIk.....",
        "....kJIIIIJk....",
        "...kJjjjjjjJk...",
        "....kkkkkkkk....",
        "................",
        "................",
        "................",
        "................",
    ]
    paste_tile(sheet, render_grid(sprinkler_icon, 16, 16), 176, 0)

    # Col 12: Lã (Novelo/tufo fofo)
    wool_icon = [
        "................",
        ".....kkkkkk.....",
        "...kkwwwwwwkk...",
        "..kwwwWWWWwwwk..",
        ".kwwWWwwwwWWwwk.",
        ".kwwWwwWWwwWwwk.",
        ".kwWWwwWWwwWWwk.",
        "..kwwWWWWWWwwk..",
        "..kWWwwWWwwWWk..",
        "...kWWWWWWWWk...",
        "....kWWWWWWk....",
        ".....kkkkkk.....",
        "................",
        "................",
        "................",
        "................",
    ]
    paste_tile(sheet, render_grid(wool_icon, 16, 16), 192, 0)

    # Col 13: Trufa (Porco)
    truffle_icon = [
        "................",
        "................",
        ".....kkkkkk.....",
        "...kkOoooooek...",
        "..keOOoZoooeeek.",
        ".keOooeeeZoooZek",
        ".keoZeeeeeZZoeek",
        ".keeZZeeeZZZeZZk",
        "..keZZZeeeeZZZk.",
        "...kZZZZZZZZZk..",
        "....kkkkkkkkk...",
        "................",
        "................",
        "................",
        "................",
        "................",
    ]
    paste_tile(sheet, render_grid(truffle_icon, 16, 16), 208, 0)

    # Col 14: Sol (Clima ensolarado)
    sun_icon = [
        "................",
        ".......yy.......",
        "..y....yy....y..",
        "...y..kkkk..y...",
        "....kHyyyyHk....",
        "...kHyyyyyyYk...",
        ".yykyywwwwyYYyy.",
        ".yykyywyyyyYYyy.",
        "...kYYYYYYYYk...",
        "....kY0000Yk....",
        "...y..kkkk..y...",
        "..y....yy....y..",
        ".......yy.......",
        "................",
        "................",
        "................",
    ]
    paste_tile(sheet, render_grid(sun_icon, 16, 16), 224, 0)

    # Col 15: Chuva (Clima chuvoso)
    rain_icon = [
        "................",
        ".....kkkkkk.....",
        "...kkIIIIIIkk...",
        "..kIIwwwwwwIIk..",
        ".kIwwwwIIIIIIJk.",
        ".kIIIIJJJJJJJJk.",
        "..kkkkkkkkkkkk..",
        "................",
        "...bb..bb..bb...",
        "..ba..ba..ba....",
        "..a...a...a.....",
        "....bb..bb..bb..",
        "...ba..ba..ba...",
        "...a...a...a....",
        "................",
        "................",
    ]
    paste_tile(sheet, render_grid(rain_icon, 16, 16), 240, 0)

    return sheet


def _load_oga_food_16(filename: str) -> Image.Image | None:
    path = OGA_FOOD_DIR / filename
    if not path.is_file():
        return None
    img = Image.open(path).convert("RGBA")
    if img.size != (16, 16):
        img = img.resize((16, 16), Image.Resampling.NEAREST)
    return img




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



# ==============================================================================
# 6. HOUSE INTERIOR (256x160 px = 16 cols x 10 rows de 16x16, assets CC0)
# Integra Kenney Roguelike Indoor Pack, ArMM1998 Zelda-like Inner/Objects
# e OGA 16x16 Food, harmonizado com a paleta da casinha da fazenda.
# ==============================================================================
def build_house_interior() -> Image.Image:
    sheet = Image.new("RGBA", (256, 160), TRANSPARENT)

    kenney = Image.open(OGA_KENNEY_INDOOR).convert("RGBA") if OGA_KENNEY_INDOOR.is_file() else None
    zelda = Image.open(OGA_ZELDA_INNER).convert("RGBA") if OGA_ZELDA_INNER.is_file() else None
    zobj = Image.open(OGA_ZELDA_OBJECTS).convert("RGBA") if OGA_ZELDA_OBJECTS.is_file() else None

    def gk(col: int, row: int) -> Image.Image:
        if kenney is None:
            return Image.new("RGBA", (16, 16), TRANSPARENT)
        return kenney.crop((col * 17, row * 17, col * 17 + 16, row * 17 + 16))

    def gz(col: int, row: int) -> Image.Image:
        if zelda is None:
            return Image.new("RGBA", (16, 16), TRANSPARENT)
        return zelda.crop((col * 16, row * 16, col * 16 + 16, row * 16 + 16))

    def gzo(col: int, row: int) -> Image.Image:
        if zobj is None:
            return Image.new("RGBA", (16, 16), TRANSPARENT)
        return zobj.crop((col * 16, row * 16, col * 16 + 16, row * 16 + 16))

    def put_cell(col: int, row: int, tile: Image.Image) -> None:
        paste_tile(sheet, tile, col * 16, row * 16)

    # --- Row 0 (y=0): Pisos & Paredes do TileMapLayer ---
    # (0,0) e (1,0): Piso de tábuas de madeira (Zelda Inner 0,4 e 1,4)
    put_cell(0, 0, gz(0, 4))
    put_cell(1, 0, gz(1, 4))
    # (2,0): Piso xadrez da cozinha (Zelda Inner 0,0)
    put_cell(2, 0, gz(0, 0))

    # Cores da casinha da fazenda (paleta consistente com o exterior)
    c_bg = hex_rgba("#18110e")
    c_dark = PAL["B"]        # #42281c
    c_wood_d = PAL["e"]      # #7a462b
    c_wood_m = PAL["o"]      # #a66742
    c_wood_l = PAL["O"]      # #c9895b
    c_cream = PAL["n"]       # #f7edd9
    c_cream_s = PAL["M"]     # #dfd0b2

    # (3,0): Parede norte superior (reboco creme + viga de madeira superior)
    wall_top = Image.new("RGBA", (16, 16), c_cream)
    d = ImageDraw.Draw(wall_top)
    d.rectangle((0, 0, 15, 2), fill=c_dark)
    d.rectangle((0, 3, 15, 5), fill=c_wood_m)
    d.rectangle((0, 6, 15, 7), fill=c_wood_d)
    d.rectangle((0, 8, 15, 9), fill=c_cream_s)
    put_cell(3, 0, wall_top)

    # (4,0): Parede norte inferior (lambril de madeira + sombra do rodapé)
    wall_bot = Image.new("RGBA", (16, 16), c_cream)
    d = ImageDraw.Draw(wall_bot)
    d.rectangle((0, 0, 15, 4), fill=c_cream)
    d.rectangle((0, 5, 15, 6), fill=c_wood_l)
    d.rectangle((0, 7, 15, 13), fill=c_wood_m)
    for px in (0, 8):
        d.line((px, 7, px, 13), fill=c_wood_d)
    d.rectangle((0, 14, 15, 15), fill=c_dark)
    put_cell(4, 0, wall_bot)

    # (5,0): Parede esquerda (16px: escuro fora + borda madeira dentro)
    wall_left = Image.new("RGBA", (16, 16), c_bg)
    d = ImageDraw.Draw(wall_left)
    d.rectangle((6, 0, 15, 15), fill=c_dark)
    d.rectangle((8, 0, 13, 15), fill=c_wood_d)
    d.rectangle((9, 0, 12, 15), fill=c_wood_m)
    d.rectangle((10, 0, 11, 15), fill=c_wood_l)
    put_cell(5, 0, wall_left)

    # (6,0): Parede direita (espelho da parede esquerda)
    put_cell(6, 0, wall_left.transpose(Image.Transpose.FLIP_LEFT_RIGHT))

    # (7,0): Parede sul (borda madeira + escuro embaixo)
    wall_south = Image.new("RGBA", (16, 16), c_bg)
    d = ImageDraw.Draw(wall_south)
    d.rectangle((0, 0, 15, 9), fill=c_dark)
    d.rectangle((0, 2, 15, 7), fill=c_wood_d)
    d.rectangle((0, 3, 15, 6), fill=c_wood_m)
    d.rectangle((0, 4, 15, 4), fill=c_wood_l)
    put_cell(7, 0, wall_south)

    # (8,0): Quina topo-esquerda
    c_tl = Image.new("RGBA", (16, 16), c_bg)
    d = ImageDraw.Draw(c_tl)
    d.rectangle((6, 0, 15, 15), fill=c_dark)
    d.rectangle((8, 3, 15, 15), fill=c_wood_d)
    d.rectangle((9, 4, 15, 15), fill=c_wood_m)
    d.rectangle((10, 4, 15, 6), fill=c_wood_l)
    d.rectangle((10, 4, 11, 15), fill=c_wood_l)
    put_cell(8, 0, c_tl)

    # (9,0): Quina topo-direita
    put_cell(9, 0, c_tl.transpose(Image.Transpose.FLIP_LEFT_RIGHT))

    # (10,0): Quina base-esquerda
    c_bl = Image.new("RGBA", (16, 16), c_bg)
    d = ImageDraw.Draw(c_bl)
    d.rectangle((6, 0, 15, 9), fill=c_dark)
    d.rectangle((8, 0, 15, 7), fill=c_wood_d)
    d.rectangle((9, 0, 15, 6), fill=c_wood_m)
    d.rectangle((10, 0, 11, 5), fill=c_wood_l)
    d.rectangle((10, 4, 15, 4), fill=c_wood_l)
    put_cell(10, 0, c_bl)

    # (11,0): Quina base-direita
    put_cell(11, 0, c_bl.transpose(Image.Transpose.FLIP_LEFT_RIGHT))

    # (12,0) e (13,0): Soleira iluminada da porta de saída
    thresh_l = gz(0, 4).copy()
    d = ImageDraw.Draw(thresh_l)
    d.rectangle((0, 0, 1, 15), fill=c_dark)
    d.rectangle((2, 0, 15, 11), fill=PAL["T"])
    d.rectangle((2, 4, 15, 9), fill=PAL["t"])
    d.rectangle((2, 11, 15, 13), fill=c_wood_m)
    d.rectangle((2, 14, 15, 15), fill=c_dark)
    put_cell(12, 0, thresh_l)
    put_cell(13, 0, thresh_l.transpose(Image.Transpose.FLIP_LEFT_RIGHT))

    # (14,0) e (15,0): Capacho acolhedor coral/creme na entrada
    mat_l = [
        "................",
        "................",
        "..RRRRRRRRRRRRRR",
        ".Rxxxxxxxxxxxxxx",
        ".Rxnnnnnnnnnnnnn",
        ".Rxnrrrrrrrrrrrr",
        ".RxnrXXrrrrXXrrr",
        ".RxnrXXrrrrXXrrr",
        ".Rxnrrrrrrrrrrrr",
        ".Rxnnnnnnnnnnnnn",
        ".RXXXXXXXXXXXXXX",
        "..RRRRRRRRRRRRRR",
        "................",
        "................",
        "................",
        "................",
    ]
    mat_tile_l = render_grid(mat_l, 16, 16)
    put_cell(14, 0, mat_tile_l)
    put_cell(15, 0, mat_tile_l.transpose(Image.Transpose.FLIP_LEFT_RIGHT))

    # --- Rows 1..3 (y=16..63): Tapetes & Decoração de Parede ---
    # (0..2, 1..3): Tapete verde bordado 48x48 (Zelda Inner 0..2, 7..9)
    for dr in range(3):
        for dc in range(3):
            put_cell(dc, 1 + dr, gz(dc, 7 + dr))

    # (3..4, 1): Tapete plano acolhedor coral/creme 32x16 para quarto (com franjas)
    rug_bed_l = [
        "................",
        "................",
        "..BBBBBBBBBBBBBB",
        ".wnrrrrrrrrrrrrr",
        "..nrxxxxxxxxxxxx",
        ".wnrxrrrrrrrrrrr",
        "..nrxrrnnrrnnrrr",
        ".wnrxrrrrrrrrrrr",
        "..nrxrrnnrrnnrrr",
        ".wnrxrrrrrrrrrrr",
        "..nrXXXXXXXXXXXX",
        ".wnrrrrrrrrrrrrr",
        "..BBBBBBBBBBBBBB",
        "................",
        "................",
        "................",
    ]
    rug_bed_tile_l = render_grid(rug_bed_l, 16, 16)
    put_cell(3, 1, rug_bed_tile_l)
    put_cell(4, 1, rug_bed_tile_l.transpose(Image.Transpose.FLIP_LEFT_RIGHT))

    # (5..6, 1): Tapete plano creme/dourado 32x16 para mesa de jantar
    rug_din_l = [
        "................",
        "..BBBBBBBBBBBBBB",
        ".wnYYYYYYYYYYYYY",
        "..nYyyyyyyyyyyyy",
        ".wnYyrrrrrrrrrrr",
        "..nYyrnnnnnnnnnn",
        ".wnYyrnYYYYYYYYY",
        "..nYyrnnnnnnnnnn",
        ".wnYyrrrrrrrrrrr",
        "..nYyyyyyyyyyyyy",
        ".wnYYYYYYYYYYYYY",
        "..BBBBBBBBBBBBBB",
        "................",
        "................",
        "................",
        "................",
    ]
    rug_din_tile_l = render_grid(rug_din_l, 16, 16)
    put_cell(5, 1, rug_din_tile_l)
    put_cell(6, 1, rug_din_tile_l.transpose(Image.Transpose.FLIP_LEFT_RIGHT))

    # (7..8, 1): Janela dupla aconchegante 32x16 (paleta da casinha)
    win_l = [
        "................",
        ".BBBBBBBBBBBBBBB",
        ".BOOOOOOOOOOOOOO",
        ".Boaaaaaaaaaacca",
        ".Boaaabcaaaaaaba",
        ".Boaaaaaaaaaaaaa",
        ".BoBBBBBBBBBBBBB",
        ".Boaaaaaaaaaacca",
        ".Boaaabbaaaaaaba",
        ".Boaaaccaaaaaaaa",
        ".Boaaaaaaaaaaaaa",
        ".BOOOOOOOOOOOOOO",
        ".BBBBBBBBBBBBBBB",
        "..eeeeeeeeeeeeee",
        "................",
        "................",
    ]
    win_tile_l = render_grid(win_l, 16, 16)
    put_cell(7, 1, win_tile_l)
    put_cell(8, 1, win_tile_l.transpose(Image.Transpose.FLIP_LEFT_RIGHT))

    # (9,1): Quadro paisagem (Zelda Inner 9,0)
    put_cell(9, 1, gz(9, 0))
    # (10,1): Quadro prado/céu centralizado (Zelda Inner 11,5 deslocado +4px)
    pic2 = Image.new("RGBA", (16, 16), TRANSPARENT)
    pic2.paste(gz(11, 5), (0, 5), gz(11, 5))
    put_cell(10, 1, pic2)
    # (11,1): Mapa na parede (Kenney 18,0)
    put_cell(11, 1, gk(18, 0))
    # (12,1): Cano da chaminé do fogão (Kenney 15,15)
    put_cell(12, 1, gk(15, 15))
    # (13,1) e (14,1): Vasinhos de planta (Kenney 16,0 e 17,0)
    put_cell(13, 1, gk(16, 0))
    put_cell(14, 1, gk(17, 0))
    # (15,1): Vaso com flor azul (Zelda Inner 9,12)
    put_cell(15, 1, gz(9, 12))

    # --- Rows 4..6 (y=64..111): Cozinha, Lareira, Estante, Cama, Piano, Armário ---
    # (0..4, 4): Balcão, Pia, Potes, Pratos, Fogão (Kenney)
    put_cell(0, 4, gk(0, 12))
    put_cell(1, 4, gk(8, 12))
    put_cell(2, 4, gk(5, 12))
    put_cell(3, 4, gk(7, 12))
    put_cell(4, 4, gk(14, 14))

    # (5..6, 4..6): Lareira de tijolos 32x48 (Zelda Inner 12..13, 10..11 + 10..11, 12)
    for dc in range(2):
        put_cell(5 + dc, 4, gz(12 + dc, 10))
        put_cell(5 + dc, 5, gz(12 + dc, 11))
        put_cell(5 + dc, 6, gz(10 + dc, 12))

    # (7..9, 4..5): Estante de livros 48x32 (Zelda Inner 3..5, 12..13)
    for dr in range(2):
        for dc in range(3):
            put_cell(7 + dc, 4 + dr, gz(3 + dc, 12 + dr))

    # (10..11, 4..6): Cama de casal aconchegante 32x48 (Zelda Inner 16,1..3 + 18,1..3)
    for dr in range(3):
        put_cell(10, 4 + dr, gz(16, 1 + dr))
        put_cell(11, 4 + dr, gz(18, 1 + dr))

    # (12..13, 4..5): Piano vertical 32x32 (Kenney 23..24, 8..9)
    for dr in range(2):
        for dc in range(2):
            put_cell(12 + dc, 4 + dr, gk(23 + dc, 8 + dr))

    # (14..15, 4..6): Guarda-roupa de madeira 32x48 (Zelda Inner 6,9..11 + 8,9..11)
    for dr in range(3):
        put_cell(14, 4 + dr, gz(6, 9 + dr))
        put_cell(15, 4 + dr, gz(8, 9 + dr))

    # --- Rows 7..9 (y=112..159): Mesa, Cadeiras, Planta Alta, Baú, Diário, Comidas, Fogo ---
    # (0..1, 7..8): Mesa de jantar 32x32 (Zelda Inner 10,1 + 12,1 / 10,3 + 12,3)
    put_cell(0, 7, gz(10, 1))
    put_cell(1, 7, gz(12, 1))
    put_cell(0, 8, gz(10, 3))
    put_cell(1, 8, gz(12, 3))

    # (2..5, 7): Cadeiras de madeira nas 4 direções (Kenney)
    put_cell(2, 7, gk(1, 2))
    put_cell(3, 7, gk(2, 2))
    put_cell(4, 7, gk(3, 2))
    put_cell(5, 7, gk(0, 2))

    # (6, 7..8): Planta alta florida 16x32 (Zelda Inner 8, 12..13)
    put_cell(6, 7, gz(8, 12))
    put_cell(6, 8, gz(8, 13))

    # (7, 7): Baú de madeira (Zelda objects 0,0)
    put_cell(7, 7, gzo(0, 0))
    # (8, 7): Livro/Diário aberto (Zelda Inner 13,9)
    put_cell(8, 7, gz(13, 9))
    # (9, 7): Tigela de sopa quentinha (Zelda Inner 14,6)
    put_cell(9, 7, gz(14, 6))

    # (10, 7): Prato com pão caseiro (OGA 16x16 Food CC0 redimensionado 10x10 sobre prato)
    bread_plate = Image.new("RGBA", (16, 16), TRANSPARENT)
    d = ImageDraw.Draw(bread_plate)
    d.ellipse((2, 4, 13, 13), fill=PAL["w"], outline=PAL["k"])
    bread_src = OGA_FOOD_DIR / "bread_loaf_white.png"
    if bread_src.is_file():
        b_img = Image.open(bread_src).convert("RGBA").resize((10, 10), Image.Resampling.NEAREST)
        bread_plate.paste(b_img, (3, 3), b_img)
    put_cell(10, 7, bread_plate)

    # (11, 7): Prato com maçã vermelha (OGA 16x16 Food CC0)
    apple_plate = Image.new("RGBA", (16, 16), TRANSPARENT)
    d = ImageDraw.Draw(apple_plate)
    d.ellipse((3, 5, 12, 13), fill=PAL["W"], outline=PAL["k"])
    apple_src = OGA_FOOD_DIR / "apple_red.png"
    if apple_src.is_file():
        a_img = Image.open(apple_src).convert("RGBA").resize((9, 9), Image.Resampling.NEAREST)
        apple_plate.paste(a_img, (4, 4), a_img)
    put_cell(11, 7, apple_plate)

    # (12..14, 7): Chamas animadas da lareira (Zelda objects 4..6, 3)
    put_cell(12, 7, gzo(4, 3))
    put_cell(13, 7, gzo(5, 3))
    put_cell(14, 7, gzo(6, 3))

    # (15, 7): Abajur acolhedor de mesa (pixel art limpa sem halo escuro)
    lamp = [
        "................",
        "................",
        ".....kkkkkk.....",
        "....kHyyyyHk....",
        "...kHywwwwyHk...",
        "...k0yyyyyy0k...",
        "....kkkkkkkk....",
        "......k0Hk......",
        "......k0Hk......",
        ".....kBBBBk.....",
        ".....kOeeOk.....",
        "......kkkk......",
        "................",
        "................",
        "................",
        "................",
    ]
    put_cell(15, 7, render_grid(lamp, 16, 16))

    # (0..1, 9): Escrivaninha de madeira 32x16 (Kenney 0,12 e 2,12)
    put_cell(0, 9, gk(0, 12))
    put_cell(1, 9, gk(2, 12))
    # (2, 9): Criado-mudo de madeira (Zelda Inner 10,7)
    put_cell(2, 9, gz(10, 7))
    # (3, 9): Vasinho de ervas (Zelda Inner 11,11)
    put_cell(3, 9, gz(11, 11))
    # (4, 9): Bule/caneca de chá (Zelda Inner 11,6)
    put_cell(4, 9, gz(11, 6))

    return sheet


def main() -> None:
    SPRITES_DIR.mkdir(parents=True, exist_ok=True)

    outputs: list[tuple[str, Image.Image, tuple[int, int]]] = [
        ("terrain_tileset.png", build_terrain_tileset(), (64, 32)),
        ("crops_sheet.png", build_crops_sheet(), (80, 96)),
        ("farmer_sheet.png", build_farmer_sheet(), (64, 64)),
        ("props_buildings.png", build_props_buildings(), (96, 64)),
        ("ui_icons.png", build_ui_icons(), (256, 16)),
        ("v13_props_sheet.png", build_v13_props_sheet(), (112, 32)),
        ("v13_icons.png", build_v13_icons(), (256, 16)),
        ("house_interior.png", build_house_interior(), (256, 160)),
    ]

    for filename, img, expected_size in outputs:
        assert img.size == expected_size, f"{filename}: {img.size} != {expected_size}"
        assert img.mode == "RGBA"
        out_path = SPRITES_DIR / filename
        img.save(out_path, format="PNG")
        print(f"OK: {out_path} -> {img.size[0]}x{img.size[1]} px ({img.mode})")


if __name__ == "__main__":
    main()
