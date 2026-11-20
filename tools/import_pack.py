#!/usr/bin/env python3
"""
Importador seguro de pacotes de sprites externos para Fazendinha 2D (Godot 4.7).

Suporta arquivos .zip ou pastas extraídas de:
- Sprout Lands (Cup Nooble / itch.io)
- Kenney Tiny Town (kenney.nl)

Antes de substituir qualquer arquivo em assets/sprites/, cria um backup em
assets/sprites_backup/ e preserva as dimensões e grades exatas exigidas pelo jogo:
- terrain_tileset.png : 64x32 RGBA
- crops_sheet.png     : 80x96 RGBA
- farmer_sheet.png    : 64x64 RGBA
- props_buildings.png : 96x64 RGBA
- ui_icons.png        : 256x16 RGBA

Uso:
  python tools/import_pack.py --source caminho/do/pacote.zip
  python tools/import_pack.py --pack sprout-lands --source caminho/da/pasta
  python tools/import_pack.py --pack kenney-tiny-town --source kenney_tiny-town.zip
  python tools/import_pack.py --source pacote.zip --list
  python tools/import_pack.py --source pacote.zip --dry-run
  python tools/import_pack.py --restore
"""

from __future__ import annotations

import argparse
import io
import shutil
import sys
import zipfile
from pathlib import Path
from PIL import Image

ROOT_DIR = Path(__file__).resolve().parent.parent
SPRITES_DIR = ROOT_DIR / "assets" / "sprites"
BACKUP_DIR = ROOT_DIR / "assets" / "sprites_backup"

EXPECTED_SIZES: dict[str, tuple[int, int]] = {
    "terrain_tileset.png": (64, 32),
    "crops_sheet.png": (80, 96),
    "farmer_sheet.png": (64, 64),
    "props_buildings.png": (96, 64),
    "ui_icons.png": (256, 16),
}


class PackSource:
    """Abstração de leitura para arquivos .zip ou diretórios extraídos."""

    def __init__(self, source_path: Path) -> None:
        self.source_path = source_path
        self._zip: zipfile.ZipFile | None = None
        if source_path.is_file() and source_path.suffix.lower() == ".zip":
            self._zip = zipfile.ZipFile(source_path, "r")
            self._entries = [
                n.replace("\\", "/")
                for n in self._zip.namelist()
                if not n.endswith("/")
            ]
        elif source_path.is_dir():
            self._entries = [
                p.relative_to(source_path).as_posix()
                for p in source_path.rglob("*")
                if p.is_file()
            ]
        else:
            raise FileNotFoundError(
                f"Fonte inválida (esperado .zip ou pasta): {source_path}"
            )

    def close(self) -> None:
        if self._zip is not None:
            self._zip.close()
            self._zip = None

    def __enter__(self) -> "PackSource":
        return self

    def __exit__(self, *_: object) -> None:
        self.close()

    @property
    def entries(self) -> list[str]:
        return self._entries

    def find_image(self, *candidates: str) -> str | None:
        """Encontra o primeiro arquivo PNG correspondente (match por sufixo ou nome)."""
        pngs = [e for e in self._entries if e.lower().endswith(".png")]
        for cand in candidates:
            cand_norm = cand.lower().replace("\\", "/")
            # 1) Match exato de caminho final
            for entry in pngs:
                if entry.lower().endswith("/" + cand_norm) or entry.lower() == cand_norm:
                    return entry
            # 2) Match apenas pelo basename
            cand_base = Path(cand_norm).name
            for entry in pngs:
                if Path(entry).name.lower() == cand_base:
                    return entry
        return None

    def open_image(self, entry: str) -> Image.Image:
        if self._zip is not None:
            data = self._zip.read(entry)
            return Image.open(io.BytesIO(data)).convert("RGBA")
        return Image.open(self.source_path / entry).convert("RGBA")


def crop_cell(
    sheet: Image.Image,
    col: int,
    row: int,
    cell_w: int = 16,
    cell_h: int = 16,
    spacing: int = 0,
    margin: int = 0,
) -> Image.Image | None:
    x = margin + col * (cell_w + spacing)
    y = margin + row * (cell_h + spacing)
    if x + cell_w > sheet.width or y + cell_h > sheet.height:
        return None
    return sheet.crop((x, y, x + cell_w, y + cell_h))


def fit_tile(tile: Image.Image, target_w: int, target_h: int) -> Image.Image:
    """Ajusta um sprite ao tamanho alvo preservando pixels nítidos (nearest-neighbor)."""
    tile = tile.convert("RGBA")
    if tile.size == (target_w, target_h):
        return tile
    # Se o sprite for maior e tiver margem transparente ao redor (ex.: frame 48x48),
    # recorta o centro ou conteúdo antes de redimensionar.
    if tile.width >= target_w * 2 and tile.height >= target_h * 2:
        bbox = tile.getbbox()
        if bbox is not None:
            bw = bbox[2] - bbox[0]
            bh = bbox[3] - bbox[1]
            if bw <= target_w and bh <= target_h:
                cx = (bbox[0] + bbox[2]) // 2
                cy = (bbox[1] + bbox[3]) // 2
                left = max(0, min(tile.width - target_w, cx - target_w // 2))
                top = max(0, min(tile.height - target_h, cy - target_h // 2))
                return tile.crop((left, top, left + target_w, top + target_h))
    return tile.resize((target_w, target_h), Image.Resampling.NEAREST)


def replace_region(
    canvas: Image.Image,
    tile: Image.Image | None,
    x: int,
    y: int,
    w: int,
    h: int,
) -> bool:
    if tile is None:
        return False
    fitted = fit_tile(tile, w, h)
    if fitted.getbbox() is None:
        return False
    canvas.paste((0, 0, 0, 0), (x, y, x + w, y + h))
    canvas.paste(fitted, (x, y), fitted)
    return True


def detect_pack(src: PackSource) -> str:
    joined = "\n".join(src.entries).lower()
    if "charakter" in joined or "sprout" in joined or "tilled_dirt" in joined or "tilled dirt" in joined:
        return "sprout-lands"
    if "tile_0000.png" in joined or "tilemap_packed.png" in joined or "tiny-town" in joined:
        return "kenney-tiny-town"
    raise ValueError(
        "Não foi possível detectar o tipo de pacote automaticamente. "
        "Informe --pack sprout-lands ou --pack kenney-tiny-town."
    )


def load_base_sheets() -> dict[str, Image.Image]:
    sheets: dict[str, Image.Image] = {}
    for name, size in EXPECTED_SIZES.items():
        path = SPRITES_DIR / name
        if path.is_file():
            im = Image.open(path).convert("RGBA")
            if im.size != size:
                raise ValueError(f"Base {path} tem tamanho {im.size}, esperado {size}")
            sheets[name] = im
        else:
            sheets[name] = Image.new("RGBA", size, (0, 0, 0, 0))
    return sheets


def map_sprout_lands(src: PackSource, sheets: dict[str, Image.Image]) -> list[str]:
    """Mapeia sprites do Sprout Lands para os 5 spritesheets do projeto."""
    changes: list[str] = []

    terrain = sheets["terrain_tileset.png"]
    crops = sheets["crops_sheet.png"]
    farmer = sheets["farmer_sheet.png"]
    props = sheets["props_buildings.png"]
    ui = sheets["ui_icons.png"]

    grass_entry = src.find_image("Tilesets/Grass.png", "Grass.png")
    if grass_entry:
        g_img = src.open_image(grass_entry)
        if replace_region(terrain, crop_cell(g_img, 1, 1, 16, 16), 0, 0, 16, 16):
            changes.append(f"terrain(0,0 grama) <- {grass_entry}")
        if replace_region(terrain, crop_cell(g_img, 0, 5, 16, 16) or crop_cell(g_img, 1, 5, 16, 16), 16, 0, 16, 16):
            changes.append(f"terrain(1,0 flores) <- {grass_entry}")

    dirt_entry = src.find_image("Tilesets/Tilled_Dirt.png", "Tilled Dirt.png", "Tilled_Dirt_Wide.png")
    if dirt_entry:
        d_img = src.open_image(dirt_entry)
        if replace_region(terrain, crop_cell(d_img, 1, 1, 16, 16), 32, 0, 16, 16):
            changes.append(f"terrain(2,0 terra batida) <- {dirt_entry}")
        if replace_region(terrain, crop_cell(d_img, 1, 1, 16, 16), 0, 16, 16, 16):
            changes.append(f"terrain(0,1 solo arado) <- {dirt_entry}")

    water_entry = src.find_image("Tilesets/Water.png", "Water.png")
    if water_entry:
        w_img = src.open_image(water_entry)
        if replace_region(terrain, crop_cell(w_img, 0, 0, 16, 16), 48, 0, 16, 16):
            changes.append(f"terrain(3,0 água) <- {water_entry}")

    fence_entry = src.find_image("Tilesets/Fences.png", "Fences.png")
    if fence_entry:
        f_img = src.open_image(fence_entry)
        if replace_region(terrain, crop_cell(f_img, 1, 1, 16, 16) or crop_cell(f_img, 0, 0, 16, 16), 32, 16, 16, 16):
            changes.append(f"terrain(2,1 cerca) <- {fence_entry}")

    chest_entry = src.find_image("Objects/Chest.png", "Chest.png")
    if chest_entry:
        c_img = src.open_image(chest_entry)
        cell_sz = 48 if c_img.width >= 48 and c_img.height >= 48 else 16
        if replace_region(terrain, crop_cell(c_img, 0, 0, cell_sz, cell_sz), 48, 16, 16, 16):
            changes.append(f"terrain(3,1 caixa venda) <- {chest_entry}")

    plants_entry = src.find_image("Objects/Basic_Plants.png", "Basic_Plants.png", "Basic Plants.png")
    if plants_entry:
        p_img = src.open_image(plants_entry)
        # Sprout Lands Basic_Plants possui 6 colunas (col 0=ícone, cols 1..5=estágios) e 2 linhas
        start_col = 1 if p_img.width >= 96 else 0
        mapped_rows = min(2, p_img.height // 16)
        for row_idx in range(mapped_rows):
            for stage_idx in range(5):
                tile = crop_cell(p_img, start_col + stage_idx, row_idx, 16, 16)
                if replace_region(crops, tile, stage_idx * 16, row_idx * 16, 16, 16):
                    changes.append(f"crops(row={row_idx},stage={stage_idx}) <- {plants_entry}")

    farmer_entry = src.find_image(
        "Characters/Basic Charakter Spritesheet.png",
        "Basic Charakter Spritesheet.png",
        "Basic_Charakter_Spritesheet.png",
    )
    if farmer_entry:
        ch_img = src.open_image(farmer_entry)
        cell_w = ch_img.width // 4 if ch_img.width >= 64 else 16
        cell_h = ch_img.height // 4 if ch_img.height >= 64 else 16
        for row_idx in range(4):
            for col_idx in range(4):
                tile = crop_cell(ch_img, col_idx, row_idx, cell_w, cell_h)
                if replace_region(farmer, tile, col_idx * 16, row_idx * 16, 16, 16):
                    pass
        changes.append(f"farmer_sheet (4x4) <- {farmer_entry}")

    chicken_entry = src.find_image("Characters/Free Chicken Sprites.png", "Free Chicken Sprites.png")
    if chicken_entry:
        ck_img = src.open_image(chicken_entry)
        for idx in range(2):
            replace_region(props, crop_cell(ck_img, idx, 0, 16, 16), idx * 16, 32, 16, 16)
        changes.append(f"props(galinha 2 frames) <- {chicken_entry}")

    cow_entry = src.find_image("Characters/Free Cow Sprites.png", "Free Cow Sprites.png")
    if cow_entry:
        cw_img = src.open_image(cow_entry)
        cw_size = 32 if cw_img.width >= 64 and cw_img.height >= 32 else 16
        for idx in range(2):
            replace_region(props, crop_cell(cw_img, idx, 0, cw_size, cw_size), 32 + idx * 16, 32, 16, 16)
        changes.append(f"props(vaca 2 frames) <- {cow_entry}")

    biom_entry = src.find_image("Objects/Basic_Grass_Biom_things.png", "Basic_Grass_Biom_things.png")
    if biom_entry:
        bm_img = src.open_image(biom_entry)
        if replace_region(props, crop_cell(bm_img, 0, 0, 32, 32), 32, 0, 32, 32):
            changes.append(f"props(árvore 32x32) <- {biom_entry}")

    tools_entry = src.find_image("Objects/Basic_tools_and_meterials.png", "Basic_tools_and_meterials.png")
    if tools_entry:
        tl_img = src.open_image(tools_entry)
        if replace_region(ui, crop_cell(tl_img, 1, 0, 16, 16), 0, 0, 16, 16):
            changes.append(f"ui(enxada col 0) <- {tools_entry}")
        if replace_region(ui, crop_cell(tl_img, 0, 0, 16, 16), 16, 0, 16, 16):
            changes.append(f"ui(regador col 1) <- {tools_entry}")

    milk_entry = src.find_image("Objects/Simple_Milk_and_grass_item.png", "Simple_Milk_and_grass_item.png")
    if milk_entry:
        mk_img = src.open_image(milk_entry)
        if replace_region(ui, crop_cell(mk_img, 0, 0, 16, 16), 112, 0, 16, 16):
            changes.append(f"ui(leite col 7) <- {milk_entry}")

    return changes


def map_kenney_tiny_town(src: PackSource, sheets: dict[str, Image.Image]) -> list[str]:
    """Mapeia tiles do Kenney Tiny Town para os spritesheets do projeto."""
    changes: list[str] = []
    terrain = sheets["terrain_tileset.png"]
    props = sheets["props_buildings.png"]

    packed_entry = src.find_image("Tilemap/tilemap_packed.png", "tilemap_packed.png")
    spaced_entry = src.find_image("Tilemap/tilemap.png", "tilemap.png")

    def get_kenney_tile(index: int) -> tuple[Image.Image | None, str]:
        tile_name = f"Tiles/tile_{index:04d}.png"
        single = src.find_image(tile_name, f"tile_{index:04d}.png")
        if single:
            return src.open_image(single), single
        col = index % 12
        row = index // 12
        if packed_entry:
            img = src.open_image(packed_entry)
            return crop_cell(img, col, row, 16, 16, spacing=0), f"{packed_entry}[{col},{row}]"
        if spaced_entry:
            img = src.open_image(spaced_entry)
            return crop_cell(img, col, row, 16, 16, spacing=1), f"{spaced_entry}[{col},{row}]"
        return None, ""

    # Mapeamento padrão do Kenney Tiny Town (grade 12x11, 132 tiles)
    terrain_map = [
        (0, 0, 0, "grama lisa"),
        (1, 16, 0, "grama detalhes"),
        (43, 32, 0, "caminho terra"),
        (44, 32, 16, "cerca madeira"),
        (89, 48, 16, "caixa/baú"),
    ]
    for tile_idx, dx, dy, label in terrain_map:
        tile, origin = get_kenney_tile(tile_idx)
        if replace_region(terrain, tile, dx, dy, 16, 16):
            changes.append(f"terrain({label}) <- {origin}")

    # Árvore / arbusto / pedra / poço
    props_map = [
        (4, 32, 0, 32, 32, "árvore"),
        (29, 80, 0, 16, 16, "arbusto"),
        (103, 64, 16, 16, 16, "poço"),
        (83, 80, 16, 16, 16, "placa loja"),
    ]
    for tile_idx, dx, dy, dw, dh, label in props_map:
        tile, origin = get_kenney_tile(tile_idx)
        if replace_region(props, tile, dx, dy, dw, dh):
            changes.append(f"props({label}) <- {origin}")

    return changes


def backup_current_sprites(dry_run: bool = False) -> Path:
    """Cria backup em assets/sprites_backup/ se ainda não existir."""
    if not BACKUP_DIR.exists():
        if not dry_run:
            BACKUP_DIR.mkdir(parents=True, exist_ok=True)
            for name in EXPECTED_SIZES:
                src_file = SPRITES_DIR / name
                if src_file.is_file():
                    shutil.copy2(src_file, BACKUP_DIR / name)
        print(f"Backup preparado em: {BACKUP_DIR}")
    else:
        print(f"Backup existente preservado em: {BACKUP_DIR}")
    return BACKUP_DIR


def restore_backup() -> int:
    if not BACKUP_DIR.is_dir():
        print(f"ERRO: Backup não encontrado em {BACKUP_DIR}", file=sys.stderr)
        return 1
    SPRITES_DIR.mkdir(parents=True, exist_ok=True)
    restored = 0
    for name, expected_size in EXPECTED_SIZES.items():
        b_file = BACKUP_DIR / name
        if b_file.is_file():
            im = Image.open(b_file).convert("RGBA")
            if im.size != expected_size:
                print(f"AVISO: {b_file} tamanho {im.size} != {expected_size}", file=sys.stderr)
                continue
            shutil.copy2(b_file, SPRITES_DIR / name)
            print(f"Restaurado: {SPRITES_DIR / name} ({im.size[0]}x{im.size[1]})")
            restored += 1
    if restored == 0:
        print("ERRO: Nenhum arquivo válido encontrado no backup.", file=sys.stderr)
        return 1
    return 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Importa pacotes Sprout Lands ou Kenney Tiny Town para assets/sprites/ com backup automático."
    )
    parser.add_argument(
        "--pack",
        choices=["auto", "sprout-lands", "kenney-tiny-town"],
        default="auto",
        help="Formato do pacote de origem (padrão: auto).",
    )
    parser.add_argument(
        "--source",
        type=Path,
        help="Caminho para o arquivo .zip baixado ou pasta extraída do pacote.",
    )
    parser.add_argument(
        "--list",
        action="store_true",
        help="Apenas lista os PNGs encontrados no pacote e sai.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Simula o mapeamento sem alterar assets/sprites/.",
    )
    parser.add_argument(
        "--restore",
        action="store_true",
        help="Restaura os sprites originais a partir de assets/sprites_backup/.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if args.restore:
        return restore_backup()

    if args.source is None:
        print("ERRO: Informe --source <arquivo.zip ou pasta> ou use --restore.", file=sys.stderr)
        return 2

    source_path = args.source.expanduser().resolve()
    with PackSource(source_path) as src:
        if args.list:
            pngs = [e for e in src.entries if e.lower().endswith(".png")]
            print(f"Total de PNGs em {source_path.name}: {len(pngs)}")
            for p in sorted(pngs):
                im = src.open_image(p)
                print(f"  - {p} ({im.width}x{im.height})")
            return 0

        pack_kind = detect_pack(src) if args.pack == "auto" else args.pack
        print(f"Pacote selecionado: {pack_kind} ({source_path})")

        sheets = load_base_sheets()
        if pack_kind == "sprout-lands":
            changes = map_sprout_lands(src, sheets)
        else:
            changes = map_kenney_tiny_town(src, sheets)

        if not changes:
            print(
                "ERRO: Nenhum arquivo compatível do pacote foi encontrado. "
                "Use --list para inspecionar o conteúdo.",
                file=sys.stderr,
            )
            return 1

        for item in changes:
            print(f"  + {item}")

        if args.dry_run:
            print(f"[DRY-RUN] {len(changes)} mapeamento(s) simulado(s); nenhum arquivo gravado.")
            return 0

        backup_current_sprites(dry_run=False)
        SPRITES_DIR.mkdir(parents=True, exist_ok=True)
        for name, img in sheets.items():
            expected_size = EXPECTED_SIZES[name]
            assert img.size == expected_size, f"{name}: {img.size} != {expected_size}"
            assert img.mode == "RGBA"
            out_path = SPRITES_DIR / name
            img.save(out_path, format="PNG")
            print(f"OK: {out_path} -> {img.size[0]}x{img.size[1]} RGBA")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
