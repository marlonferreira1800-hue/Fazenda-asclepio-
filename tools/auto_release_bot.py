#!/usr/bin/env python3
"""
Robô Agente de Release — Fazendinha 2D (Godot 4.7.2)
Valida as 5 Regras/Barreiras de Critério (RELEASE_RULES.md) antes de aprovar,
versionar (Antes vs. Depois), exportar Web HTML5 e publicar no GitHub.
"""

from __future__ import annotations

import argparse
import datetime
import fnmatch
import os
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

try:
    from PIL import Image
except ImportError:  # pragma: no cover
    Image = None

REPO_ROOT = Path(__file__).resolve().parent.parent
PROJECT_GODOT = REPO_ROOT / "project.godot"
VERSION_DATA_GD = REPO_ROOT / "scripts" / "data" / "version_data.gd"
CHANGELOG_MD = REPO_ROOT / "CHANGELOG.md"
EXPORT_PRESETS = REPO_ROOT / "export_presets.cfg"
WEB_INDEX = REPO_ROOT / "build" / "web" / "index.html"

REPO_SLUG = "marlonferreira1800-hue/Fazenda-asclepio-"
REPO_URL = f"https://github.com/{REPO_SLUG}"

EXPECTED_SPRITES: dict[str, tuple[int, int]] = {
    "assets/sprites/terrain_tileset.png": (64, 32),
    "assets/sprites/crops_sheet.png": (80, 48),
    "assets/sprites/farmer_sheet.png": (64, 64),
    "assets/sprites/props_buildings.png": (96, 48),
    "assets/sprites/ui_icons.png": (128, 16),
}

FORBIDDEN_TEMP_PATTERNS = [
    "test_*.gd",
    "test_*.py",
    "verify_*.gd",
    "verify_*.py",
    "tmp_*",
    "debug_*",
    "*.tmp",
    "*.bak",
]

FORBIDDEN_SECRET_FILES = {
    ".env",
    ".env.local",
    ".env.production",
    "export_credentials.cfg",
    "id_rsa",
    "id_ed25519",
}

SECRET_REGEXES = [
    re.compile(r"gh" + r"p_[A-Za-z0-9]{20,}"),
    re.compile(r"github" + r"_pat_[A-Za-z0-9_]{20,}"),
    re.compile(r"AIza" + r"Sy[A-Za-z0-9_-]{20,}"),
    re.compile(r"-----BEGIN (?:RSA |OPENSSH |EC )?PRIVATE KEY-----"),
]

SKIP_WALK_DIRS = {
    ".git",
    ".godot",
    "build",
    "__pycache__",
    "oga_cc0",
    "sprites_backup",
}


@dataclass
class RuleResult:
    rule_id: int
    name: str
    passed: bool
    details: list[str]


def run_cmd(cmd: list[str], cwd: Path = REPO_ROOT, timeout: int = 180) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        cmd,
        cwd=str(cwd),
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=timeout,
    )


def find_godot_binary(override: str | None = None) -> Path | None:
    candidates: list[Path] = []
    if override:
        candidates.append(Path(override))
    env_bin = os.environ.get("GODOT_BIN")
    if env_bin:
        candidates.append(Path(env_bin))
    for cmd_name in ("godot", "godot4", "Godot_v4.7.2-stable_win64.exe"):
        resolved = shutil.which(cmd_name)
        if resolved:
            candidates.append(Path(resolved))
    candidates.extend([
        Path(r"C:\Users\marlo\OneDrive\Desktop\Godot_v4.7.2-stable_win64.exe"),
        Path.home() / "OneDrive" / "Desktop" / "Godot_v4.7.2-stable_win64.exe",
        Path.home() / "Desktop" / "Godot_v4.7.2-stable_win64.exe",
    ])
    for cand in candidates:
        if cand.is_file():
            return cand
    return None


def parse_versions() -> tuple[str | None, str | None]:
    proj_ver = None
    vd_ver = None
    if PROJECT_GODOT.is_file():
        text = PROJECT_GODOT.read_text(encoding="utf-8", errors="replace")
        m = re.search(r'^config/version="([^"]+)"', text, flags=re.MULTILINE)
        if m:
            proj_ver = m.group(1).strip()
    if VERSION_DATA_GD.is_file():
        text = VERSION_DATA_GD.read_text(encoding="utf-8", errors="replace")
        m = re.search(r'^const\s+CURRENT_VERSION\s*:?=\s*"([^"]+)"', text, flags=re.MULTILINE)
        if m:
            vd_ver = m.group(1).strip().lstrip("v")
    return proj_ver, vd_ver


def bump_semver(current: str, bump: str) -> str:
    clean = current.strip().lstrip("v")
    parts = clean.split(".")
    if len(parts) != 3 or not all(p.isdigit() for p in parts):
        raise ValueError(f"Versão semântica inválida: {current}")
    major, minor, patch = (int(parts[0]), int(parts[1]), int(parts[2]))
    if bump == "major":
        return f"{major + 1}.0.0"
    if bump == "minor":
        return f"{major}.{minor + 1}.0"
    if bump == "patch":
        return f"{major}.{minor}.{patch + 1}"
    raise ValueError(f"Tipo de bump inválido: {bump}")


def check_rule_1_syntax(godot_bin: Path | None) -> RuleResult:
    details: list[str] = []
    if godot_bin is None:
        return RuleResult(1, "Barreira de Sintaxe Godot 4.7.2", False, ["Executável do Godot 4.7.2 não encontrado."])

    gd_files = sorted((REPO_ROOT / "scripts").rglob("*.gd"))
    if not gd_files:
        return RuleResult(1, "Barreira de Sintaxe Godot 4.7.2", False, ["Nenhum arquivo .gd encontrado em scripts/."])

    failed = False
    for gd in gd_files:
        rel = gd.relative_to(REPO_ROOT).as_posix()
        res = run_cmd([
            str(godot_bin),
            "--headless",
            "--no-header",
            "--quit",
            "--check-only",
            "--path",
            str(REPO_ROOT),
            "-s",
            f"res://{rel}",
        ])
        combined = f"{res.stdout}\n{res.stderr}"
        if res.returncode != 0 or "SCRIPT ERROR" in combined:
            failed = True
            details.append(f"[ERRO] res://{rel} (exit={res.returncode}): {combined.strip()}")
        else:
            details.append(f"[OK] res://{rel}")

    return RuleResult(1, "Barreira de Sintaxe Godot 4.7.2", not failed, details)


def check_rule_2_assets() -> RuleResult:
    details: list[str] = []
    if Image is None:
        return RuleResult(2, "Barreira de Assets & Grade RGBA", False, ["Biblioteca Pillow (PIL) não instalada."])

    failed = False
    for rel_path, expected_size in EXPECTED_SPRITES.items():
        full = REPO_ROOT / rel_path
        if not full.is_file():
            failed = True
            details.append(f"[ERRO] Arquivo ausente: {rel_path}")
            continue
        try:
            with Image.open(full) as img:
                size_ok = img.size == expected_size
                mode_ok = img.mode == "RGBA"
                bbox = img.getbbox()
                if not size_ok or not mode_ok or bbox is None:
                    failed = True
                    details.append(
                        f"[ERRO] {rel_path}: obtido size={img.size}, mode={img.mode}, non_empty={bbox is not None}; "
                        f"esperado {expected_size} RGBA não vazio"
                    )
                else:
                    details.append(f"[OK] {rel_path} ({img.size[0]}x{img.size[1]} {img.mode})")
        except Exception as exc:
            failed = True
            details.append(f"[ERRO] Falha ao abrir {rel_path}: {exc}")

    return RuleResult(2, "Barreira de Assets & Grade RGBA", not failed, details)


def check_rule_3_boot_and_hygiene(godot_bin: Path | None) -> RuleResult:
    details: list[str] = []
    failed = False

    if godot_bin is None:
        failed = True
        details.append("[ERRO] Executável do Godot 4.7.2 não encontrado para boot.")
    else:
        res = run_cmd([
            str(godot_bin),
            "--headless",
            "--no-header",
            "--path",
            str(REPO_ROOT),
            "--quit-after",
            "10",
        ])
        combined = f"{res.stdout}\n{res.stderr}"
        has_err = res.returncode != 0 or "SCRIPT ERROR" in combined or "ERROR:" in combined
        if has_err:
            failed = True
            details.append(f"[ERRO] Boot main.tscn falhou (exit={res.returncode}): {combined.strip()}")
        else:
            details.append("[OK] Boot headless res://scenes/main.tscn (--quit-after 10) EXIT=0, 0 erros")

    temp_hits: list[str] = []
    secret_hits: list[str] = []
    for root, dirs, files in os.walk(REPO_ROOT):
        dirs[:] = [d for d in dirs if d not in SKIP_WALK_DIRS]
        for fname in files:
            fpath = Path(root) / fname
            rel = fpath.relative_to(REPO_ROOT).as_posix()
            if fname in FORBIDDEN_SECRET_FILES or fname.endswith(".pem") or fname.endswith(".key"):
                secret_hits.append(rel)
            if any(fnmatch.fnmatch(fname, pat) for pat in FORBIDDEN_TEMP_PATTERNS):
                temp_hits.append(rel)
            if fpath.suffix.lower() in {".gd", ".tscn", ".godot", ".cfg", ".md", ".py", ".yml", ".yaml", ".json", ".bat"}:
                if fpath.stat().st_size <= 512_000:
                    content = fpath.read_text(encoding="utf-8", errors="ignore")
                    for rx in SECRET_REGEXES:
                        if rx.search(content):
                            secret_hits.append(f"{rel} (padrão secreto detectado)")

    if temp_hits:
        failed = True
        details.append(f"[ERRO] Arquivos temporários encontrados: {', '.join(temp_hits)}")
    else:
        details.append("[OK] Higiene: 0 arquivos temporários (test_*, verify_*, *.tmp)")

    if secret_hits:
        failed = True
        details.append(f"[ERRO] Possíveis segredos expostos: {', '.join(secret_hits)}")
    else:
        details.append("[OK] Segurança: 0 segredos ou credenciais expostas")

    return RuleResult(3, "Barreira de Boot & Higiene do Repositório", not failed, details)


def get_git_status_lines() -> list[str]:
    res = run_cmd(["git", "status", "--porcelain"])
    if res.returncode != 0:
        return []
    return [line for line in res.stdout.splitlines() if line.strip()]


def check_rule_4_change_and_before_after(
    mode: str,
    bump: str,
    title: str | None,
    before: str | None,
    after: str | None,
) -> tuple[RuleResult, str, str]:
    details: list[str] = []
    failed = False

    proj_ver, vd_ver = parse_versions()
    if not proj_ver or not vd_ver or proj_ver != vd_ver:
        failed = True
        details.append(f"[ERRO] Versão divergente: project.godot={proj_ver} vs version_data.gd={vd_ver}")
        current_ver = proj_ver or vd_ver or "0.0.0"
    else:
        current_ver = proj_ver
        details.append(f"[OK] Versão atual sincronizada: v{current_ver}")

    try:
        next_ver = bump_semver(current_ver, bump)
    except ValueError as exc:
        failed = True
        details.append(f"[ERRO] {exc}")
        next_ver = current_ver

    git_changes = get_git_status_lines()
    if mode == "check":
        vd_text = VERSION_DATA_GD.read_text(encoding="utf-8", errors="replace") if VERSION_DATA_GD.is_file() else ""
        ch_text = CHANGELOG_MD.read_text(encoding="utf-8", errors="replace") if CHANGELOG_MD.is_file() else ""
        has_ba_vd = '"before":' in vd_text and '"after":' in vd_text
        has_ba_ch = "Antes vs. Depois" in ch_text and f"[v{current_ver}]" in ch_text
        if not has_ba_vd or not has_ba_ch:
            failed = True
            details.append("[ERRO] Quadro Antes vs. Depois ausente em version_data.gd ou CHANGELOG.md.")
        else:
            details.append("[OK] Histórico Antes vs. Depois validado em version_data.gd e CHANGELOG.md")
        details.append(f"[INFO] Working tree: {len(git_changes)} arquivo(s) modificado(s)")
    else:
        title_clean = (title or "").strip()
        before_clean = (before or "").strip()
        after_clean = (after or "").strip()
        if len(title_clean) < 3:
            failed = True
            details.append("[ERRO] --title é obrigatório (mínimo 3 caracteres).")
        if len(before_clean) < 5 or len(after_clean) < 5:
            failed = True
            details.append("[ERRO] --before e --after são obrigatórios (mínimo 5 caracteres cada).")
        elif before_clean.lower() == after_clean.lower():
            failed = True
            details.append("[ERRO] --before e --after não podem ser idênticos.")
        else:
            details.append(f"[OK] Bump semântico ({bump}): v{current_ver} -> v{next_ver}")
            details.append(f"[OK] Antes: {before_clean}")
            details.append(f"[OK] Depois: {after_clean}")

        if mode == "publish":
            if not git_changes:
                failed = True
                details.append("[ERRO] Nenhuma alteração real (git status limpo). Proibido subir versão sem diff real.")
            else:
                details.append(f"[OK] Diff real detectado no Git ({len(git_changes)} alteração(ões))")
        else:
            if git_changes:
                details.append(f"[OK] Diff real detectado no Git ({len(git_changes)} alteração(ões))")
            else:
                details.append("[OK (dry-run)] Working tree limpa; simulação aprovada (--publish exigirá diff real)")

    return RuleResult(4, "Critério de Mudança Real & Antes/Depois", not failed, details), current_ver, next_ver


def check_rule_5_web_and_github(mode: str, godot_bin: Path | None) -> RuleResult:
    details: list[str] = []
    failed = False

    if not EXPORT_PRESETS.is_file() or 'name="Web"' not in EXPORT_PRESETS.read_text(encoding="utf-8", errors="ignore"):
        failed = True
        details.append("[ERRO] Preset 'Web' ausente em export_presets.cfg.")
    else:
        details.append("[OK] Preset 'Web' configurado em export_presets.cfg")

    web_files = [
        WEB_INDEX,
        REPO_ROOT / "build" / "web" / "index.pck",
        REPO_ROOT / "build" / "web" / "index.wasm",
    ]
    missing_web = [p.relative_to(REPO_ROOT).as_posix() for p in web_files if not p.is_file()]
    if missing_web and mode != "publish":
        failed = True
        details.append(f"[ERRO] Artefatos Web ausentes: {', '.join(missing_web)}")
    elif not missing_web:
        details.append("[OK] Build Web presente (index.html, index.pck, index.wasm)")

    git_bin = shutil.which("git")
    gh_bin = shutil.which("gh")
    if not git_bin:
        failed = True
        details.append("[ERRO] Git não encontrado no PATH.")
    else:
        details.append("[OK] Git disponível")

    if gh_bin:
        gh_auth = run_cmd([gh_bin, "auth", "status"])
        if gh_auth.returncode == 0:
            details.append("[OK] GitHub CLI (gh) autenticado")
        else:
            if mode == "publish":
                failed = True
                details.append(f"[ERRO] GitHub CLI (gh) não autenticado: {gh_auth.stderr.strip()}")
            else:
                details.append("[INFO] GitHub CLI (gh) encontrado (auth não verificada para modo offline)")
    else:
        if mode == "publish":
            failed = True
            details.append("[ERRO] GitHub CLI (gh) obrigatório para --publish.")
        else:
            details.append("[INFO] GitHub CLI (gh) ausente no PATH (somente exigido em --publish)")

    if mode == "publish" and godot_bin is None:
        failed = True
        details.append("[ERRO] Executável Godot 4.7.2 necessário para re-exportar Web em --publish.")

    return RuleResult(5, "Build Web Sincronizado & Rastreabilidade GitHub", not failed, details)


def _gd_escape(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')


def update_version_files(
    current_ver: str,
    next_ver: str,
    bump: str,
    title: str,
    before: str,
    after: str,
    fixes: list[str],
    issue_num: int | None,
) -> None:
    today = datetime.date.today().isoformat()
    v_tag = f"v{next_ver}"

    # 1. project.godot
    pg_text = PROJECT_GODOT.read_text(encoding="utf-8")
    pg_new, count = re.subn(
        r'^config/version="[^"]+"',
        f'config/version="{next_ver}"',
        pg_text,
        count=1,
        flags=re.MULTILINE,
    )
    if count != 1:
        raise RuntimeError("Não foi possível atualizar config/version em project.godot")
    PROJECT_GODOT.write_text(pg_new, encoding="utf-8")

    # 2. scripts/data/version_data.gd
    vd_text = VERSION_DATA_GD.read_text(encoding="utf-8")
    vd_text = re.sub(
        r'^const\s+CURRENT_VERSION\s*:?=\s*"[^"]+"',
        f'const CURRENT_VERSION := "{v_tag}"',
        vd_text,
        count=1,
        flags=re.MULTILINE,
    )
    prefix = f"Issue #{issue_num}: " if issue_num else ""
    highlights = [f"Antes -> Depois: {before} -> {after}"]
    if fixes:
        for idx, item in enumerate(fixes):
            item_prefix = prefix if idx == 0 else ""
            highlights.append(f"{item_prefix}{item}")
    else:
        highlights.append(f"{prefix}{title}")

    hl_lines = "\n".join(f'\t\t\t"{_gd_escape(h)}",' for h in highlights)
    new_entry = (
        "\t{\n"
        f'\t\t"version": "{v_tag}",\n'
        f'\t\t"title": "{_gd_escape(title)}",\n'
        f'\t\t"date": "{today}",\n'
        '\t\t"author": "@marlonferreira1800-hue",\n'
        f'\t\t"tag_url": "{REPO_URL}/releases/tag/{v_tag}",\n'
        f'\t\t"before": "{_gd_escape(before)}",\n'
        f'\t\t"after": "{_gd_escape(after)}",\n'
        '\t\t"highlights": [\n'
        f"{hl_lines}\n"
        "\t\t],\n"
        "\t},\n"
    )
    marker = "const HISTORY: Array[Dictionary] = [\n"
    if marker not in vd_text:
        raise RuntimeError("Marcador HISTORY não encontrado em version_data.gd")
    vd_text = vd_text.replace(marker, marker + new_entry, 1)
    VERSION_DATA_GD.write_text(vd_text, encoding="utf-8")

    # 3. CHANGELOG.md
    ch_text = CHANGELOG_MD.read_text(encoding="utf-8")
    issue_md = (
        f"**Issue [#{issue_num}]({REPO_URL}/issues/{issue_num}):** "
        if issue_num
        else ""
    )
    fixes_md = "\n".join(
        f"- {issue_md if idx == 0 else ''}{item}" for idx, item in enumerate(fixes or [title])
    )
    ch_block = (
        f"## [{v_tag}] — {today}\n\n"
        f"**{title}**\n"
        f"- **Release:** [{v_tag}]({REPO_URL}/releases/tag/{v_tag})\n"
        "- **Contribuidor:** [@marlonferreira1800-hue](https://github.com/marlonferreira1800-hue)\n\n"
        "### 🔄 Antes vs. Depois\n"
        f"- **Antes:** {before}\n"
        f"- **Depois:** {after}\n\n"
        "### Bugs Resolvidos e Melhorias\n"
        f"{fixes_md}\n\n"
        "---\n\n"
    )
    first_release_idx = ch_text.find("## [v")
    if first_release_idx == -1:
        raise RuntimeError("Seção de versão não encontrada em CHANGELOG.md")
    ch_text = ch_text[:first_release_idx] + ch_block + ch_text[first_release_idx:]
    CHANGELOG_MD.write_text(ch_text, encoding="utf-8")


def publish_release(
    godot_bin: Path,
    current_ver: str,
    next_ver: str,
    bump: str,
    title: str,
    before: str,
    after: str,
    fixes: list[str],
) -> int:
    v_tag = f"v{next_ver}"
    commit_prefix = "fix" if bump == "patch" else "feat"
    issue_label = "bug" if bump == "patch" else "enhancement"
    issue_title = f"{commit_prefix}: {title}"
    fixes_text = "\n".join(f"- {f}" for f in (fixes or [title]))
    issue_body = (
        f"## Versão alvo\n{v_tag} (anterior: v{current_ver})\n\n"
        f"## Antes vs. Depois\n- **Antes:** {before}\n- **Depois:** {after}\n\n"
        f"## Correções / Melhorias\n{fixes_text}\n"
    )

    print("\n[PUBLISH] 1/5 Criando Issue no GitHub...")
    issue_res = run_cmd([
        "gh", "issue", "create",
        "--repo", REPO_SLUG,
        "--title", issue_title,
        "--body", issue_body,
        "--label", issue_label,
    ])
    if issue_res.returncode != 0:
        print(f"[ERRO] Falha ao criar Issue: {issue_res.stderr}")
        return 1
    issue_url = issue_res.stdout.strip().splitlines()[-1]
    m_num = re.search(r"/issues/(\d+)", issue_url)
    issue_num = int(m_num.group(1)) if m_num else None
    print(f"[OK] Issue criada: {issue_url}")

    print("[PUBLISH] 2/5 Atualizando project.godot, version_data.gd e CHANGELOG.md...")
    update_version_files(current_ver, next_ver, bump, title, before, after, fixes, issue_num)

    print("[PUBLISH] 3/5 Re-exportando build Web HTML5 sincronizado...")
    exp_res = run_cmd([
        str(godot_bin),
        "--headless",
        "--path", str(REPO_ROOT),
        "--export-release", "Web",
        "build/web/index.html",
    ])
    if exp_res.returncode != 0:
        print(f"[ERRO] Export Web falhou: {exp_res.stdout}\n{exp_res.stderr}")
        return 1
    print("[OK] Build Web atualizado em build/web/index.html")

    print("[PUBLISH] 4/5 Executando git add, commit e push (sem --force)...")
    run_cmd(["git", "add", "-A"])
    close_ref = f" (#{issue_num})" if issue_num else ""
    commit_msg = f"{commit_prefix}: {title}{close_ref}"
    commit_res = run_cmd(["git", "commit", "-m", commit_msg])
    if commit_res.returncode != 0:
        print(f"[ERRO] git commit falhou: {commit_res.stdout}\n{commit_res.stderr}")
        return 1
    push_res = run_cmd(["git", "push", "origin", "HEAD"])
    if push_res.returncode != 0:
        print(f"[ERRO] git push falhou: {push_res.stdout}\n{push_res.stderr}")
        return 1

    if issue_num is not None:
        run_cmd([
            "gh", "issue", "close", str(issue_num),
            "--repo", REPO_SLUG,
            "--comment", f"Resolvido e publicado na release {v_tag}.",
        ])

    print(f"[PUBLISH] 5/5 Publicando GitHub Release {v_tag}...")
    release_notes = (
        f"## 🔄 Antes vs. Depois\n"
        f"- **Antes:** {before}\n"
        f"- **Depois:** {after}\n\n"
        f"## 🐛 Correções e Melhorias\n{fixes_text}\n\n"
        + (f"Closes #{issue_num}\n" if issue_num else "")
    )
    rel_res = run_cmd([
        "gh", "release", "create", v_tag,
        "--repo", REPO_SLUG,
        "--title", f"{v_tag} — {title}",
        "--notes", release_notes,
    ])
    if rel_res.returncode != 0:
        print(f"[ERRO] gh release create falhou: {rel_res.stderr}")
        return 1
    print(f"[OK] Release publicada: {rel_res.stdout.strip()}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Robô Agente de Release — Validação das 5 Barreiras e Publicação (Fazendinha 2D)"
    )
    mode_group = parser.add_mutually_exclusive_group(required=True)
    mode_group.add_argument("--check", action="store_true", help="Executa auditoria das 5 regras sem alterar arquivos.")
    mode_group.add_argument("--dry-run", action="store_true", help="Simula bump + quadro Antes vs. Depois sem alterar arquivos.")
    mode_group.add_argument("--publish", action="store_true", help="Valida tudo, atualiza versão, exporta Web e publica no GitHub.")

    parser.add_argument("--bump", choices=["patch", "minor", "major"], default="patch", help="Tipo de incremento semântico.")
    parser.add_argument("--title", type=str, default="", help="Título curto da atualização/bug resolvido.")
    parser.add_argument("--before", type=str, default="", help="Descrição de como estava ANTES da correção.")
    parser.add_argument("--after", type=str, default="", help="Descrição de como ficou DEPOIS da correção.")
    parser.add_argument("--fixes", action="append", default=[], help="Item(ns) corrigido(s) (pode repetir a flag).")
    parser.add_argument("--godot", type=str, default=None, help="Caminho explícito do Godot 4.7.2.")
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    mode = "check" if args.check else ("dry-run" if args.dry_run else "publish")
    godot_bin = find_godot_binary(args.godot)

    print("============================================================")
    print(f" ROBO AGENTE DE RELEASE — FAZENDINHA 2D (MODO: {mode.upper()})")
    print("============================================================")
    print(f"Repositório: {REPO_ROOT}")
    print(f"Godot 4.7.2: {godot_bin if godot_bin else 'NÃO ENCONTRADO'}")
    print("------------------------------------------------------------")

    r1 = check_rule_1_syntax(godot_bin)
    r2 = check_rule_2_assets()
    r3 = check_rule_3_boot_and_hygiene(godot_bin)
    r4, current_ver, next_ver = check_rule_4_change_and_before_after(
        mode, args.bump, args.title, args.before, args.after
    )
    r5 = check_rule_5_web_and_github(mode, godot_bin)

    results = [r1, r2, r3, r4, r5]
    all_passed = all(r.passed for r in results)

    for res in results:
        tag = "PASS" if res.passed else "FAIL"
        print(f"\n[Regra {res.rule_id} - {tag}] {res.name}")
        for line in res.details:
            print(f"  {line}")

    print("\n============================================================")
    if not all_passed:
        print(" RESULTADO FINAL: REJECTED (corrija as barreiras acima)")
        print("============================================================")
        return 1

    print(f" RESULTADO FINAL: APPROVED ({mode.upper()})")
    if mode == "dry-run":
        fixes = args.fixes if args.fixes else [args.title.strip()]
        print("------------------------------------------------------------")
        print(f" PREVIEW DA RELEASE: v{current_ver} -> v{next_ver} ({args.bump})")
        print(f" Título : {args.title.strip()}")
        print(f" Antes  : {args.before.strip()}")
        print(f" Depois : {args.after.strip()}")
        print(" Itens  :")
        for item in fixes:
            print(f"   - {item}")
    print("============================================================")

    if mode == "publish":
        assert godot_bin is not None
        return publish_release(
            godot_bin,
            current_ver,
            next_ver,
            args.bump,
            args.title.strip(),
            args.before.strip(),
            args.after.strip(),
            [f.strip() for f in args.fixes if f.strip()],
        )

    return 0


if __name__ == "__main__":
    sys.exit(main())
